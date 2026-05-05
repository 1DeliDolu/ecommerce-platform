package com.pehlione.ecommerce.security;

import io.github.bucket4j.Bandwidth;
import io.github.bucket4j.Bucket;
import io.github.bucket4j.ConsumptionProbe;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.annotation.Order;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.time.Duration;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.TimeUnit;

@Component
@Order(1)
public class RateLimitingFilter extends OncePerRequestFilter {

    private static final String[] RATE_LIMITED_PREFIXES = {
            "/api/auth/login", "/api/auth/register", "/api/auth/refresh"
    };
    private static final long ONE_SECOND_IN_NANOS = TimeUnit.SECONDS.toNanos(1);

    private final Map<String, Bucket> buckets = new ConcurrentHashMap<>();
    private final int requestsPerMinute;

    public RateLimitingFilter(
            @Value("${app.security.rate-limit.auth-requests-per-minute:20}") int requestsPerMinute
    ) {
        if (requestsPerMinute <= 0) {
            throw new IllegalArgumentException("app.security.rate-limit.auth-requests-per-minute must be greater than 0");
        }
        this.requestsPerMinute = requestsPerMinute;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {
        String path = request.getRequestURI();
        boolean isRateLimited = isRateLimitedPath(path);

        if (!isRateLimited) {
            filterChain.doFilter(request, response);
            return;
        }

        String clientKey = resolveClientKey(request);
        Bucket bucket = buckets.computeIfAbsent(clientKey, k -> createBucket());
        ConsumptionProbe probe = bucket.tryConsumeAndReturnRemaining(1);

        if (probe.isConsumed()) {
            response.setHeader("X-Rate-Limit-Remaining", String.valueOf(probe.getRemainingTokens()));
            filterChain.doFilter(request, response);
        } else {
            long retryAfterSeconds = toRetryAfterSeconds(probe.getNanosToWaitForRefill());
            response.setStatus(HttpStatus.TOO_MANY_REQUESTS.value());
            response.setContentType(MediaType.APPLICATION_JSON_VALUE);
            response.setCharacterEncoding("UTF-8");
            response.setHeader("X-Rate-Limit-Remaining", "0");
            response.setHeader("Retry-After", String.valueOf(retryAfterSeconds));
            response.getWriter().write("{\"error\":\"Too many requests. Try again in " + retryAfterSeconds + " seconds.\"}");
        }
    }

    private boolean isRateLimitedPath(String path) {
        for (String prefix : RATE_LIMITED_PREFIXES) {
            if (path.equals(prefix) || path.startsWith(prefix + "/")) {
                return true;
            }
        }
        return false;
    }

    private long toRetryAfterSeconds(long nanosToWaitForRefill) {
        if (nanosToWaitForRefill <= 0) {
            return 1;
        }
        long roundedUpSeconds = (nanosToWaitForRefill + ONE_SECOND_IN_NANOS - 1) / ONE_SECOND_IN_NANOS;
        return Math.max(1, roundedUpSeconds);
    }

    private Bucket createBucket() {
        return Bucket.builder()
                .addLimit(Bandwidth.builder()
                        .capacity(requestsPerMinute)
                        .refillGreedy(requestsPerMinute, Duration.ofMinutes(1))
                        .build())
                .build();
    }

    private String resolveClientKey(HttpServletRequest request) {
        String xff = request.getHeader("X-Forwarded-For");
        if (xff != null && !xff.isBlank()) {
            String forwarded = xff.split(",")[0].trim();
            if (!forwarded.isBlank()) {
                return forwarded;
            }
        }
        String xri = request.getHeader("X-Real-IP");
        if (xri != null && !xri.isBlank()) {
            return xri.trim();
        }
        String remoteAddr = request.getRemoteAddr();
        return (remoteAddr == null || remoteAddr.isBlank()) ? "unknown-client" : remoteAddr;
    }
}

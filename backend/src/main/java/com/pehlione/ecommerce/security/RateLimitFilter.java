package com.pehlione.ecommerce.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.time.Instant;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * IP-based sliding-window rate limiter.
 * Auth endpoints: 10 requests / 60 s.
 * All other endpoints: 100 requests / 60 s.
 */
@Component
public class RateLimitFilter extends OncePerRequestFilter {

    static final int AUTH_MAX_REQUESTS = 10;
    static final int GENERAL_MAX_REQUESTS = 100;
    static final long WINDOW_SECONDS = 60;

    private final Map<String, WindowCounter> counters = new ConcurrentHashMap<>();

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain chain)
            throws ServletException, IOException {

        String clientIp = resolveClientIp(request);
        boolean isAuthPath = request.getRequestURI().startsWith("/api/auth/");
        int maxRequests = isAuthPath ? AUTH_MAX_REQUESTS : GENERAL_MAX_REQUESTS;
        String key = (isAuthPath ? "auth:" : "gen:") + clientIp;

        WindowCounter counter = counters.computeIfAbsent(key, k -> new WindowCounter());
        if (!counter.tryAcquire(maxRequests, WINDOW_SECONDS)) {
            response.setStatus(HttpStatus.TOO_MANY_REQUESTS.value());
            response.setContentType("application/json");
            response.getWriter().write("{\"error\":\"Too many requests. Please try again later.\"}");
            return;
        }

        chain.doFilter(request, response);
    }

    static String resolveClientIp(HttpServletRequest request) {
        String xForwardedFor = request.getHeader("X-Forwarded-For");
        if (xForwardedFor != null && !xForwardedFor.isBlank()) {
            return xForwardedFor.split(",")[0].trim();
        }
        return request.getRemoteAddr();
    }

    static class WindowCounter {
        private long windowStart = Instant.now().getEpochSecond();
        private int count = 0;

        synchronized boolean tryAcquire(int maxRequests, long windowSeconds) {
            long now = Instant.now().getEpochSecond();
            if (now - windowStart >= windowSeconds) {
                windowStart = now;
                count = 0;
            }
            if (count >= maxRequests) {
                return false;
            }
            count++;
            return true;
        }
    }
}

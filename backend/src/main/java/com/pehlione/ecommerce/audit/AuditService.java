package com.pehlione.ecommerce.audit;

import jakarta.servlet.http.HttpServletRequest;
import org.slf4j.MDC;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.stereotype.Service;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

@Service
public class AuditService {
    private final JdbcTemplate jdbcTemplate;

    public AuditService(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public void record(String action, String resourceType, String resourceId, String details) {
        HttpServletRequest request = currentRequest();
        String actorEmail = currentActorEmail();
        jdbcTemplate.update(
                """
                INSERT INTO audit_logs (
                    actor_email, action, resource_type, resource_id, ip_address, user_agent, details
                )
                VALUES (?, ?, ?, ?, ?, ?, ?)
                """,
                actorEmail,
                action,
                resourceType,
                resourceId,
                request == null ? null : request.getRemoteAddr(),
                request == null ? null : request.getHeader("User-Agent"),
                detailsWithCorrelation(details)
        );
    }

    private String currentActorEmail() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null
                || !authentication.isAuthenticated()
                || authentication instanceof AnonymousAuthenticationToken) {
            return null;
        }
        return authentication.getName();
    }

    private HttpServletRequest currentRequest() {
        if (RequestContextHolder.getRequestAttributes() instanceof ServletRequestAttributes attributes) {
            return attributes.getRequest();
        }
        return null;
    }

    private String detailsWithCorrelation(String details) {
        String correlationId = MDC.get("correlationId");
        if (correlationId == null || correlationId.isBlank()) {
            return details;
        }
        String safeDetails = details == null ? "" : details;
        return safeDetails.isBlank()
                ? "correlationId=" + correlationId
                : safeDetails + "; correlationId=" + correlationId;
    }
}

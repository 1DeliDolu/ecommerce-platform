package com.pehlione.ecommerce.security;

import com.pehlione.ecommerce.audit.AuditAction;
import com.pehlione.ecommerce.audit.AuditService;
import com.pehlione.ecommerce.event.KafkaEventPublisher;
import com.pehlione.ecommerce.event.KafkaTopics;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.util.Map;

@Service
public class LoginAttemptAuditService {
    static final int MAX_FAILED_ATTEMPTS = 5;
    static final int LOCKOUT_WINDOW_MINUTES = 15;

    private final JdbcTemplate jdbcTemplate;
    private final KafkaEventPublisher kafkaEventPublisher;
    private final AuditService auditService;

    public LoginAttemptAuditService(JdbcTemplate jdbcTemplate, KafkaEventPublisher kafkaEventPublisher, AuditService auditService) {
        this.jdbcTemplate = jdbcTemplate;
        this.kafkaEventPublisher = kafkaEventPublisher;
        this.auditService = auditService;
    }

    /**
     * Returns true if the given email has exceeded the failed-attempt threshold within the lockout window.
     * This provides brute-force / account-lockout protection without requiring a schema change.
     */
    public boolean isLockedOut(String email) {
        String normalizedEmail = email == null ? "" : email.trim().toLowerCase();
        Integer failedCount = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM login_attempts WHERE email = ? AND success = false " +
                "AND created_at > NOW() - (? * INTERVAL '1 minute')",
                Integer.class,
                normalizedEmail,
                LOCKOUT_WINDOW_MINUTES
        );
        return failedCount != null && failedCount >= MAX_FAILED_ATTEMPTS;
    }

    public void record(String email, boolean success, String failureCode) {
        String normalizedEmail = email == null ? "" : email.trim().toLowerCase();
        jdbcTemplate.update(
                "INSERT INTO login_attempts (email, success, failure_code) VALUES (?, ?, ?)",
                normalizedEmail,
                success,
                failureCode
        );
        auditService.record(
                success ? AuditAction.LOGIN_SUCCESS : AuditAction.LOGIN_FAILED,
                "auth",
                normalizedEmail,
                "email=" + maskEmail(normalizedEmail)
                        + "; success=" + success
                        + "; failureCode=" + (failureCode == null ? "" : failureCode)
        );

        kafkaEventPublisher.publish(
                KafkaTopics.AUDIT_SECURITY_EVENT,
                "auth-service",
                Map.of(
                        "event", "login_attempt",
                        "email", maskEmail(normalizedEmail),
                        "success", success,
                        "failureCode", failureCode == null ? "" : failureCode
                )
        );
    }

    private String maskEmail(String email) {
        int atIndex = email.indexOf('@');
        if (atIndex <= 1) {
            return "***" + (atIndex >= 0 ? email.substring(atIndex) : "");
        }
        return email.charAt(0) + "***" + email.substring(atIndex);
    }
}

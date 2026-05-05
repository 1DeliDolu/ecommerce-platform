package com.pehlione.ecommerce.security;

import com.pehlione.ecommerce.event.KafkaEventPublisher;
import com.pehlione.ecommerce.event.KafkaTopics;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.util.Map;

@Service
public class LoginAttemptAuditService {
    private final JdbcTemplate jdbcTemplate;
    private final KafkaEventPublisher kafkaEventPublisher;

    public LoginAttemptAuditService(JdbcTemplate jdbcTemplate, KafkaEventPublisher kafkaEventPublisher) {
        this.jdbcTemplate = jdbcTemplate;
        this.kafkaEventPublisher = kafkaEventPublisher;
    }

    public void record(String email, boolean success, String failureCode) {
        String normalizedEmail = email == null ? "" : email.trim().toLowerCase();
        jdbcTemplate.update(
                "INSERT INTO login_attempts (email, success, failure_code) VALUES (?, ?, ?)",
                normalizedEmail,
                success,
                failureCode
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

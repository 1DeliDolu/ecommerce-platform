package com.pehlione.ecommerce.security;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

@Service
public class LoginAttemptAuditService {
    private final JdbcTemplate jdbcTemplate;

    public LoginAttemptAuditService(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public void record(String email, boolean success, String failureCode) {
        jdbcTemplate.update(
                "INSERT INTO login_attempts (email, success, failure_code) VALUES (?, ?, ?)",
                email == null ? "" : email.trim().toLowerCase(),
                success,
                failureCode
        );
    }
}

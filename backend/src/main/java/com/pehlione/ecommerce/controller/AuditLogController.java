package com.pehlione.ecommerce.controller;

import com.pehlione.ecommerce.dto.audit.AuditLogResponse;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/audit/logs")
public class AuditLogController {
    private final JdbcTemplate jdbcTemplate;

    public AuditLogController(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @GetMapping
    public List<AuditLogResponse> findLatest() {
        return jdbcTemplate.query(
                """
                SELECT id, actor_email, action, resource_type, resource_id, details, created_at
                FROM audit_logs
                ORDER BY created_at DESC
                LIMIT 100
                """,
                (rs, rowNum) -> new AuditLogResponse(
                        rs.getLong("id"),
                        rs.getString("actor_email"),
                        rs.getString("action"),
                        rs.getString("resource_type"),
                        rs.getString("resource_id"),
                        rs.getString("details"),
                        rs.getObject("created_at", java.time.OffsetDateTime.class)
                )
        );
    }
}

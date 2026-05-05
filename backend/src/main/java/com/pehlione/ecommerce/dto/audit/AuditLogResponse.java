package com.pehlione.ecommerce.dto.audit;

import java.time.OffsetDateTime;

public record AuditLogResponse(
        Long id,
        String actorEmail,
        String action,
        String resourceType,
        String resourceId,
        String details,
        OffsetDateTime createdAt
) {}

package com.pehlione.ecommerce.event;

import java.time.Instant;
import java.util.Map;
import java.util.UUID;

public record EventEnvelope(
        String eventId,
        String eventType,
        Instant occurredAt,
        String source,
        String correlationId,
        Map<String, Object> payload
) {
    public static EventEnvelope of(String eventType, String source, Map<String, Object> payload) {
        return new EventEnvelope(
                UUID.randomUUID().toString(),
                eventType,
                Instant.now(),
                source,
                UUID.randomUUID().toString(),
                payload
        );
    }
}

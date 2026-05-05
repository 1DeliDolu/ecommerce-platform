package com.pehlione.ecommerce.queue;

import java.time.Instant;
import java.util.UUID;

public record MailTask(
        String taskId,
        String to,
        String subject,
        String htmlBody,
        Instant createdAt
) {
    public static MailTask html(String to, String subject, String htmlBody) {
        return new MailTask(UUID.randomUUID().toString(), to, subject, htmlBody, Instant.now());
    }
}

package com.pehlione.ecommerce.notification;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
public class NotificationMailService {
    private static final Logger LOGGER = LoggerFactory.getLogger(NotificationMailService.class);

    private final JavaMailSender mailSender;
    private final String from;

    public NotificationMailService(
            JavaMailSender mailSender,
            @Value("${app.mail.from:no-reply@enterprise-shop.local}") String from
    ) {
        this.mailSender = mailSender;
        this.from = from;
    }

    public void sendPlainTextMail(String to, String subject, String body) {
        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setFrom(from);
            message.setTo(to);
            message.setSubject(subject);
            message.setText(body);
            mailSender.send(message);
        } catch (Exception exception) {
            LOGGER.warn("Mail could not be sent to {} with subject '{}': {}", to, subject, exception.getMessage());
        }
    }
}

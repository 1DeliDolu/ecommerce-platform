package com.pehlione.ecommerce.notification;

import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ClassPathResource;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

import java.nio.charset.StandardCharsets;

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
        sendHtmlMail(to, subject, "<pre style=\"font-family:Arial,sans-serif\">" + escapeHtml(body) + "</pre>");
    }

    public void sendHtmlMail(String to, String subject, String html) {
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(
                    message,
                    true,
                    StandardCharsets.UTF_8.name()
            );
            helper.setFrom(from);
            helper.setTo(to);
            helper.setSubject(subject);
            helper.setText(html, true);
            mailSender.send(message);
        } catch (MessagingException exception) {
            LOGGER.warn("HTML mail could not be sent to {} with subject '{}': {}", to, subject, exception.getMessage());
        }
    }

    public String loadTemplate(String classpathLocation) {
        try {
            ClassPathResource resource = new ClassPathResource(classpathLocation);
            return new String(resource.getInputStream().readAllBytes(), StandardCharsets.UTF_8);
        } catch (Exception exception) {
            throw new IllegalStateException("Email template could not be loaded: " + classpathLocation, exception);
        }
    }

    public String replace(String template, String key, String value) {
        return template.replace("{{" + key + "}}", value == null ? "" : value);
    }

    private String escapeHtml(String input) {
        if (input == null) return "";
        return input
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;");
    }
}

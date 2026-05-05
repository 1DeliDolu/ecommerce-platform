package com.pehlione.ecommerce.queue;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.stereotype.Service;

@Service
public class MailTaskProducer {
    private static final Logger log = LoggerFactory.getLogger(MailTaskProducer.class);

    private final RabbitTemplate rabbitTemplate;

    public MailTaskProducer(RabbitTemplate rabbitTemplate) {
        this.rabbitTemplate = rabbitTemplate;
    }

    public void enqueueHtmlMail(String to, String subject, String htmlBody) {
        MailTask task = MailTask.html(to, subject, htmlBody);
        rabbitTemplate.convertAndSend(
                RabbitMqTopologyConfig.TASK_EXCHANGE,
                RabbitMqTopologyConfig.MAIL_SEND_ROUTING_KEY,
                task
        );
        log.info("Mail task queued: taskId={} to={}", task.taskId(), maskEmail(to));
    }

    private String maskEmail(String email) {
        if (email == null || email.isBlank()) {
            return "";
        }
        int atIndex = email.indexOf('@');
        if (atIndex <= 1) {
            return "***" + (atIndex >= 0 ? email.substring(atIndex) : "");
        }
        return email.charAt(0) + "***" + email.substring(atIndex);
    }
}

package com.pehlione.ecommerce.queue;

import com.pehlione.ecommerce.notification.NotificationMailService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.stereotype.Component;

@Component
public class MailTaskConsumer {
    private static final Logger log = LoggerFactory.getLogger(MailTaskConsumer.class);

    private final NotificationMailService notificationMailService;

    public MailTaskConsumer(NotificationMailService notificationMailService) {
        this.notificationMailService = notificationMailService;
    }

    @RabbitListener(queues = RabbitMqTopologyConfig.MAIL_SEND_QUEUE)
    public void consume(MailTask task) {
        notificationMailService.sendHtmlMail(task.to(), task.subject(), task.htmlBody());
        log.info("Mail task processed: taskId={}", task.taskId());
    }
}

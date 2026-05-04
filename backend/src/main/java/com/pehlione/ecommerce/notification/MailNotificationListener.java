package com.pehlione.ecommerce.notification;

import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

@Component
public class MailNotificationListener {
    private final NotificationMailService notificationMailService;

    public MailNotificationListener(NotificationMailService notificationMailService) {
        this.notificationMailService = notificationMailService;
    }

    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT, fallbackExecution = true)
    public void onMailNotification(MailNotificationEvent event) {
        notificationMailService.sendPlainTextMail(event.getTo(), event.getSubject(), event.getBody());
    }
}

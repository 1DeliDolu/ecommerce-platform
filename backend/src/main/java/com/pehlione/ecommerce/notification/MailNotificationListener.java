package com.pehlione.ecommerce.notification;

import com.pehlione.ecommerce.queue.MailTaskProducer;
import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

@Component
public class MailNotificationListener {
    private final MailTaskProducer mailTaskProducer;

    public MailNotificationListener(MailTaskProducer mailTaskProducer) {
        this.mailTaskProducer = mailTaskProducer;
    }

    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT, fallbackExecution = true)
    public void onMailNotification(MailNotificationEvent event) {
        mailTaskProducer.enqueueHtmlMail(event.getTo(), event.getSubject(), event.getBody());
    }
}

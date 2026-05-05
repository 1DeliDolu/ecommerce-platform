package com.pehlione.ecommerce.event;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;

@Component
public class KafkaEventConsumer {
    private static final Logger log = LoggerFactory.getLogger(KafkaEventConsumer.class);

    @KafkaListener(topics = {
            KafkaTopics.USER_REGISTERED,
            KafkaTopics.ORDER_CREATED,
            KafkaTopics.PAYMENT_COMPLETED,
            KafkaTopics.PAYMENT_FAILED,
            KafkaTopics.INVENTORY_UPDATED,
            KafkaTopics.AUDIT_SECURITY_EVENT
    })
    public void consume(EventEnvelope envelope) {
        log.info(
                "Kafka event consumed: eventType={} eventId={} source={} correlationId={}",
                envelope.eventType(),
                envelope.eventId(),
                envelope.source(),
                envelope.correlationId()
        );
    }
}

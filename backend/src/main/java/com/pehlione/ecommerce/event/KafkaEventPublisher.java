package com.pehlione.ecommerce.event;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

import java.util.Map;

@Service
public class KafkaEventPublisher {
    private static final Logger log = LoggerFactory.getLogger(KafkaEventPublisher.class);

    private final KafkaTemplate<String, EventEnvelope> kafkaTemplate;

    public KafkaEventPublisher(KafkaTemplate<String, EventEnvelope> kafkaTemplate) {
        this.kafkaTemplate = kafkaTemplate;
    }

    public void publish(String topic, String source, Map<String, Object> payload) {
        EventEnvelope envelope = EventEnvelope.of(topic, source, payload);
        kafkaTemplate.send(topic, envelope.eventId(), envelope)
                .whenComplete((result, exception) -> {
                    if (exception != null) {
                        log.warn("Kafka publish failed for topic {} event {}", topic, envelope.eventId(), exception);
                        return;
                    }
                    log.info("Kafka event published: topic={} eventId={}", topic, envelope.eventId());
                });
    }
}

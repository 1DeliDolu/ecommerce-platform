package com.pehlione.ecommerce.config;

import com.pehlione.ecommerce.event.KafkaTopics;
import org.apache.kafka.clients.admin.NewTopic;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.kafka.annotation.EnableKafka;

@Configuration
@EnableKafka
public class KafkaTopicConfig {
    @Bean
    NewTopic userRegisteredTopic() {
        return new NewTopic(KafkaTopics.USER_REGISTERED, 3, (short) 1);
    }

    @Bean
    NewTopic orderCreatedTopic() {
        return new NewTopic(KafkaTopics.ORDER_CREATED, 3, (short) 1);
    }

    @Bean
    NewTopic paymentCompletedTopic() {
        return new NewTopic(KafkaTopics.PAYMENT_COMPLETED, 3, (short) 1);
    }

    @Bean
    NewTopic paymentFailedTopic() {
        return new NewTopic(KafkaTopics.PAYMENT_FAILED, 3, (short) 1);
    }

    @Bean
    NewTopic inventoryUpdatedTopic() {
        return new NewTopic(KafkaTopics.INVENTORY_UPDATED, 3, (short) 1);
    }

    @Bean
    NewTopic auditSecurityEventTopic() {
        return new NewTopic(KafkaTopics.AUDIT_SECURITY_EVENT, 3, (short) 1);
    }
}

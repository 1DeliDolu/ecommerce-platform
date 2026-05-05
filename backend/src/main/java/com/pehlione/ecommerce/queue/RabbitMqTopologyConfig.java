package com.pehlione.ecommerce.queue;

import org.springframework.amqp.core.Binding;
import org.springframework.amqp.core.BindingBuilder;
import org.springframework.amqp.core.DirectExchange;
import org.springframework.amqp.core.Queue;
import org.springframework.amqp.support.converter.Jackson2JsonMessageConverter;
import org.springframework.amqp.support.converter.MessageConverter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.Map;

@Configuration
public class RabbitMqTopologyConfig {
    public static final String TASK_EXCHANGE = "ecommerce.tasks";
    public static final String TASK_DLX = "ecommerce.tasks.dlx";
    public static final String MAIL_SEND_QUEUE = "mail.send";
    public static final String MAIL_SEND_DLQ = "mail.send.dlq";
    public static final String MAIL_SEND_ROUTING_KEY = "mail.send";

    @Bean
    DirectExchange taskExchange() {
        return new DirectExchange(TASK_EXCHANGE, true, false);
    }

    @Bean
    DirectExchange taskDeadLetterExchange() {
        return new DirectExchange(TASK_DLX, true, false);
    }

    @Bean
    Queue mailSendQueue() {
        return new Queue(
                MAIL_SEND_QUEUE,
                true,
                false,
                false,
                Map.of(
                        "x-dead-letter-exchange", TASK_DLX,
                        "x-dead-letter-routing-key", MAIL_SEND_DLQ
                )
        );
    }

    @Bean
    Queue mailSendDeadLetterQueue() {
        return new Queue(MAIL_SEND_DLQ, true);
    }

    @Bean
    Binding mailSendBinding() {
        return BindingBuilder.bind(mailSendQueue()).to(taskExchange()).with(MAIL_SEND_ROUTING_KEY);
    }

    @Bean
    Binding mailSendDeadLetterBinding() {
        return BindingBuilder.bind(mailSendDeadLetterQueue()).to(taskDeadLetterExchange()).with(MAIL_SEND_DLQ);
    }

    @Bean
    MessageConverter messageConverter() {
        return new Jackson2JsonMessageConverter();
    }
}

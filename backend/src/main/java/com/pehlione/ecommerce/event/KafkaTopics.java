package com.pehlione.ecommerce.event;

public final class KafkaTopics {
    public static final String USER_REGISTERED = "user.registered";
    public static final String ORDER_CREATED = "order.created";
    public static final String PAYMENT_COMPLETED = "payment.completed";
    public static final String PAYMENT_FAILED = "payment.failed";
    public static final String INVENTORY_UPDATED = "inventory.updated";
    public static final String AUDIT_SECURITY_EVENT = "audit.security-event";

    private KafkaTopics() {
    }
}

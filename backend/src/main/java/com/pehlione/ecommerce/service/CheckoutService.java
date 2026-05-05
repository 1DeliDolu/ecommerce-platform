package com.pehlione.ecommerce.service;

import com.pehlione.ecommerce.audit.AuditAction;
import com.pehlione.ecommerce.audit.AuditService;
import com.pehlione.ecommerce.domain.*;
import com.pehlione.ecommerce.dto.customer.*;
import com.pehlione.ecommerce.event.KafkaEventPublisher;
import com.pehlione.ecommerce.event.KafkaTopics;
import com.pehlione.ecommerce.notification.MailNotificationEvent;
import com.pehlione.ecommerce.notification.NotificationTemplateService;
import com.pehlione.ecommerce.repository.CartItemRepository;
import com.pehlione.ecommerce.repository.CustomerOrderRepository;
import com.pehlione.ecommerce.repository.ProductRepository;
import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.MeterRegistry;
import jakarta.transaction.Transactional;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;

@Service
public class CheckoutService {

    private final CartItemRepository cartItemRepository;
    private final CustomerOrderRepository orderRepository;
    private final ProductRepository productRepository;
    private final ApplicationEventPublisher eventPublisher;
    private final NotificationTemplateService notificationTemplateService;
    private final KafkaEventPublisher kafkaEventPublisher;
    private final AuditService auditService;
    private final Counter orderCreatedCounter;
    private final Counter paymentFailureCounter;

    public CheckoutService(CartItemRepository cartItemRepository,
                           CustomerOrderRepository orderRepository,
                           ProductRepository productRepository,
                           ApplicationEventPublisher eventPublisher,
                           NotificationTemplateService notificationTemplateService,
                           KafkaEventPublisher kafkaEventPublisher,
                           AuditService auditService,
                           MeterRegistry meterRegistry) {
        this.cartItemRepository = cartItemRepository;
        this.orderRepository = orderRepository;
        this.productRepository = productRepository;
        this.eventPublisher = eventPublisher;
        this.notificationTemplateService = notificationTemplateService;
        this.kafkaEventPublisher = kafkaEventPublisher;
        this.auditService = auditService;
        this.orderCreatedCounter = Counter.builder("ecommerce.orders.created")
                .description("Total orders placed")
                .register(meterRegistry);
        this.paymentFailureCounter = Counter.builder("ecommerce.orders.payment_failures")
                .description("Simulated payment failures")
                .register(meterRegistry);
    }

    @Transactional
    public OrderResponse checkout(String userEmail, CheckoutRequest request) {
        validateCheckoutRequest(request);

        List<CartItem> cartItems = cartItemRepository.findByUserEmailOrderByCreatedAtDesc(userEmail);

        if (cartItems.isEmpty()) throw new IllegalArgumentException("Cart is empty.");

        for (CartItem cartItem : cartItems) {
            if (cartItem.getQuantity() > cartItem.getProduct().getStockQuantity())
                throw new IllegalArgumentException("Not enough stock for product: " + cartItem.getProduct().getName());
        }

        BigDecimal subtotal = cartItems.stream()
                .map(item -> item.getProduct().getPrice().multiply(BigDecimal.valueOf(item.getQuantity())))
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        BigDecimal shippingCost = subtotal.compareTo(BigDecimal.valueOf(500)) > 0
                ? BigDecimal.ZERO : BigDecimal.valueOf(49.90);

        BigDecimal tax = subtotal.multiply(BigDecimal.valueOf(0.18));
        BigDecimal totalAmount = subtotal.add(shippingCost).add(tax);

        CustomerOrder order = new CustomerOrder();
        order.setOrderNumber(generateOrderNumber());
        order.setUserEmail(userEmail);
        order.setStatus(CustomerOrder.OrderStatus.PAID);
        order.setSubtotal(subtotal);
        order.setShippingCost(shippingCost);
        order.setTax(tax);
        order.setTotalAmount(totalAmount);
        order.setPaymentMethod("CARD");
        order.setPaymentReference(processPayment(userEmail, request.getPayment(), totalAmount));

        ShippingAddressRequest shipping = request.getShippingAddress();
        order.setShippingFullName(shipping.getFullName());
        order.setShippingEmail(shipping.getEmail());
        order.setShippingPhone(shipping.getPhone());
        order.setShippingStreet(shipping.getStreet());
        order.setShippingCity(shipping.getCity());
        order.setShippingPostalCode(shipping.getPostalCode());
        order.setShippingCountry(shipping.getCountry());

        for (CartItem cartItem : cartItems) {
            Product product = cartItem.getProduct();
            product.setStockQuantity(product.getStockQuantity() - cartItem.getQuantity());
            productRepository.save(product);
            order.getItems().add(new CustomerOrderItem(order, product, cartItem.getQuantity()));
        }

        CustomerOrder savedOrder = orderRepository.save(order);
        auditService.record(
                AuditAction.ORDER_CREATED,
                "order",
                savedOrder.getId().toString(),
                "orderNumber=" + savedOrder.getOrderNumber() + "; totalAmount=" + savedOrder.getTotalAmount()
        );
        cartItemRepository.deleteByUserEmail(userEmail);
        orderCreatedCounter.increment();

        eventPublisher.publishEvent(new MailNotificationEvent(
                savedOrder.getShippingEmail(),
                "Order Confirmation - " + savedOrder.getOrderNumber(),
                notificationTemplateService.orderConfirmationHtml(savedOrder)
        ));
        kafkaEventPublisher.publish(
                KafkaTopics.ORDER_CREATED,
                "order-service",
                Map.of(
                        "orderId", savedOrder.getId(),
                        "orderNumber", savedOrder.getOrderNumber(),
                        "userEmail", savedOrder.getUserEmail(),
                        "status", savedOrder.getStatus().name(),
                        "totalAmount", savedOrder.getTotalAmount(),
                        "itemCount", savedOrder.getItems().size()
                )
        );
        kafkaEventPublisher.publish(
                KafkaTopics.PAYMENT_COMPLETED,
                "payment-service",
                Map.of(
                        "orderId", savedOrder.getId(),
                        "paymentReference", savedOrder.getPaymentReference(),
                        "amount", savedOrder.getTotalAmount(),
                        "method", savedOrder.getPaymentMethod()
                )
        );

        return new OrderResponse(savedOrder);
    }

    @Transactional
    public List<OrderResponse> findMyOrders(String userEmail) {
        return orderRepository.findByUserEmailOrderByCreatedAtDesc(userEmail)
                .stream()
                .map(OrderResponse::new)
                .toList();
    }

    private void validateCheckoutRequest(CheckoutRequest request) {
        if (request == null) throw new IllegalArgumentException("Checkout request is required.");
        if (request.getShippingAddress() == null) throw new IllegalArgumentException("Shipping address is required.");
        if (request.getPayment() == null) throw new IllegalArgumentException("Payment information is required.");

        ShippingAddressRequest shipping = request.getShippingAddress();
        if (isBlank(shipping.getFullName()) || isBlank(shipping.getEmail()) || isBlank(shipping.getPhone())
                || isBlank(shipping.getStreet()) || isBlank(shipping.getCity())
                || isBlank(shipping.getPostalCode()) || isBlank(shipping.getCountry()))
            throw new IllegalArgumentException("All shipping address fields are required.");

        PaymentRequest payment = request.getPayment();
        if (isBlank(payment.getCardHolder()) || isBlank(payment.getCardNumber())
                || isBlank(payment.getExpiry()) || isBlank(payment.getCvv()))
            throw new IllegalArgumentException("All payment fields are required.");
    }

    private String processPayment(String userEmail, PaymentRequest payment, BigDecimal totalAmount) {
        String normalizedCardNumber = payment.getCardNumber().replaceAll("\\s+", "");
        String last4 = last4(normalizedCardNumber);
        if ("0000".equals(last4)) {
            paymentFailureCounter.increment();
            auditService.record(
                    AuditAction.PAYMENT_FAILED,
                    "payment",
                    null,
                    "user=" + maskEmail(userEmail) + "; amount=" + totalAmount + "; cardLast4=" + last4
            );
            kafkaEventPublisher.publish(
                    KafkaTopics.PAYMENT_FAILED,
                    "payment-service",
                    Map.of(
                            "amount", totalAmount,
                            "method", "CARD",
                            "cardLast4", last4,
                            "reason", "SIMULATED_DECLINE"
                    )
            );
            throw new IllegalArgumentException("Payment was declined.");
        }

        return "PAY-SIM-" + last4 + "-" + System.currentTimeMillis();
    }

    private String last4(String cardNumber) {
        return cardNumber.length() >= 4 ? cardNumber.substring(cardNumber.length() - 4) : "0000";
    }

    private String generateOrderNumber() {
        String ts = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));
        return "ORD-" + ts + "-" + System.currentTimeMillis();
    }

    private boolean isBlank(String v) { return v == null || v.trim().isEmpty(); }

    private String maskEmail(String email) {
        if (email == null || email.isBlank()) {
            return "unknown";
        }
        int at = email.indexOf('@');
        if (at <= 1) {
            return "***" + email.substring(Math.max(at, 0));
        }
        return email.charAt(0) + "***" + email.substring(at);
    }
}

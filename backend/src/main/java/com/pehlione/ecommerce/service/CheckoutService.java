package com.pehlione.ecommerce.service;

import com.pehlione.ecommerce.domain.*;
import com.pehlione.ecommerce.dto.customer.*;
import com.pehlione.ecommerce.notification.MailNotificationEvent;
import com.pehlione.ecommerce.repository.CartItemRepository;
import com.pehlione.ecommerce.repository.CustomerOrderRepository;
import com.pehlione.ecommerce.repository.ProductRepository;
import jakarta.transaction.Transactional;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

@Service
public class CheckoutService {

    private final CartItemRepository cartItemRepository;
    private final CustomerOrderRepository orderRepository;
    private final ProductRepository productRepository;
    private final ApplicationEventPublisher eventPublisher;

    public CheckoutService(CartItemRepository cartItemRepository,
                           CustomerOrderRepository orderRepository,
                           ProductRepository productRepository,
                           ApplicationEventPublisher eventPublisher) {
        this.cartItemRepository = cartItemRepository;
        this.orderRepository = orderRepository;
        this.productRepository = productRepository;
        this.eventPublisher = eventPublisher;
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
        order.setPaymentReference(simulatePayment(request.getPayment()));

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
        cartItemRepository.deleteByUserEmail(userEmail);

        eventPublisher.publishEvent(new MailNotificationEvent(
                savedOrder.getShippingEmail(),
                "Order Confirmation - " + savedOrder.getOrderNumber(),
                """
                        Hello %s,

                        Your order has been completed successfully.

                        Order Number: %s
                        Status: %s
                        Total Amount: €%s

                        Thank you for shopping with Enterprise Shop.

                        Regards,
                        Enterprise Shop Team
                        """.formatted(
                        savedOrder.getShippingFullName(),
                        savedOrder.getOrderNumber(),
                        savedOrder.getStatus().name(),
                        savedOrder.getTotalAmount()
                )
        ));

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

    private String simulatePayment(PaymentRequest payment) {
        String last4 = payment.getCardNumber().replaceAll("\\s+", "");
        last4 = last4.length() >= 4 ? last4.substring(last4.length() - 4) : "0000";
        return "PAY-SIM-" + last4 + "-" + System.currentTimeMillis();
    }

    private String generateOrderNumber() {
        String ts = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));
        return "ORD-" + ts + "-" + System.currentTimeMillis();
    }

    private boolean isBlank(String v) { return v == null || v.trim().isEmpty(); }
}

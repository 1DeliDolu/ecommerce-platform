package com.pehlione.ecommerce.dto.customer;

import com.pehlione.ecommerce.domain.CustomerOrder;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

public class OrderResponse {

    private Long id;
    private String orderNumber;
    private String status;
    private BigDecimal subtotal;
    private BigDecimal shippingCost;
    private BigDecimal tax;
    private BigDecimal totalAmount;
    private String shippingFullName;
    private String shippingEmail;
    private String shippingCity;
    private String shippingCountry;
    private String paymentMethod;
    private String paymentReference;
    private LocalDateTime createdAt;
    private List<OrderItemResponse> items;

    public OrderResponse(CustomerOrder order) {
        this.id = order.getId();
        this.orderNumber = order.getOrderNumber();
        this.status = order.getStatus().name();
        this.subtotal = order.getSubtotal();
        this.shippingCost = order.getShippingCost();
        this.tax = order.getTax();
        this.totalAmount = order.getTotalAmount();
        this.shippingFullName = order.getShippingFullName();
        this.shippingEmail = order.getShippingEmail();
        this.shippingCity = order.getShippingCity();
        this.shippingCountry = order.getShippingCountry();
        this.paymentMethod = order.getPaymentMethod();
        this.paymentReference = order.getPaymentReference();
        this.createdAt = order.getCreatedAt();
        this.items = order.getItems().stream().map(OrderItemResponse::new).toList();
    }

    public Long getId() { return id; }
    public String getOrderNumber() { return orderNumber; }
    public String getStatus() { return status; }
    public BigDecimal getSubtotal() { return subtotal; }
    public BigDecimal getShippingCost() { return shippingCost; }
    public BigDecimal getTax() { return tax; }
    public BigDecimal getTotalAmount() { return totalAmount; }
    public String getShippingFullName() { return shippingFullName; }
    public String getShippingEmail() { return shippingEmail; }
    public String getShippingCity() { return shippingCity; }
    public String getShippingCountry() { return shippingCountry; }
    public String getPaymentMethod() { return paymentMethod; }
    public String getPaymentReference() { return paymentReference; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public List<OrderItemResponse> getItems() { return items; }
}

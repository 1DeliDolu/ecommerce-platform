package com.pehlione.ecommerce.domain;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "customer_orders")
public class CustomerOrder {

    public enum OrderStatus {
        CREATED, PAID, PAYMENT_FAILED, CANCELLED, SHIPPED, DELIVERED
    }

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String orderNumber;

    @Column(nullable = false)
    private String userEmail;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private OrderStatus status = OrderStatus.CREATED;

    @Column(nullable = false, precision = 12, scale = 2)
    private BigDecimal subtotal;

    @Column(nullable = false, precision = 12, scale = 2)
    private BigDecimal shippingCost;

    @Column(nullable = false, precision = 12, scale = 2)
    private BigDecimal tax;

    @Column(nullable = false, precision = 12, scale = 2)
    private BigDecimal totalAmount;

    @Column(nullable = false)
    private String shippingFullName;

    @Column(nullable = false)
    private String shippingEmail;

    @Column(nullable = false)
    private String shippingPhone;

    @Column(nullable = false)
    private String shippingStreet;

    @Column(nullable = false)
    private String shippingCity;

    @Column(nullable = false)
    private String shippingPostalCode;

    @Column(nullable = false)
    private String shippingCountry;

    @Column(nullable = false)
    private String paymentMethod;

    @Column(nullable = false)
    private String paymentReference;

    @Column(nullable = false)
    private LocalDateTime createdAt = LocalDateTime.now();

    @OneToMany(mappedBy = "order", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<CustomerOrderItem> items = new ArrayList<>();

    public CustomerOrder() {}

    public Long getId() { return id; }
    public String getOrderNumber() { return orderNumber; }
    public String getUserEmail() { return userEmail; }
    public OrderStatus getStatus() { return status; }
    public BigDecimal getSubtotal() { return subtotal; }
    public BigDecimal getShippingCost() { return shippingCost; }
    public BigDecimal getTax() { return tax; }
    public BigDecimal getTotalAmount() { return totalAmount; }
    public String getShippingFullName() { return shippingFullName; }
    public String getShippingEmail() { return shippingEmail; }
    public String getShippingPhone() { return shippingPhone; }
    public String getShippingStreet() { return shippingStreet; }
    public String getShippingCity() { return shippingCity; }
    public String getShippingPostalCode() { return shippingPostalCode; }
    public String getShippingCountry() { return shippingCountry; }
    public String getPaymentMethod() { return paymentMethod; }
    public String getPaymentReference() { return paymentReference; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public List<CustomerOrderItem> getItems() { return items; }

    public void setOrderNumber(String orderNumber) { this.orderNumber = orderNumber; }
    public void setUserEmail(String userEmail) { this.userEmail = userEmail; }
    public void setStatus(OrderStatus status) { this.status = status; }
    public void setSubtotal(BigDecimal subtotal) { this.subtotal = subtotal; }
    public void setShippingCost(BigDecimal shippingCost) { this.shippingCost = shippingCost; }
    public void setTax(BigDecimal tax) { this.tax = tax; }
    public void setTotalAmount(BigDecimal totalAmount) { this.totalAmount = totalAmount; }
    public void setShippingFullName(String v) { this.shippingFullName = v; }
    public void setShippingEmail(String v) { this.shippingEmail = v; }
    public void setShippingPhone(String v) { this.shippingPhone = v; }
    public void setShippingStreet(String v) { this.shippingStreet = v; }
    public void setShippingCity(String v) { this.shippingCity = v; }
    public void setShippingPostalCode(String v) { this.shippingPostalCode = v; }
    public void setShippingCountry(String v) { this.shippingCountry = v; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }
    public void setPaymentReference(String paymentReference) { this.paymentReference = paymentReference; }
    public void setItems(List<CustomerOrderItem> items) { this.items = items; }
}

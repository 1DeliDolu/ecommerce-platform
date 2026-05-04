package com.pehlione.ecommerce.dto.customer;

import com.pehlione.ecommerce.domain.CustomerOrderItem;
import java.math.BigDecimal;

public class OrderItemResponse {

    private Long id;
    private Long productId;
    private String productName;
    private String productSlug;
    private BigDecimal unitPrice;
    private int quantity;
    private BigDecimal lineTotal;

    public OrderItemResponse(CustomerOrderItem item) {
        this.id = item.getId();
        this.productId = item.getProduct().getId();
        this.productName = item.getProductName();
        this.productSlug = item.getProductSlug();
        this.unitPrice = item.getUnitPrice();
        this.quantity = item.getQuantity();
        this.lineTotal = item.getLineTotal();
    }

    public Long getId() { return id; }
    public Long getProductId() { return productId; }
    public String getProductName() { return productName; }
    public String getProductSlug() { return productSlug; }
    public BigDecimal getUnitPrice() { return unitPrice; }
    public int getQuantity() { return quantity; }
    public BigDecimal getLineTotal() { return lineTotal; }
}

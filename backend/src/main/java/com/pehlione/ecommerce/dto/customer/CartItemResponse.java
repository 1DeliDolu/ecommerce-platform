package com.pehlione.ecommerce.dto.customer;

import com.pehlione.ecommerce.domain.CartItem;
import com.pehlione.ecommerce.dto.product.ProductResponse;
import java.math.BigDecimal;

public class CartItemResponse {

    private Long id;
    private ProductResponse product;
    private int quantity;
    private BigDecimal lineTotal;

    public CartItemResponse(CartItem item) {
        this.id = item.getId();
        this.product = new ProductResponse(item.getProduct());
        this.quantity = item.getQuantity();
        this.lineTotal = item.getProduct().getPrice().multiply(BigDecimal.valueOf(item.getQuantity()));
    }

    public Long getId() { return id; }
    public ProductResponse getProduct() { return product; }
    public int getQuantity() { return quantity; }
    public BigDecimal getLineTotal() { return lineTotal; }
}

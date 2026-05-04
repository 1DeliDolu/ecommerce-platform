package com.pehlione.ecommerce.dto.customer;

import java.math.BigDecimal;
import java.util.List;

public class CartResponse {

    private List<CartItemResponse> items;
    private int itemCount;
    private BigDecimal subtotal;

    public CartResponse(List<CartItemResponse> items) {
        this.items = items;
        this.itemCount = items.stream().mapToInt(CartItemResponse::getQuantity).sum();
        this.subtotal = items.stream()
                .map(CartItemResponse::getLineTotal)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    public List<CartItemResponse> getItems() { return items; }
    public int getItemCount() { return itemCount; }
    public BigDecimal getSubtotal() { return subtotal; }
}

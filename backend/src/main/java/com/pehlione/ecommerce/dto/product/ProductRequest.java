package com.pehlione.ecommerce.dto.product;

import com.pehlione.ecommerce.domain.Product;
import java.math.BigDecimal;

public class ProductRequest {

    private Long categoryId;
    private String name;
    private String slug;
    private String description;
    private BigDecimal price;
    private int stockQuantity;
    private Product.ProductStatus status;

    public Long getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(Long categoryId) {
        this.categoryId = categoryId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getSlug() {
        return slug;
    }

    public void setSlug(String slug) {
        this.slug = slug;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public BigDecimal getPrice() {
        return price;
    }

    public void setPrice(BigDecimal price) {
        this.price = price;
    }

    public int getStockQuantity() {
        return stockQuantity;
    }

    public void setStockQuantity(int stockQuantity) {
        this.stockQuantity = stockQuantity;
    }

    public Product.ProductStatus getStatus() {
        return status;
    }

    public void setStatus(Product.ProductStatus status) {
        this.status = status;
    }
}

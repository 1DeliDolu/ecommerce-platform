package com.pehlione.ecommerce.dto.product;

import com.pehlione.ecommerce.domain.Product;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

public class ProductResponse {

    private Long id;
    private Long categoryId;
    private String categoryName;
    private String categorySlug;
    private String name;
    private String slug;
    private String description;
    private BigDecimal price;
    private int stockQuantity;
    private Product.ProductStatus status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private List<ProductImageResponse> images;

    public ProductResponse(Product product) {
        this.id = product.getId();
        this.categoryId = product.getCategory().getId();
        this.categoryName = product.getCategory().getName();
        this.categorySlug = product.getCategory().getSlug();
        this.name = product.getName();
        this.slug = product.getSlug();
        this.description = product.getDescription();
        this.price = product.getPrice();
        this.stockQuantity = product.getStockQuantity();
        this.status = product.getStatus();
        this.createdAt = product.getCreatedAt();
        this.updatedAt = product.getUpdatedAt();
        this.images = product.getImages()
                .stream()
                .map(ProductImageResponse::new)
                .toList();
    }

    public Long getId() {
        return id;
    }

    public Long getCategoryId() {
        return categoryId;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public String getCategorySlug() {
        return categorySlug;
    }

    public String getName() {
        return name;
    }

    public String getSlug() {
        return slug;
    }

    public String getDescription() {
        return description;
    }

    public BigDecimal getPrice() {
        return price;
    }

    public int getStockQuantity() {
        return stockQuantity;
    }

    public Product.ProductStatus getStatus() {
        return status;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public List<ProductImageResponse> getImages() {
        return images;
    }
}

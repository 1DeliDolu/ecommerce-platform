package com.pehlione.ecommerce.dto.category;

import com.pehlione.ecommerce.domain.Category;

import java.time.LocalDate;

public class CategoryResponse {
    private final Long id;
    private final String name;
    private final String slug;
    private final String description;
    private final int productCount;
    private final Category.CategoryStatus status;
    private final LocalDate createdAt;

    public CategoryResponse(Category category) {
        this.id = category.getId();
        this.name = category.getName();
        this.slug = category.getSlug();
        this.description = category.getDescription();
        this.productCount = category.getProductCount();
        this.status = category.getStatus();
        this.createdAt = category.getCreatedAt();
    }

    public Long getId() {
        return id;
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

    public int getProductCount() {
        return productCount;
    }

    public Category.CategoryStatus getStatus() {
        return status;
    }

    public LocalDate getCreatedAt() {
        return createdAt;
    }
}

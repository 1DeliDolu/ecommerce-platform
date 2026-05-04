package com.pehlione.ecommerce.dto.category;

import com.pehlione.ecommerce.domain.Category;

public class CategoryRequest {
    private String name;
    private String slug;
    private String description;
    private Category.CategoryStatus status;

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

    public Category.CategoryStatus getStatus() {
        return status;
    }

    public void setStatus(Category.CategoryStatus status) {
        this.status = status;
    }
}

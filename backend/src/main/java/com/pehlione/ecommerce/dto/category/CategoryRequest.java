package com.pehlione.ecommerce.dto.category;

import com.pehlione.ecommerce.domain.Category;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class CategoryRequest {
    @NotBlank
    @Size(max = 120)
    private String name;

    @NotBlank
    @Size(max = 140)
    private String slug;

    @Size(max = 1000)
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

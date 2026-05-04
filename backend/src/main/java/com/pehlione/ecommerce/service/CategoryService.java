package com.pehlione.ecommerce.service;

import com.pehlione.ecommerce.domain.Category;
import com.pehlione.ecommerce.dto.category.CategoryRequest;
import com.pehlione.ecommerce.dto.category.CategoryResponse;
import com.pehlione.ecommerce.repository.CategoryRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Transactional
public class CategoryService {
    private final CategoryRepository categoryRepository;

    public CategoryService(CategoryRepository categoryRepository) {
        this.categoryRepository = categoryRepository;
    }

    @Transactional(readOnly = true)
    public List<CategoryResponse> findAll() {
        return categoryRepository.findAll()
                .stream()
                .map(CategoryResponse::new)
                .toList();
    }

    @Transactional(readOnly = true)
    public CategoryResponse findById(Long id) {
        return new CategoryResponse(getCategoryOrThrow(id));
    }

    public CategoryResponse create(CategoryRequest request) {
        validateCreateRequest(request);

        Category category = new Category(
                request.getName().trim(),
                normalizeSlug(request.getSlug()),
                normalizeDescription(request.getDescription()),
                normalizeStatus(request.getStatus())
        );

        return new CategoryResponse(categoryRepository.save(category));
    }

    public CategoryResponse update(Long id, CategoryRequest request) {
        Category category = getCategoryOrThrow(id);
        validateUpdateRequest(id, request);

        category.setName(request.getName().trim());
        category.setSlug(normalizeSlug(request.getSlug()));
        category.setDescription(normalizeDescription(request.getDescription()));
        category.setStatus(normalizeStatus(request.getStatus()));

        return new CategoryResponse(categoryRepository.save(category));
    }

    public void delete(Long id) {
        Category category = getCategoryOrThrow(id);

        if (category.getProductCount() > 0) {
            throw new IllegalStateException("Category has products and cannot be deleted.");
        }

        categoryRepository.delete(category);
    }

    private Category getCategoryOrThrow(Long id) {
        return categoryRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Category not found: " + id));
    }

    private void validateCreateRequest(CategoryRequest request) {
        validateRequiredFields(request);

        if (categoryRepository.existsByNameIgnoreCase(request.getName().trim())) {
            throw new IllegalArgumentException("Category name already exists.");
        }

        if (categoryRepository.existsBySlug(normalizeSlug(request.getSlug()))) {
            throw new IllegalArgumentException("Category slug already exists.");
        }
    }

    private void validateUpdateRequest(Long id, CategoryRequest request) {
        validateRequiredFields(request);

        String name = request.getName().trim();
        String slug = normalizeSlug(request.getSlug());
        categoryRepository.findAll().forEach(category -> {
            if (!category.getId().equals(id) && category.getName().equalsIgnoreCase(name)) {
                throw new IllegalArgumentException("Category name already exists.");
            }

            if (!category.getId().equals(id) && category.getSlug().equals(slug)) {
                throw new IllegalArgumentException("Category slug already exists.");
            }
        });
    }

    private void validateRequiredFields(CategoryRequest request) {
        if (request.getName() == null || request.getName().trim().isEmpty()) {
            throw new IllegalArgumentException("Category name is required.");
        }

        if (request.getSlug() == null || request.getSlug().trim().isEmpty()) {
            throw new IllegalArgumentException("Category slug is required.");
        }
    }

    private Category.CategoryStatus normalizeStatus(Category.CategoryStatus status) {
        return status == null ? Category.CategoryStatus.ACTIVE : status;
    }

    private String normalizeDescription(String description) {
        return description == null ? "" : description.trim();
    }

    private String normalizeSlug(String slug) {
        return slug.trim().toLowerCase();
    }
}

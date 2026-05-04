package com.pehlione.ecommerce.service;

import com.pehlione.ecommerce.domain.Category;
import com.pehlione.ecommerce.dto.category.CategoryRequest;
import com.pehlione.ecommerce.dto.category.CategoryResponse;
import com.pehlione.ecommerce.notification.MailNotificationEvent;
import com.pehlione.ecommerce.repository.CategoryRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Transactional
public class CategoryService {
    private final CategoryRepository categoryRepository;
    private final ApplicationEventPublisher eventPublisher;
    private final String adminMailTo;

    public CategoryService(
            CategoryRepository categoryRepository,
            ApplicationEventPublisher eventPublisher,
            @Value("${app.mail.admin-to:admin@example.com}") String adminMailTo
    ) {
        this.categoryRepository = categoryRepository;
        this.eventPublisher = eventPublisher;
        this.adminMailTo = adminMailTo;
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

        Category saved = categoryRepository.save(category);
        publishCategoryMail("Category Created - " + saved.getName(), """
                A new category has been created.

                Category: %s
                Slug: %s
                Status: %s
                """.formatted(saved.getName(), saved.getSlug(), saved.getStatus().name()));

        return new CategoryResponse(saved);
    }

    public CategoryResponse update(Long id, CategoryRequest request) {
        Category category = getCategoryOrThrow(id);
        validateUpdateRequest(id, request);

        category.setName(request.getName().trim());
        category.setSlug(normalizeSlug(request.getSlug()));
        category.setDescription(normalizeDescription(request.getDescription()));
        category.setStatus(normalizeStatus(request.getStatus()));

        Category saved = categoryRepository.save(category);
        publishCategoryMail("Category Updated - " + saved.getName(), """
                A category has been updated.

                Category: %s
                Slug: %s
                Status: %s
                Product Count: %s
                """.formatted(
                saved.getName(),
                saved.getSlug(),
                saved.getStatus().name(),
                saved.getProductCount()
        ));

        return new CategoryResponse(saved);
    }

    public void delete(Long id) {
        Category category = getCategoryOrThrow(id);

        if (category.getProductCount() > 0) {
            throw new IllegalStateException("Category has products and cannot be deleted.");
        }

        String categoryName = category.getName();
        String categorySlug = category.getSlug();

        categoryRepository.delete(category);
        publishCategoryMail("Category Deleted - " + categoryName, """
                A category has been deleted.

                Category: %s
                Slug: %s
                """.formatted(categoryName, categorySlug));
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

    private void publishCategoryMail(String subject, String body) {
        eventPublisher.publishEvent(new MailNotificationEvent(adminMailTo, subject, body));
    }
}

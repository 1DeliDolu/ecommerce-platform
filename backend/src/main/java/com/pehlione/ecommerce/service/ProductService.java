package com.pehlione.ecommerce.service;

import com.pehlione.ecommerce.audit.AuditAction;
import com.pehlione.ecommerce.audit.AuditService;
import com.pehlione.ecommerce.domain.Category;
import com.pehlione.ecommerce.domain.Product;
import com.pehlione.ecommerce.dto.PagedResponse;
import com.pehlione.ecommerce.dto.product.ProductRequest;
import com.pehlione.ecommerce.dto.product.ProductResponse;
import com.pehlione.ecommerce.dto.product.ProductSearchParams;
import com.pehlione.ecommerce.notification.MailNotificationEvent;
import com.pehlione.ecommerce.repository.CategoryRepository;
import com.pehlione.ecommerce.repository.ProductRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;

@Service
@Transactional
public class ProductService {

    private final ProductRepository productRepository;
    private final CategoryRepository categoryRepository;
    private final ApplicationEventPublisher eventPublisher;
    private final AuditService auditService;
    private final String adminMailTo;

    public ProductService(
            ProductRepository productRepository,
            CategoryRepository categoryRepository,
            ApplicationEventPublisher eventPublisher,
            AuditService auditService,
            @Value("${app.mail.admin-to:admin@example.com}") String adminMailTo
    ) {
        this.productRepository = productRepository;
        this.categoryRepository = categoryRepository;
        this.eventPublisher = eventPublisher;
        this.auditService = auditService;
        this.adminMailTo = adminMailTo;
    }

    @Transactional(readOnly = true)
    public List<ProductResponse> findAll() {
        return productRepository.findAllWithCategoryAndImages()
                .stream()
                .map(ProductResponse::new)
                .toList();
    }

    @Transactional(readOnly = true)
    public ProductResponse findById(Long id) {
        Product product = getProductOrThrow(id);
        return new ProductResponse(product);
    }

    @Transactional(readOnly = true)
    public PagedResponse<ProductResponse> search(ProductSearchParams params) {
        Sort sort = "asc".equalsIgnoreCase(params.getDirection())
                ? Sort.by(params.getSort()).ascending()
                : Sort.by(params.getSort()).descending();
        PageRequest pageable = PageRequest.of(params.getPage(), params.getSize(), sort);

        Page<ProductResponse> page = productRepository
                .searchProducts(
                        params.getSearch(),
                        params.getCategoryId(),
                        params.getMinPrice(),
                        params.getMaxPrice(),
                        params.getStatus(),
                        pageable)
                .map(ProductResponse::new);

        return new PagedResponse<>(page);
    }

    public ProductResponse create(ProductRequest request) {
        validateRequest(request);

        Category category = getCategoryOrThrow(request.getCategoryId());
        String slug = normalizeSlug(request.getSlug());

        if (productRepository.existsByCategoryIdAndSlug(category.getId(), slug)) {
            slug = slug + "-" + System.currentTimeMillis();
        }

        Product product = new Product(
                category,
                request.getName().trim(),
                slug,
                request.getDescription(),
                request.getPrice(),
                request.getStockQuantity(),
                request.getStatus() == null ? Product.ProductStatus.ACTIVE : request.getStatus()
        );

        Product saved = productRepository.save(product);
        auditService.record(
                AuditAction.PRODUCT_CREATED,
                "product",
                saved.getId().toString(),
                "name=" + saved.getName() + "; slug=" + saved.getSlug()
        );
        category.setProductCount(category.getProductCount() + 1);
        categoryRepository.save(category);

        publishProductMail("Product Created - " + saved.getName(), """
                A new product has been created.

                Product: %s
                Category: %s
                Price: €%s
                Stock: %s
                Slug: %s
                """.formatted(
                saved.getName(),
                saved.getCategory().getName(),
                saved.getPrice(),
                saved.getStockQuantity(),
                saved.getSlug()
        ));

        return new ProductResponse(saved);
    }

    public ProductResponse update(Long id, ProductRequest request) {
        validateRequest(request);

        Product product = getProductOrThrow(id);
        Category oldCategory = product.getCategory();
        Category newCategory = getCategoryOrThrow(request.getCategoryId());

        String slug = normalizeSlug(request.getSlug());
        final String slugToCheck = slug;

        boolean slugUsedByAnother = productRepository.findAll()
                .stream()
                .anyMatch(item ->
                        !item.getId().equals(id)
                                && item.getCategory().getId().equals(newCategory.getId())
                                && item.getSlug().equals(slugToCheck)
                );

        if (slugUsedByAnother) {
            slug = slug + "-" + System.currentTimeMillis();
        }

        product.setCategory(newCategory);
        product.setName(request.getName().trim());
        product.setSlug(slug);
        product.setDescription(request.getDescription());
        product.setPrice(request.getPrice());
        product.setStockQuantity(request.getStockQuantity());
        product.setStatus(request.getStatus() == null ? Product.ProductStatus.ACTIVE : request.getStatus());

        Product saved = productRepository.save(product);

        if (!oldCategory.getId().equals(newCategory.getId())) {
            oldCategory.setProductCount(Math.max(0, oldCategory.getProductCount() - 1));
            newCategory.setProductCount(newCategory.getProductCount() + 1);
            categoryRepository.save(oldCategory);
            categoryRepository.save(newCategory);
        }

        publishProductMail("Product Updated - " + saved.getName(), """
                A product has been updated.

                Product: %s
                Category: %s
                Price: €%s
                Stock: %s
                Status: %s
                Slug: %s
                """.formatted(
                saved.getName(),
                saved.getCategory().getName(),
                saved.getPrice(),
                saved.getStockQuantity(),
                saved.getStatus().name(),
                saved.getSlug()
        ));

        return new ProductResponse(saved);
    }

    public void delete(Long id) {
        Product product = getProductOrThrow(id);
        Category category = product.getCategory();
        String productName = product.getName();
        String categoryName = category.getName();
        String slug = product.getSlug();

        productRepository.delete(product);

        category.setProductCount(Math.max(0, category.getProductCount() - 1));
        categoryRepository.save(category);

        publishProductMail("Product Deleted - " + productName, """
                A product has been deleted.

                Product: %s
                Category: %s
                Slug: %s
                """.formatted(productName, categoryName, slug));
    }

    public ProductResponse updateStatus(Long id, Product.ProductStatus status) {
        Product product = getProductOrThrow(id);
        product.setStatus(status);
        return new ProductResponse(productRepository.save(product));
    }

    public Product getProductOrThrow(Long id) {
        return productRepository.findByIdWithCategoryAndImages(id)
                .orElseThrow(() -> new IllegalArgumentException("Product not found: " + id));
    }

    private Category getCategoryOrThrow(Long id) {
        return categoryRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Category not found: " + id));
    }

    private void validateRequest(ProductRequest request) {
        if (request.getCategoryId() == null) {
            throw new IllegalArgumentException("Category is required.");
        }

        if (request.getName() == null || request.getName().trim().isEmpty()) {
            throw new IllegalArgumentException("Product name is required.");
        }

        if (request.getSlug() == null || request.getSlug().trim().isEmpty()) {
            throw new IllegalArgumentException("Product slug is required.");
        }

        if (request.getPrice() == null || request.getPrice().compareTo(BigDecimal.ZERO) < 0) {
            throw new IllegalArgumentException("Product price must be positive.");
        }

        if (request.getStockQuantity() < 0) {
            throw new IllegalArgumentException("Stock quantity cannot be negative.");
        }
    }

    private String normalizeSlug(String slug) {
        return slug.trim().toLowerCase();
    }

    private void publishProductMail(String subject, String body) {
        eventPublisher.publishEvent(new MailNotificationEvent(adminMailTo, subject, body));
    }
}

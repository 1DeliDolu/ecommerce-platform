package com.pehlione.ecommerce.service;

import com.pehlione.ecommerce.domain.Category;
import com.pehlione.ecommerce.domain.Product;
import com.pehlione.ecommerce.dto.product.ProductRequest;
import com.pehlione.ecommerce.dto.product.ProductResponse;
import com.pehlione.ecommerce.repository.CategoryRepository;
import com.pehlione.ecommerce.repository.ProductRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;

@Service
@Transactional
public class ProductService {

    private final ProductRepository productRepository;
    private final CategoryRepository categoryRepository;

    public ProductService(
            ProductRepository productRepository,
            CategoryRepository categoryRepository
    ) {
        this.productRepository = productRepository;
        this.categoryRepository = categoryRepository;
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
        category.setProductCount(category.getProductCount() + 1);
        categoryRepository.save(category);

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

        return new ProductResponse(saved);
    }

    public void delete(Long id) {
        Product product = getProductOrThrow(id);
        Category category = product.getCategory();

        productRepository.delete(product);

        category.setProductCount(Math.max(0, category.getProductCount() - 1));
        categoryRepository.save(category);
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
}

package com.pehlione.ecommerce.controller;

import com.pehlione.ecommerce.domain.Product;
import com.pehlione.ecommerce.dto.PagedResponse;
import com.pehlione.ecommerce.dto.product.ProductImageResponse;
import com.pehlione.ecommerce.dto.product.ProductRequest;
import com.pehlione.ecommerce.dto.product.ProductResponse;
import com.pehlione.ecommerce.dto.product.ProductSearchParams;
import com.pehlione.ecommerce.service.ProductImageService;
import com.pehlione.ecommerce.service.ProductService;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.math.BigDecimal;
import java.util.List;

@RestController
@RequestMapping("/api/admin/products")
public class ProductController {

    private final ProductService productService;
    private final ProductImageService productImageService;

    public ProductController(
            ProductService productService,
            ProductImageService productImageService
    ) {
        this.productService = productService;
        this.productImageService = productImageService;
    }

    @GetMapping
    public List<ProductResponse> findAll() {
        return productService.findAll();
    }

    @GetMapping("/search")
    public PagedResponse<ProductResponse> search(
            @RequestParam(required = false) String search,
            @RequestParam(required = false) Long categoryId,
            @RequestParam(required = false) BigDecimal minPrice,
            @RequestParam(required = false) BigDecimal maxPrice,
            @RequestParam(required = false) String status,
            @RequestParam(required = false, defaultValue = "0") int page,
            @RequestParam(required = false, defaultValue = "20") int size,
            @RequestParam(required = false, defaultValue = "id") String sort,
            @RequestParam(required = false, defaultValue = "desc") String direction
    ) {
        ProductSearchParams params = new ProductSearchParams();
        params.setSearch(search);
        params.setCategoryId(categoryId);
        params.setMinPrice(minPrice);
        params.setMaxPrice(maxPrice);
        params.setStatus(status == null || status.isBlank() ? null : Product.ProductStatus.valueOf(status.toUpperCase()));
        params.setPage(page);
        params.setSize(size);
        params.setSort(sort);
        params.setDirection(direction);
        return productService.search(params);
    }

    @GetMapping("/{id}")
    public ProductResponse findById(@PathVariable Long id) {
        return productService.findById(id);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public ProductResponse create(@RequestBody ProductRequest request) {
        return productService.create(request);
    }

    @PutMapping("/{id}")
    public ProductResponse update(
            @PathVariable Long id,
            @RequestBody ProductRequest request
    ) {
        return productService.update(id, request);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable Long id) {
        productService.delete(id);
    }

    @PatchMapping("/{id}/status")
    public ProductResponse toggleStatus(
            @PathVariable Long id,
            @RequestParam Product.ProductStatus status
    ) {
        return productService.updateStatus(id, status);
    }

    @PostMapping("/{id}/images")
    public List<ProductImageResponse> uploadImages(
            @PathVariable Long id,
            @RequestParam("files") MultipartFile[] files
    ) {
        return productImageService.uploadImages(id, files);
    }

    @DeleteMapping("/{productId}/images/{imageId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteImage(
            @PathVariable Long productId,
            @PathVariable Long imageId
    ) {
        productImageService.deleteImage(productId, imageId);
    }

    @PatchMapping("/{productId}/images/{imageId}/primary")
    public ProductImageResponse setPrimaryImage(
            @PathVariable Long productId,
            @PathVariable Long imageId
    ) {
        return productImageService.setPrimaryImage(productId, imageId);
    }
}

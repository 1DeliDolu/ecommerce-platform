package com.pehlione.ecommerce.controller;

import com.pehlione.ecommerce.domain.Product;
import com.pehlione.ecommerce.dto.PagedResponse;
import com.pehlione.ecommerce.dto.product.ProductResponse;
import com.pehlione.ecommerce.dto.product.ProductSearchParams;
import com.pehlione.ecommerce.service.ProductService;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;

@RestController
@RequestMapping("/api/products")
@CrossOrigin(origins = "*")
public class StoreProductController {

    private final ProductService productService;

    public StoreProductController(ProductService productService) {
        this.productService = productService;
    }

    @GetMapping
    public List<ProductResponse> findAll() {
        return productService.findAll()
                .stream()
                .filter(product -> "ACTIVE".equals(product.getStatus().name()))
                .toList();
    }

    @GetMapping("/search")
    public PagedResponse<ProductResponse> search(
            @RequestParam(required = false) String search,
            @RequestParam(required = false) Long categoryId,
            @RequestParam(required = false) BigDecimal minPrice,
            @RequestParam(required = false) BigDecimal maxPrice,
            @RequestParam(required = false, defaultValue = "ACTIVE") String status,
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
        params.setStatus(status.isBlank() ? null : Product.ProductStatus.valueOf(status.toUpperCase()));
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
}

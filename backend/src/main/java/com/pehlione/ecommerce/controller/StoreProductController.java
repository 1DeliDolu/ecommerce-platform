package com.pehlione.ecommerce.controller;

import com.pehlione.ecommerce.dto.product.ProductResponse;
import com.pehlione.ecommerce.service.ProductService;
import org.springframework.web.bind.annotation.*;

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

    @GetMapping("/{id}")
    public ProductResponse findById(@PathVariable Long id) {
        return productService.findById(id);
    }
}

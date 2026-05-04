package com.pehlione.ecommerce.controller;

import com.pehlione.ecommerce.dto.customer.*;
import com.pehlione.ecommerce.service.CartService;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/cart")
@CrossOrigin(origins = "*")
public class CartController {

    private final CartService cartService;

    public CartController(CartService cartService) {
        this.cartService = cartService;
    }

    @GetMapping
    public CartResponse getCart(
            @RequestHeader(value = "X-User-Email", defaultValue = "customer@example.com") String userEmail) {
        return cartService.getCart(userEmail);
    }

    @PostMapping("/items")
    public CartResponse addItem(
            @RequestHeader(value = "X-User-Email", defaultValue = "customer@example.com") String userEmail,
            @RequestBody AddCartItemRequest request) {
        return cartService.addItem(userEmail, request);
    }

    @PatchMapping("/items/{productId}")
    public CartResponse updateItem(
            @RequestHeader(value = "X-User-Email", defaultValue = "customer@example.com") String userEmail,
            @PathVariable Long productId,
            @RequestBody UpdateCartItemRequest request) {
        return cartService.updateItem(userEmail, productId, request);
    }

    @DeleteMapping("/items/{productId}")
    public CartResponse removeItem(
            @RequestHeader(value = "X-User-Email", defaultValue = "customer@example.com") String userEmail,
            @PathVariable Long productId) {
        return cartService.removeItem(userEmail, productId);
    }
}

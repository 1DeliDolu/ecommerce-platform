package com.pehlione.ecommerce.controller;

import com.pehlione.ecommerce.dto.customer.*;
import com.pehlione.ecommerce.service.CheckoutService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/orders")
@CrossOrigin(origins = "*")
public class CheckoutController {

    private final CheckoutService checkoutService;

    public CheckoutController(CheckoutService checkoutService) {
        this.checkoutService = checkoutService;
    }

    @PostMapping("/checkout")
    public OrderResponse checkout(
            @RequestHeader(value = "X-User-Email", defaultValue = "customer@example.com") String userEmail,
            @RequestBody CheckoutRequest request) {
        return checkoutService.checkout(userEmail, request);
    }

    @GetMapping("/my")
    public List<OrderResponse> myOrders(
            @RequestHeader(value = "X-User-Email", defaultValue = "customer@example.com") String userEmail) {
        return checkoutService.findMyOrders(userEmail);
    }
}

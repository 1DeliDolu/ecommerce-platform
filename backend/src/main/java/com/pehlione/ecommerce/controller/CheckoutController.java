package com.pehlione.ecommerce.controller;

import com.pehlione.ecommerce.dto.customer.*;
import com.pehlione.ecommerce.service.CheckoutService;
import jakarta.validation.Valid;
import org.springframework.security.core.Authentication;
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
            Authentication authentication,
            @Valid @RequestBody CheckoutRequest request) {
        return checkoutService.checkout(authentication.getName(), request);
    }

    @GetMapping("/my")
    public List<OrderResponse> myOrders(Authentication authentication) {
        return checkoutService.findMyOrders(authentication.getName());
    }
}

package com.example.ecommerce.dto;

public record LoginResponse(
        String accessToken,
        String tokenType,
        String role
) {}

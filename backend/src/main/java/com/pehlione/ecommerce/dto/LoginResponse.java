package com.pehlione.ecommerce.dto;

public record LoginResponse(
        String accessToken,
        String tokenType,
        String role
) {}

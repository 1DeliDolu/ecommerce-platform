package com.pehlione.ecommerce.dto;

import com.pehlione.ecommerce.dto.auth.AuthUserResponse;

public record LoginResponse(
        String accessToken,
        String refreshToken,
        AuthUserResponse user
) {}

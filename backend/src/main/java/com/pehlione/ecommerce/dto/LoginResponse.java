package com.pehlione.ecommerce.dto;

import com.pehlione.ecommerce.dto.auth.AuthUserResponse;

public record LoginResponse(
        String accessToken,
        AuthUserResponse user
) {}

package com.pehlione.ecommerce.dto.auth;

import java.util.List;

public record AuthUserResponse(
        String email,
        String fullName,
        String role,
        List<String> permissions
) {}

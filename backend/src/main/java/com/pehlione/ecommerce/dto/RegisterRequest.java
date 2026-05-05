package com.pehlione.ecommerce.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record RegisterRequest(
        @NotBlank @Size(max = 200) String fullName,
        @Email @NotBlank @Size(max = 255) String email,
        @NotBlank
        @Size(min = 8, max = 100)
        @Pattern(
                regexp = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[^a-zA-Z\\d]).{8,}$",
                message = "Password must be at least 8 characters and contain at least one uppercase letter, one lowercase letter, one digit, and one special character"
        )
        String password
) {}

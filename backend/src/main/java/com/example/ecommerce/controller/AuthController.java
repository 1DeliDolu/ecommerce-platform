package com.example.ecommerce.controller;

import com.example.ecommerce.dto.LoginRequest;
import com.example.ecommerce.dto.LoginResponse;
import com.example.ecommerce.security.JwtService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
public class AuthController {
    private final JwtService jwtService;

    public AuthController(JwtService jwtService) {
        this.jwtService = jwtService;
    }

    @PostMapping("/login")
    public LoginResponse login(@Valid @RequestBody LoginRequest request) {
        // Demo amaçlıdır. Production'da BCrypt/Argon2 password verification + DB user lookup kullanın.
        String role = request.email().equalsIgnoreCase("admin@example.com") ? "ADMIN" : "CUSTOMER";
        String token = jwtService.createToken(request.email(), role);
        return new LoginResponse(token, "Bearer", role);
    }
}

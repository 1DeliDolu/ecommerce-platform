package com.pehlione.ecommerce.controller;

import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import com.pehlione.ecommerce.dto.LoginRequest;
import com.pehlione.ecommerce.dto.LoginResponse;
import com.pehlione.ecommerce.dto.auth.AuthUserResponse;
import com.pehlione.ecommerce.repository.AppUserRepository;
import com.pehlione.ecommerce.security.JwtService;

import java.util.Arrays;
import java.util.List;

@RestController
@RequestMapping("/api/auth")
public class AuthController {
    private final AppUserRepository appUserRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;

    public AuthController(AppUserRepository appUserRepository, PasswordEncoder passwordEncoder, JwtService jwtService) {
        this.appUserRepository = appUserRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
    }

    @PostMapping("/login")
    public LoginResponse login(@Valid @RequestBody LoginRequest request) {
        var user = appUserRepository.findByEmailIgnoreCase(request.email())
                .filter(candidate -> candidate.isEnabled()
                        && passwordEncoder.matches(request.password(), candidate.getPasswordHash()))
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid credentials"));

        List<String> permissions = parsePermissions(user.getPermissions());
        String token = jwtService.createToken(user.getEmail(), user.getFullName(), user.getRole(), permissions);

        AuthUserResponse userResponse = new AuthUserResponse(
                user.getEmail(),
                user.getFullName(),
                user.getRole(),
                permissions
        );

        return new LoginResponse(token, userResponse);
    }

    private List<String> parsePermissions(String permissions) {
        if (permissions == null || permissions.isBlank()) {
            return List.of();
        }
        return Arrays.stream(permissions.split(","))
                .map(String::trim)
                .filter(value -> !value.isBlank())
                .toList();
    }
}

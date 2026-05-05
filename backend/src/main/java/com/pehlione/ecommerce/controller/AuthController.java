package com.pehlione.ecommerce.controller;

import com.pehlione.ecommerce.audit.AuditAction;
import com.pehlione.ecommerce.audit.AuditService;
import com.pehlione.ecommerce.security.AccountLockoutService;
import jakarta.validation.Valid;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.MeterRegistry;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import com.pehlione.ecommerce.dto.LoginRequest;
import com.pehlione.ecommerce.dto.LoginResponse;
import com.pehlione.ecommerce.dto.RefreshTokenRequest;
import com.pehlione.ecommerce.dto.RegisterRequest;
import com.pehlione.ecommerce.domain.AppUser;
import com.pehlione.ecommerce.dto.auth.AuthUserResponse;
import com.pehlione.ecommerce.event.KafkaEventPublisher;
import com.pehlione.ecommerce.event.KafkaTopics;
import com.pehlione.ecommerce.repository.AppUserRepository;
import com.pehlione.ecommerce.security.JwtService;
import com.pehlione.ecommerce.security.LoginAttemptAuditService;
import com.pehlione.ecommerce.security.RefreshTokenService;

import java.util.Arrays;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
public class AuthController {
    private static final String CUSTOMER_PERMISSIONS = "PRODUCT_READ,ORDER_READ_OWN";

    private final AppUserRepository appUserRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final RefreshTokenService refreshTokenService;
    private final LoginAttemptAuditService loginAttemptAuditService;
    private final AccountLockoutService accountLockoutService;
    private final KafkaEventPublisher kafkaEventPublisher;
    private final AuditService auditService;
    private final Counter loginSuccessCounter;
    private final Counter loginFailureCounter;

    public AuthController(AppUserRepository appUserRepository, PasswordEncoder passwordEncoder,
                          JwtService jwtService, RefreshTokenService refreshTokenService,
                          LoginAttemptAuditService loginAttemptAuditService,
                          AccountLockoutService accountLockoutService,
                          KafkaEventPublisher kafkaEventPublisher,
                          AuditService auditService,
                          MeterRegistry meterRegistry) {
        this.appUserRepository = appUserRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
        this.refreshTokenService = refreshTokenService;
        this.loginAttemptAuditService = loginAttemptAuditService;
        this.accountLockoutService = accountLockoutService;
        this.kafkaEventPublisher = kafkaEventPublisher;
        this.auditService = auditService;
        this.loginSuccessCounter = Counter.builder("ecommerce.auth.login")
                .tag("result", "success")
                .description("Successful logins")
                .register(meterRegistry);
        this.loginFailureCounter = Counter.builder("ecommerce.auth.login")
                .tag("result", "failure")
                .description("Failed logins")
                .register(meterRegistry);
    }

    @PostMapping("/login")
    public LoginResponse login(@Valid @RequestBody LoginRequest request) {
        var userOpt = appUserRepository.findByEmailIgnoreCase(request.email());

        if (userOpt.isEmpty()) {
            loginFailureCounter.increment();
            loginAttemptAuditService.record(request.email(), false, "INVALID_CREDENTIALS");
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid credentials");
        }

        var user = userOpt.get();

        if (accountLockoutService.isLocked(user)) {
            loginAttemptAuditService.record(request.email(), false, "ACCOUNT_LOCKED");
            throw new ResponseStatusException(HttpStatus.LOCKED, "Account temporarily locked. Try again later.");
        }

        if (!user.isEnabled() || !passwordEncoder.matches(request.password(), user.getPasswordHash())) {
            loginFailureCounter.increment();
            loginAttemptAuditService.record(request.email(), false, "INVALID_CREDENTIALS");
            accountLockoutService.recordFailure(user);
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid credentials");
        }

        loginSuccessCounter.increment();
        loginAttemptAuditService.record(user.getEmail(), true, null);
        accountLockoutService.recordSuccess(user);

        List<String> permissions = parsePermissions(user.getPermissions());
        String token = jwtService.createToken(user.getEmail(), user.getFullName(), user.getRole(), permissions);
        String refreshToken = refreshTokenService.rotateForUser(user);

        return new LoginResponse(token, refreshToken, toUserResponse(user, permissions));
    }

    @PostMapping("/register")
    @ResponseStatus(HttpStatus.CREATED)
    public LoginResponse register(@Valid @RequestBody RegisterRequest request) {
        String email = request.email().trim().toLowerCase();
        if (appUserRepository.existsByEmailIgnoreCase(email)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Email is already registered");
        }

        AppUser user = new AppUser();
        user.setEmail(email);
        user.setFullName(request.fullName().trim());
        user.setPasswordHash(passwordEncoder.encode(request.password()));
        user.setRole("CUSTOMER");
        user.setPermissions(CUSTOMER_PERMISSIONS);
        user.setEnabled(true);

        AppUser saved = appUserRepository.save(user);
        auditService.record(
                AuditAction.USER_REGISTERED,
                "user",
                saved.getId().toString(),
                "email=" + maskEmail(saved.getEmail()) + "; role=" + saved.getRole()
        );
        List<String> permissions = parsePermissions(saved.getPermissions());
        String token = jwtService.createToken(saved.getEmail(), saved.getFullName(), saved.getRole(), permissions);
        String refreshToken = refreshTokenService.rotateForUser(saved);
        kafkaEventPublisher.publish(
                KafkaTopics.USER_REGISTERED,
                "auth-service",
                Map.of(
                        "userId", saved.getId(),
                        "email", saved.getEmail(),
                        "role", saved.getRole()
                )
        );

        return new LoginResponse(token, refreshToken, toUserResponse(saved, permissions));
    }

    @PostMapping("/refresh")
    public LoginResponse refresh(@Valid @RequestBody RefreshTokenRequest request) {
        Long userId = refreshTokenService.consume(request.refreshToken())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid refresh token"));

        AppUser user = appUserRepository.findById(userId)
                .filter(AppUser::isEnabled)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid refresh token"));

        List<String> permissions = parsePermissions(user.getPermissions());
        String accessToken = jwtService.createToken(user.getEmail(), user.getFullName(), user.getRole(), permissions);
        String refreshToken = refreshTokenService.rotateForUser(user);
        auditService.record(
                AuditAction.TOKEN_REFRESHED,
                "auth",
                user.getId().toString(),
                "email=" + maskEmail(user.getEmail())
        );

        return new LoginResponse(accessToken, refreshToken, toUserResponse(user, permissions));
    }

    @GetMapping("/me")
    public AuthUserResponse me(@RequestHeader(value = "Authorization", required = false) String authorizationHeader) {
        String token = extractBearerToken(authorizationHeader);
        try {
            Claims claims = jwtService.parseToken(token);
            return new AuthUserResponse(
                    claims.getSubject(),
                    stringClaim(claims, "fullName"),
                    stringClaim(claims, "role"),
                    permissionsClaim(claims)
            );
        } catch (JwtException | IllegalArgumentException exception) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid token");
        }
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

    private AuthUserResponse toUserResponse(AppUser user, List<String> permissions) {
        return new AuthUserResponse(
                user.getEmail(),
                user.getFullName() != null ? user.getFullName() : "",
                user.getRole(),
                permissions
        );
    }

    private String extractBearerToken(String authorizationHeader) {
        if (authorizationHeader == null || !authorizationHeader.startsWith("Bearer ")) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Bearer token is required");
        }
        String token = authorizationHeader.substring("Bearer ".length()).trim();
        if (token.isBlank()) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Bearer token is required");
        }
        return token;
    }

    private String stringClaim(Claims claims, String name) {
        Object value = claims.get(name);
        return value == null ? "" : value.toString();
    }

    private List<String> permissionsClaim(Claims claims) {
        Object value = claims.get("permissions");
        if (!(value instanceof List<?> rawPermissions)) {
            return List.of();
        }
        return rawPermissions.stream()
                .map(Object::toString)
                .filter(permission -> !permission.isBlank())
                .toList();
    }

    private String maskEmail(String email) {
        if (email == null || email.isBlank()) {
            return "";
        }
        int atIndex = email.indexOf('@');
        if (atIndex <= 1) {
            return "***" + (atIndex >= 0 ? email.substring(atIndex) : "");
        }
        return email.charAt(0) + "***" + email.substring(atIndex);
    }
}

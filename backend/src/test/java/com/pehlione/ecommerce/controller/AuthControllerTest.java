package com.pehlione.ecommerce.controller;

import org.junit.jupiter.api.Test;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.server.ResponseStatusException;

import com.pehlione.ecommerce.domain.AppUser;
import com.pehlione.ecommerce.dto.LoginRequest;
import com.pehlione.ecommerce.repository.AppUserRepository;
import com.pehlione.ecommerce.security.JwtService;

import java.lang.reflect.Proxy;
import java.util.Map;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class AuthControllerTest {
    private final JwtService jwtService = new JwtService("01234567890123456789012345678901", 30);

    @Test
    void loginReturnsBearerTokenForValidCredentials() {
        AppUser user = new AppUser();
        user.setEmail("admin@example.com");
        user.setFullName("Admin User");
        user.setPasswordHash("admin123");
        user.setRole("ADMIN");
        user.setPermissions("ADMIN_PANEL_ACCESS,PRODUCT_READ");
        user.setEnabled(true);

        AuthController authController = new AuthController(
                repositoryWithUsers(Map.of("admin@example.com", user)),
                plainTextPasswordEncoder(),
                jwtService
        );

        var response = authController.login(new LoginRequest("admin@example.com", "admin123"));

        assertThat(response.accessToken()).isNotBlank();
        assertThat(response.user().role()).isEqualTo("ADMIN");
        assertThat(response.user().email()).isEqualTo("admin@example.com");
        assertThat(response.user().permissions()).contains("ADMIN_PANEL_ACCESS", "PRODUCT_READ");
    }

    @Test
    void loginRejectsInvalidCredentials() {
        AppUser user = new AppUser();
        user.setEmail("admin@example.com");
        user.setFullName("Admin User");
        user.setPasswordHash("admin123");
        user.setRole("ADMIN");
        user.setPermissions("");
        user.setEnabled(true);

        AuthController authController = new AuthController(
                repositoryWithUsers(Map.of("admin@example.com", user)),
                plainTextPasswordEncoder(),
                jwtService
        );

        assertThatThrownBy(() -> authController.login(new LoginRequest("admin@example.com", "wrong-password")))
                .isInstanceOf(ResponseStatusException.class)
                .hasMessageContaining("401 UNAUTHORIZED");
    }

    private AppUserRepository repositoryWithUsers(Map<String, AppUser> usersByEmail) {
        return (AppUserRepository) Proxy.newProxyInstance(
                AppUserRepository.class.getClassLoader(),
                new Class<?>[]{AppUserRepository.class},
                (proxy, method, args) -> {
                    if (method.getName().equals("findByEmailIgnoreCase")) {
                        String email = ((String) args[0]).toLowerCase();
                        return Optional.ofNullable(usersByEmail.get(email));
                    }
                    throw new UnsupportedOperationException(method.getName());
                }
        );
    }

    private PasswordEncoder plainTextPasswordEncoder() {
        return new PasswordEncoder() {
            @Override
            public String encode(CharSequence rawPassword) {
                return rawPassword.toString();
            }

            @Override
            public boolean matches(CharSequence rawPassword, String encodedPassword) {
                return rawPassword.toString().equals(encodedPassword);
            }
        };
    }
}

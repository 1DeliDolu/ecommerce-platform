package com.pehlione.ecommerce.controller;

import com.pehlione.ecommerce.audit.AuditService;
import com.pehlione.ecommerce.domain.AppUser;
import com.pehlione.ecommerce.dto.LoginRequest;
import com.pehlione.ecommerce.event.KafkaEventPublisher;
import com.pehlione.ecommerce.repository.AppUserRepository;
import com.pehlione.ecommerce.security.JwtService;
import com.pehlione.ecommerce.security.LoginAttemptAuditService;
import com.pehlione.ecommerce.security.RefreshTokenService;
import io.micrometer.core.instrument.simple.SimpleMeterRegistry;
import org.junit.jupiter.api.Test;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.server.ResponseStatusException;

import java.util.Map;
import java.util.Optional;
import java.lang.reflect.Proxy;

import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

class BruteForceProtectionTest {

    private final JwtService jwtService = new JwtService("01234567890123456789012345678901", "", "", 30);
    private final SimpleMeterRegistry meterRegistry = new SimpleMeterRegistry();

    @Test
    void loginIsBlockedWhenAccountIsLockedOut() {
        LoginAttemptAuditService lockoutService = mock(LoginAttemptAuditService.class);
        when(lockoutService.isLockedOut("victim@example.com")).thenReturn(true);

        AuthController authController = new AuthController(
                emptyRepository(),
                plainTextEncoder(),
                jwtService,
                refreshTokenService(),
                lockoutService,
                mock(KafkaEventPublisher.class),
                mock(AuditService.class),
                meterRegistry
        );

        assertThatThrownBy(() -> authController.login(new LoginRequest("victim@example.com", "password")))
                .isInstanceOf(ResponseStatusException.class)
                .hasMessageContaining("429");
    }

    @Test
    void loginProceedsWhenNotLockedOut() {
        AppUser user = new AppUser();
        user.setEmail("good@example.com");
        user.setFullName("Good User");
        user.setPasswordHash("pass");
        user.setRole("CUSTOMER");
        user.setPermissions("PRODUCT_READ");
        user.setEnabled(true);

        LoginAttemptAuditService lockoutService = mock(LoginAttemptAuditService.class);
        when(lockoutService.isLockedOut(any())).thenReturn(false);

        RefreshTokenService rts = mock(RefreshTokenService.class);
        when(rts.rotateForUser(any())).thenReturn("rt");

        AuthController authController = new AuthController(
                repositoryWithUser(user),
                plainTextEncoder(),
                jwtService,
                rts,
                lockoutService,
                mock(KafkaEventPublisher.class),
                mock(AuditService.class),
                meterRegistry
        );

        var response = authController.login(new LoginRequest("good@example.com", "pass"));
        org.assertj.core.api.Assertions.assertThat(response.accessToken()).isNotBlank();
    }

    private AppUserRepository emptyRepository() {
        return (AppUserRepository) Proxy.newProxyInstance(
                AppUserRepository.class.getClassLoader(),
                new Class<?>[]{AppUserRepository.class},
                (proxy, method, args) -> {
                    if (method.getName().equals("findByEmailIgnoreCase")) return Optional.empty();
                    throw new UnsupportedOperationException(method.getName());
                }
        );
    }

    private AppUserRepository repositoryWithUser(AppUser user) {
        return (AppUserRepository) Proxy.newProxyInstance(
                AppUserRepository.class.getClassLoader(),
                new Class<?>[]{AppUserRepository.class},
                (proxy, method, args) -> {
                    if (method.getName().equals("findByEmailIgnoreCase")) {
                        String email = ((String) args[0]).toLowerCase();
                        return user.getEmail().equals(email) ? Optional.of(user) : Optional.empty();
                    }
                    throw new UnsupportedOperationException(method.getName());
                }
        );
    }

    private PasswordEncoder plainTextEncoder() {
        return new PasswordEncoder() {
            @Override public String encode(CharSequence r) { return r.toString(); }
            @Override public boolean matches(CharSequence r, String e) { return r.toString().equals(e); }
        };
    }

    private RefreshTokenService refreshTokenService() {
        RefreshTokenService rts = mock(RefreshTokenService.class);
        when(rts.rotateForUser(any())).thenReturn("rt");
        return rts;
    }
}

package com.pehlione.ecommerce.security;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class JwtServiceTest {
    @Test
    void constructorRejectsShortSecret() {
        assertThatThrownBy(() -> new JwtService("short-secret", 30))
                .isInstanceOf(IllegalStateException.class)
                .hasMessageContaining("at least 32 bytes");
    }

    @Test
    void createTokenReturnsSignedTokenForValidSecret() {
        JwtService jwtService = new JwtService("01234567890123456789012345678901", 30);

        String token = jwtService.createToken("admin@example.com", "ADMIN");

        assertThat(token).isNotBlank();
        assertThat(token.split("\\.")).hasSize(3);
    }
}

package com.pehlione.ecommerce.security;

import org.junit.jupiter.api.Test;

import java.security.KeyPair;
import java.security.KeyPairGenerator;
import java.util.Base64;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class JwtServiceTest {
    @Test
    void constructorRejectsShortSecret() {
        assertThatThrownBy(() -> new JwtService("short-secret", "", "", 30))
                .isInstanceOf(IllegalStateException.class)
                .hasMessageContaining("at least 32 bytes");
    }

    @Test
    void constructorRejectsBlankSecretWithoutRsaKeys() {
        assertThatThrownBy(() -> new JwtService("", "", "", 30))
                .isInstanceOf(IllegalStateException.class)
                .hasMessageContaining("JWT secret must be configured");
    }

    @Test
    void createTokenReturnsSignedTokenForValidHmacSecret() {
        JwtService jwtService = new JwtService("01234567890123456789012345678901", "", "", 30);

        String token = jwtService.createToken("admin@example.com", "Admin User", "ADMIN", List.of("ADMIN_PANEL_ACCESS"));

        assertThat(token).isNotBlank();
        assertThat(token.split("\\.")).hasSize(3);
    }

    @Test
    void createAndParseTokenRoundTripWithHmac() {
        JwtService jwtService = new JwtService("01234567890123456789012345678901", "", "", 30);

        String token = jwtService.createToken("user@example.com", "Test User", "CUSTOMER", List.of("PRODUCT_READ"));
        var claims = jwtService.parseToken(token);

        assertThat(claims.getSubject()).isEqualTo("user@example.com");
        assertThat(claims.get("role")).isEqualTo("CUSTOMER");
    }

    @Test
    void createAndParseTokenRoundTripWithRsa() throws Exception {
        KeyPairGenerator gen = KeyPairGenerator.getInstance("RSA");
        gen.initialize(2048);
        KeyPair keyPair = gen.generateKeyPair();

        String privateKeyBase64 = Base64.getEncoder().encodeToString(keyPair.getPrivate().getEncoded());
        String publicKeyBase64 = Base64.getEncoder().encodeToString(keyPair.getPublic().getEncoded());

        JwtService jwtService = new JwtService("", privateKeyBase64, publicKeyBase64, 30);

        String token = jwtService.createToken("rsa@example.com", "RSA User", "ADMIN", List.of("ADMIN_PANEL_ACCESS"));

        assertThat(token).isNotBlank();
        assertThat(token.split("\\.")).hasSize(3);

        var claims = jwtService.parseToken(token);
        assertThat(claims.getSubject()).isEqualTo("rsa@example.com");
        assertThat(claims.get("role")).isEqualTo("ADMIN");
    }

    @Test
    void rsaModeIgnoresHmacSecret() throws Exception {
        KeyPairGenerator gen = KeyPairGenerator.getInstance("RSA");
        gen.initialize(2048);
        KeyPair keyPair = gen.generateKeyPair();

        String privateKeyBase64 = Base64.getEncoder().encodeToString(keyPair.getPrivate().getEncoded());
        String publicKeyBase64 = Base64.getEncoder().encodeToString(keyPair.getPublic().getEncoded());

        // Should not throw even though secret is blank, because RSA keys take precedence
        JwtService jwtService = new JwtService("", privateKeyBase64, publicKeyBase64, 30);
        String token = jwtService.createToken("user@example.com", "User", "CUSTOMER", List.of());
        assertThat(jwtService.parseToken(token).getSubject()).isEqualTo("user@example.com");
    }
}

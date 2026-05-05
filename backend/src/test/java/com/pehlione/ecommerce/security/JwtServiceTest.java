package com.pehlione.ecommerce.security;

import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

import java.security.KeyPair;
import java.security.KeyPairGenerator;
import java.security.interfaces.RSAPrivateKey;
import java.security.interfaces.RSAPublicKey;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class JwtServiceTest {

    private static RSAPrivateKey privateKey;
    private static RSAPublicKey publicKey;

    @BeforeAll
    static void generateKeyPair() throws Exception {
        KeyPairGenerator gen = KeyPairGenerator.getInstance("RSA");
        gen.initialize(2048);
        KeyPair kp = gen.generateKeyPair();
        privateKey = (RSAPrivateKey) kp.getPrivate();
        publicKey = (RSAPublicKey) kp.getPublic();
    }

    @Test
    void createTokenReturnsSignedRS256Token() {
        JwtService jwtService = new JwtService(privateKey, publicKey, 30);

        String token = jwtService.createToken("admin@example.com", "Admin User", "ADMIN", List.of("ADMIN_PANEL_ACCESS"));

        assertThat(token).isNotBlank();
        assertThat(token.split("\\.")).hasSize(3);
    }

    @Test
    void parseTokenReturnsCorrectClaims() {
        JwtService jwtService = new JwtService(privateKey, publicKey, 30);

        String token = jwtService.createToken("user@example.com", "User Name", "CUSTOMER", List.of("PRODUCT_READ"));
        var claims = jwtService.parseToken(token);

        assertThat(claims.getSubject()).isEqualTo("user@example.com");
        assertThat(claims.get("role", String.class)).isEqualTo("CUSTOMER");
    }

    @Test
    void parseTokenRejectsTokenSignedWithDifferentKey() throws Exception {
        KeyPairGenerator gen = KeyPairGenerator.getInstance("RSA");
        gen.initialize(2048);
        KeyPair otherKp = gen.generateKeyPair();
        JwtService signer = new JwtService((RSAPrivateKey) otherKp.getPrivate(), publicKey, 30);
        JwtService verifier = new JwtService(privateKey, publicKey, 30);

        String token = signer.createToken("attacker@example.com", "Attacker", "ADMIN", List.of());

        assertThatThrownBy(() -> verifier.parseToken(token))
                .isInstanceOf(io.jsonwebtoken.JwtException.class);
    }
}

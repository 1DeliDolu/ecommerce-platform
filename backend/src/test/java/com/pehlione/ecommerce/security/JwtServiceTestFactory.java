package com.pehlione.ecommerce.security;

import java.security.interfaces.RSAPrivateKey;
import java.security.interfaces.RSAPublicKey;

public final class JwtServiceTestFactory {

    private JwtServiceTestFactory() {
    }

    public static JwtService create(RSAPrivateKey signingKey, RSAPublicKey verificationKey, long expirationMinutes) {
        return new JwtService(signingKey, verificationKey, expirationMinutes);
    }
}

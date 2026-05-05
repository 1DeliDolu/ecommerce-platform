package com.pehlione.ecommerce.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.security.KeyFactory;
import java.security.NoSuchAlgorithmException;
import java.security.PrivateKey;
import java.security.PublicKey;
import java.security.spec.InvalidKeySpecException;
import java.security.spec.PKCS8EncodedKeySpec;
import java.security.spec.X509EncodedKeySpec;
import java.time.Instant;
import java.util.Base64;
import java.util.Date;
import java.util.List;

@Service
public class JwtService {
    private static final int MIN_SECRET_BYTES = 32;

    /** Symmetric key – present when using HS256 mode. */
    private final SecretKey hmacKey;
    /** RSA private key – present when using RS256 mode. */
    private final PrivateKey rsaPrivateKey;
    /** RSA public key – present when using RS256 mode. */
    private final PublicKey rsaPublicKey;

    private final long expirationMinutes;

    public JwtService(
            @Value("${security.jwt.secret:}") String secret,
            @Value("${security.jwt.private-key:}") String privateKeyBase64,
            @Value("${security.jwt.public-key:}") String publicKeyBase64,
            @Value("${security.jwt.expiration-minutes}") long expirationMinutes
    ) {
        this.expirationMinutes = expirationMinutes;

        boolean hasRsaKeys = isPresent(privateKeyBase64) && isPresent(publicKeyBase64);
        if (hasRsaKeys) {
            this.rsaPrivateKey = parsePrivateKey(privateKeyBase64);
            this.rsaPublicKey = parsePublicKey(publicKeyBase64);
            this.hmacKey = null;
        } else {
            this.hmacKey = Keys.hmacShaKeyFor(validateSecret(secret));
            this.rsaPrivateKey = null;
            this.rsaPublicKey = null;
        }
    }

    private static boolean isPresent(String value) {
        return value != null && !value.isBlank();
    }

    private byte[] validateSecret(String secret) {
        if (secret == null || secret.isBlank()) {
            throw new IllegalStateException("JWT secret must be configured");
        }

        byte[] secretBytes = secret.getBytes(StandardCharsets.UTF_8);
        if (secretBytes.length < MIN_SECRET_BYTES) {
            throw new IllegalStateException("JWT secret must be at least 32 bytes for HS256 signing");
        }

        return secretBytes;
    }

    private PrivateKey parsePrivateKey(String base64) {
        try {
            byte[] keyBytes = Base64.getMimeDecoder().decode(stripPemHeaders(base64));
            PKCS8EncodedKeySpec spec = new PKCS8EncodedKeySpec(keyBytes);
            return KeyFactory.getInstance("RSA").generatePrivate(spec);
        } catch (NoSuchAlgorithmException | InvalidKeySpecException e) {
            throw new IllegalStateException("Invalid RSA private key configuration", e);
        }
    }

    private PublicKey parsePublicKey(String base64) {
        try {
            byte[] keyBytes = Base64.getMimeDecoder().decode(stripPemHeaders(base64));
            X509EncodedKeySpec spec = new X509EncodedKeySpec(keyBytes);
            return KeyFactory.getInstance("RSA").generatePublic(spec);
        } catch (NoSuchAlgorithmException | InvalidKeySpecException e) {
            throw new IllegalStateException("Invalid RSA public key configuration", e);
        }
    }

    private String stripPemHeaders(String pem) {
        return pem.replaceAll("-----[^-]+-----", "").replaceAll("\\s+", "");
    }

    public String createToken(String subject, String fullName, String role, List<String> permissions) {
        Instant now = Instant.now();
        var builder = Jwts.builder()
                .subject(subject)
                .claim("fullName", fullName)
                .claim("role", role)
                .claim("permissions", permissions)
                .issuedAt(Date.from(now))
                .expiration(Date.from(now.plusSeconds(expirationMinutes * 60)));

        if (rsaPrivateKey != null) {
            return builder.signWith(rsaPrivateKey).compact();
        }
        return builder.signWith(hmacKey).compact();
    }

    public Claims parseToken(String token) throws JwtException {
        var parserBuilder = Jwts.parser();
        if (rsaPublicKey != null) {
            parserBuilder.verifyWith(rsaPublicKey);
        } else {
            parserBuilder.verifyWith(hmacKey);
        }
        return parserBuilder.build().parseSignedClaims(token).getPayload();
    }
}

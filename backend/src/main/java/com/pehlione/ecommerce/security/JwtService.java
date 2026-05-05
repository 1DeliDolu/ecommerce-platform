package com.pehlione.ecommerce.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.security.GeneralSecurityException;
import java.security.KeyFactory;
import java.security.interfaces.RSAPrivateKey;
import java.security.interfaces.RSAPublicKey;
import java.security.spec.PKCS8EncodedKeySpec;
import java.security.spec.X509EncodedKeySpec;
import java.time.Instant;
import java.util.Base64;
import java.util.Date;
import java.util.List;

@Service
public class JwtService {

    private final RSAPrivateKey signingKey;
    private final RSAPublicKey verificationKey;
    private final long expirationMinutes;

    @Autowired
    public JwtService(
            @Value("${security.jwt.private-key-path}") String privateKeyPath,
            @Value("${security.jwt.public-key-path}") String publicKeyPath,
            @Value("${security.jwt.expiration-minutes}") long expirationMinutes
    ) throws IOException, GeneralSecurityException {
        this.signingKey = loadPrivateKey(privateKeyPath);
        this.verificationKey = loadPublicKey(publicKeyPath);
        this.expirationMinutes = expirationMinutes;
    }

    // Package-private constructor for unit tests
    JwtService(RSAPrivateKey signingKey, RSAPublicKey verificationKey, long expirationMinutes) {
        this.signingKey = signingKey;
        this.verificationKey = verificationKey;
        this.expirationMinutes = expirationMinutes;
    }

    public String createToken(String subject, String fullName, String role, List<String> permissions) {
        Instant now = Instant.now();
        return Jwts.builder()
                .subject(subject)
                .claim("fullName", fullName)
                .claim("role", role)
                .claim("permissions", permissions)
                .issuedAt(Date.from(now))
                .expiration(Date.from(now.plusSeconds(expirationMinutes * 60)))
                .signWith(signingKey, Jwts.SIG.RS256)
                .compact();
    }

    public Claims parseToken(String token) throws JwtException {
        return Jwts.parser()
                .verifyWith(verificationKey)
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }

    private RSAPrivateKey loadPrivateKey(String path) throws IOException, GeneralSecurityException {
        String pem = Files.readString(Paths.get(path));
        byte[] der = decodePem(pem, "PRIVATE KEY");
        PKCS8EncodedKeySpec spec = new PKCS8EncodedKeySpec(der);
        return (RSAPrivateKey) KeyFactory.getInstance("RSA").generatePrivate(spec);
    }

    private RSAPublicKey loadPublicKey(String path) throws IOException, GeneralSecurityException {
        String pem = Files.readString(Paths.get(path));
        byte[] der = decodePem(pem, "PUBLIC KEY");
        X509EncodedKeySpec spec = new X509EncodedKeySpec(der);
        return (RSAPublicKey) KeyFactory.getInstance("RSA").generatePublic(spec);
    }

    private byte[] decodePem(String pem, String type) {
        String cleaned = pem
                .replace("-----BEGIN " + type + "-----", "")
                .replace("-----END " + type + "-----", "")
                .replaceAll("\\s", "");
        return Base64.getDecoder().decode(cleaned);
    }
}

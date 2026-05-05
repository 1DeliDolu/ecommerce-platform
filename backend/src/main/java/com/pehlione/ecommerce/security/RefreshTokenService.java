package com.pehlione.ecommerce.security;

import com.pehlione.ecommerce.domain.AppUser;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.sql.Timestamp;
import java.time.Instant;
import java.util.Base64;
import java.util.Optional;

@Service
public class RefreshTokenService {
    private static final long REFRESH_TOKEN_DAYS = 7;

    private final JdbcTemplate jdbcTemplate;
    private final SecureRandom secureRandom = new SecureRandom();

    public RefreshTokenService(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Transactional
    public String rotateForUser(AppUser user) {
        jdbcTemplate.update(
                "UPDATE refresh_tokens SET revoked_at = NOW() WHERE user_id = ? AND revoked_at IS NULL",
                user.getId()
        );

        String token = generateToken();
        jdbcTemplate.update(
                "INSERT INTO refresh_tokens (user_id, token_hash, expires_at) VALUES (?, ?, ?)",
                user.getId(),
                hash(token),
                Timestamp.from(Instant.now().plusSeconds(REFRESH_TOKEN_DAYS * 24 * 60 * 60))
        );
        return token;
    }

    @Transactional
    public Optional<Long> consume(String refreshToken) {
        Optional<Long> userId = jdbcTemplate.query(
                        "SELECT user_id FROM refresh_tokens WHERE token_hash = ? AND revoked_at IS NULL AND expires_at > NOW()",
                        (rs, rowNum) -> rs.getLong("user_id"),
                        hash(refreshToken)
                )
                .stream()
                .findFirst();

        userId.ifPresent(id -> jdbcTemplate.update(
                "UPDATE refresh_tokens SET revoked_at = NOW() WHERE token_hash = ?",
                hash(refreshToken)
        ));

        return userId;
    }

    private String generateToken() {
        byte[] bytes = new byte[48];
        secureRandom.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }

    private String hash(String token) {
        try {
            byte[] digest = MessageDigest.getInstance("SHA-256").digest(token.getBytes(StandardCharsets.UTF_8));
            return Base64.getUrlEncoder().withoutPadding().encodeToString(digest);
        } catch (NoSuchAlgorithmException exception) {
            throw new IllegalStateException("SHA-256 is not available", exception);
        }
    }
}

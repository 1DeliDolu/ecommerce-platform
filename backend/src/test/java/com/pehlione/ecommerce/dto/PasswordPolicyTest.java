package com.pehlione.ecommerce.dto;

import jakarta.validation.ConstraintViolation;
import jakarta.validation.Validation;
import jakarta.validation.Validator;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;

import java.util.Set;

import static org.assertj.core.api.Assertions.assertThat;

class PasswordPolicyTest {

    private final Validator validator = Validation.buildDefaultValidatorFactory().getValidator();

    @Test
    void acceptsValidStrongPassword() {
        var request = new RegisterRequest("Test User", "test@example.com", "Secure1!");
        Set<ConstraintViolation<RegisterRequest>> violations = validator.validate(request);
        assertThat(violations).isEmpty();
    }

    @Test
    void rejectsTooShortPassword() {
        var request = new RegisterRequest("Test User", "test@example.com", "Ab1!");
        Set<ConstraintViolation<RegisterRequest>> violations = validator.validate(request);
        assertThat(violations).isNotEmpty();
    }

    @ParameterizedTest
    @ValueSource(strings = {
            "alllowercase1!",    // no uppercase
            "ALLUPPERCASE1!",    // no lowercase
            "NoDigitHere!",      // no digit
            "NoSpecialChar1",    // no special char
            "Sh0rt!"             // too short (7 chars)
    })
    void rejectsWeakPasswords(String password) {
        var request = new RegisterRequest("Test User", "test@example.com", password);
        Set<ConstraintViolation<RegisterRequest>> violations = validator.validate(request);
        assertThat(violations).isNotEmpty();
    }

    @Test
    void rejectsPasswordShorterThan8Characters() {
        var request = new RegisterRequest("Test User", "test@example.com", "Abc1!");
        Set<ConstraintViolation<RegisterRequest>> violations = validator.validate(request);
        assertThat(violations).isNotEmpty();
    }

    @Test
    void acceptsPasswordWithAllRequiredElements() {
        var request = new RegisterRequest("Test User", "test@example.com", "MyP@ssword9");
        Set<ConstraintViolation<RegisterRequest>> violations = validator.validate(request);
        assertThat(violations).isEmpty();
    }
}

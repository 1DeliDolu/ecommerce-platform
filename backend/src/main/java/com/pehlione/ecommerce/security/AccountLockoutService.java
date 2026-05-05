package com.pehlione.ecommerce.security;

import com.pehlione.ecommerce.domain.AppUser;
import com.pehlione.ecommerce.repository.AppUserRepository;
import org.springframework.stereotype.Service;

import java.time.Instant;

@Service
public class AccountLockoutService {
    private static final int MAX_ATTEMPTS = 5;
    private static final int LOCKOUT_MINUTES = 15;

    private final AppUserRepository appUserRepository;

    public AccountLockoutService(AppUserRepository appUserRepository) {
        this.appUserRepository = appUserRepository;
    }

    public boolean isLocked(AppUser user) {
        Instant lockedUntil = user.getLockedUntil();
        if (lockedUntil == null) {
            return false;
        }
        if (Instant.now().isAfter(lockedUntil)) {
            // Lock expired — clear it lazily
            user.setLockedUntil(null);
            user.setFailedLoginAttempts(0);
            appUserRepository.save(user);
            return false;
        }
        return true;
    }

    public void recordFailure(AppUser user) {
        int attempts = user.getFailedLoginAttempts() + 1;
        user.setFailedLoginAttempts(attempts);
        if (attempts >= MAX_ATTEMPTS) {
            user.setLockedUntil(Instant.now().plusSeconds(LOCKOUT_MINUTES * 60L));
        }
        appUserRepository.save(user);
    }

    public void recordSuccess(AppUser user) {
        if (user.getFailedLoginAttempts() > 0 || user.getLockedUntil() != null) {
            user.setFailedLoginAttempts(0);
            user.setLockedUntil(null);
            appUserRepository.save(user);
        }
    }
}

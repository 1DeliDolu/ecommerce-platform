package com.pehlione.ecommerce.config;

import com.pehlione.ecommerce.domain.AppUser;
import com.pehlione.ecommerce.repository.AppUserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

@Component
public class DataInitializer implements ApplicationRunner {

    private static final Logger log = LoggerFactory.getLogger(DataInitializer.class);

    private final AppUserRepository appUserRepository;
    private final PasswordEncoder passwordEncoder;

    public DataInitializer(AppUserRepository appUserRepository, PasswordEncoder passwordEncoder) {
        this.appUserRepository = appUserRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    public void run(ApplicationArguments args) {
        seedAdminUser();
    }

    private void seedAdminUser() {
        String adminEmail = "admin@ecommerce.local";
        String adminPassword = "admin123";

        appUserRepository.findByEmailIgnoreCase(adminEmail).ifPresentOrElse(
            existing -> {
                // Always sync the password so stale hashes from previous runs don't block login
                existing.setPasswordHash(passwordEncoder.encode(adminPassword));
                appUserRepository.save(existing);
                log.info("Admin user password refreshed: {}", adminEmail);
            },
            () -> {
                AppUser admin = new AppUser();
                admin.setEmail(adminEmail);
                admin.setPasswordHash(passwordEncoder.encode(adminPassword));
                admin.setRole("ADMIN");
                admin.setEnabled(true);
                appUserRepository.save(admin);
                log.info("Default admin user created: {}", adminEmail);
            }
        );
    }
}

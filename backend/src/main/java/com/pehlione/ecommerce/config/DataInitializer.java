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

    private static final String ADMIN_PERMISSIONS =
            "ADMIN_PANEL_ACCESS,PRODUCT_READ,PRODUCT_CREATE,PRODUCT_UPDATE,PRODUCT_DELETE," +
            "PRODUCT_IMAGE_UPLOAD,PRODUCT_IMAGE_DELETE,PRODUCT_IMAGE_SET_PRIMARY," +
            "CATEGORY_READ,CATEGORY_CREATE,CATEGORY_UPDATE,CATEGORY_DELETE," +
            "ORDER_READ_OWN,ORDER_READ_ALL,USER_MANAGE,ROLE_MANAGE";

    private static final String EMPLOYEE_PERMISSIONS =
            "ADMIN_PANEL_ACCESS,PRODUCT_READ,PRODUCT_CREATE,PRODUCT_UPDATE," +
            "PRODUCT_IMAGE_UPLOAD,PRODUCT_IMAGE_SET_PRIMARY,CATEGORY_READ,ORDER_READ_OWN";

    private static final String CUSTOMER_PERMISSIONS = "PRODUCT_READ,ORDER_READ_OWN";

    private final AppUserRepository appUserRepository;
    private final PasswordEncoder passwordEncoder;

    public DataInitializer(AppUserRepository appUserRepository, PasswordEncoder passwordEncoder) {
        this.appUserRepository = appUserRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    public void run(ApplicationArguments args) {
        seedUser("admin@example.com", "Admin User", "ADMIN", ADMIN_PERMISSIONS, "password");
        seedUser("employee@example.com", "Employee User", "EMPLOYEE", EMPLOYEE_PERMISSIONS, "password");
        seedUser("customer@example.com", "Customer User", "CUSTOMER", CUSTOMER_PERMISSIONS, "password");
    }

    private void seedUser(String email, String fullName, String role, String permissions, String password) {
        appUserRepository.findByEmailIgnoreCase(email).ifPresentOrElse(
            existing -> {
                existing.setPasswordHash(passwordEncoder.encode(password));
                existing.setFullName(fullName);
                existing.setPermissions(permissions);
                appUserRepository.save(existing);
                log.info("User refreshed: {}", email);
            },
            () -> {
                AppUser user = new AppUser();
                user.setEmail(email);
                user.setFullName(fullName);
                user.setPasswordHash(passwordEncoder.encode(password));
                user.setRole(role);
                user.setPermissions(permissions);
                user.setEnabled(true);
                appUserRepository.save(user);
                log.info("User created: {} ({})", email, role);
            }
        );
    }
}

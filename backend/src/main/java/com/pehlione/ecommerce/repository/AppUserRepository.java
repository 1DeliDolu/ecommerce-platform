package com.pehlione.ecommerce.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.pehlione.ecommerce.domain.AppUser;

import java.util.Optional;

public interface AppUserRepository extends JpaRepository<AppUser, Long> {
    Optional<AppUser> findByEmailIgnoreCase(String email);
}

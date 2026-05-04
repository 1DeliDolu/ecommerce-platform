package com.pehlione.ecommerce.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.pehlione.ecommerce.domain.Product;

public interface ProductRepository extends JpaRepository<Product, Long> {
}

package com.pehlione.ecommerce.repository;

import com.pehlione.ecommerce.domain.Product;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;

public interface ProductRepository extends JpaRepository<Product, Long> {

    boolean existsByCategoryIdAndSlug(Long categoryId, String slug);

    @Query("SELECT DISTINCT p FROM Product p JOIN FETCH p.category LEFT JOIN FETCH p.images ORDER BY p.id")
    List<Product> findAllWithCategoryAndImages();

    @Query("SELECT p FROM Product p JOIN FETCH p.category LEFT JOIN FETCH p.images WHERE p.id = :id")
    Optional<Product> findByIdWithCategoryAndImages(Long id);
}

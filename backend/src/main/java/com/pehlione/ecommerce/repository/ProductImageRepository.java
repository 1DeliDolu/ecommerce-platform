package com.pehlione.ecommerce.repository;

import com.pehlione.ecommerce.domain.ProductImage;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ProductImageRepository extends JpaRepository<ProductImage, Long> {
    List<ProductImage> findByProductIdOrderByImageOrderAsc(Long productId);
    long countByProductId(Long productId);
}

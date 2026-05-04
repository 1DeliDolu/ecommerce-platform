package com.pehlione.ecommerce.repository;

import com.pehlione.ecommerce.domain.CartItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

public interface CartItemRepository extends JpaRepository<CartItem, Long> {

    @Query("SELECT c FROM CartItem c JOIN FETCH c.product p LEFT JOIN FETCH p.category LEFT JOIN FETCH p.images WHERE c.userEmail = :userEmail ORDER BY c.createdAt DESC")
    List<CartItem> findByUserEmailOrderByCreatedAtDesc(String userEmail);

    @Query("SELECT c FROM CartItem c JOIN FETCH c.product p WHERE c.userEmail = :userEmail AND p.id = :productId")
    Optional<CartItem> findByUserEmailAndProductId(String userEmail, Long productId);

    @Modifying
    @Transactional
    @Query("DELETE FROM CartItem c WHERE c.userEmail = :userEmail")
    void deleteByUserEmail(String userEmail);
}

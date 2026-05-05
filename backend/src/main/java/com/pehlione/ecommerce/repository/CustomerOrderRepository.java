package com.pehlione.ecommerce.repository;

import com.pehlione.ecommerce.domain.CustomerOrder;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface CustomerOrderRepository extends JpaRepository<CustomerOrder, Long> {

    @Query("SELECT o FROM CustomerOrder o LEFT JOIN FETCH o.items i LEFT JOIN FETCH i.product WHERE o.userEmail = :userEmail ORDER BY o.createdAt DESC")
    List<CustomerOrder> findByUserEmailOrderByCreatedAtDesc(String userEmail);

    @Query("SELECT DISTINCT o FROM CustomerOrder o LEFT JOIN FETCH o.items i LEFT JOIN FETCH i.product ORDER BY o.createdAt DESC")
    List<CustomerOrder> findAllOrderByCreatedAtDesc();
}

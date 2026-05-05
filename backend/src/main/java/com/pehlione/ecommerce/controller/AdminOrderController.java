package com.pehlione.ecommerce.controller;

import com.pehlione.ecommerce.dto.customer.OrderResponse;
import com.pehlione.ecommerce.repository.CustomerOrderRepository;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/admin/orders")
public class AdminOrderController {
    private final CustomerOrderRepository customerOrderRepository;

    public AdminOrderController(CustomerOrderRepository customerOrderRepository) {
        this.customerOrderRepository = customerOrderRepository;
    }

    @GetMapping
    public List<OrderResponse> findAll() {
        return customerOrderRepository.findAllOrderByCreatedAtDesc()
                .stream()
                .map(OrderResponse::new)
                .toList();
    }
}

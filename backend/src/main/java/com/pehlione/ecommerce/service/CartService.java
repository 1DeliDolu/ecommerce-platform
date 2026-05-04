package com.pehlione.ecommerce.service;

import com.pehlione.ecommerce.domain.CartItem;
import com.pehlione.ecommerce.domain.Product;
import com.pehlione.ecommerce.dto.customer.*;
import com.pehlione.ecommerce.repository.CartItemRepository;
import com.pehlione.ecommerce.repository.ProductRepository;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CartService {

    private final CartItemRepository cartItemRepository;
    private final ProductRepository productRepository;

    public CartService(CartItemRepository cartItemRepository, ProductRepository productRepository) {
        this.cartItemRepository = cartItemRepository;
        this.productRepository = productRepository;
    }

    public CartResponse getCart(String userEmail) {
        List<CartItemResponse> items = cartItemRepository
                .findByUserEmailOrderByCreatedAtDesc(userEmail)
                .stream()
                .map(CartItemResponse::new)
                .toList();
        return new CartResponse(items);
    }

    @Transactional
    public CartResponse addItem(String userEmail, AddCartItemRequest request) {
        if (request.getProductId() == null) throw new IllegalArgumentException("Product id is required.");
        int qty = request.getQuantity() <= 0 ? 1 : request.getQuantity();

        Product product = productRepository.findById(request.getProductId())
                .orElseThrow(() -> new IllegalArgumentException("Product not found."));

        if (product.getStockQuantity() <= 0) throw new IllegalArgumentException("Product is out of stock.");

        CartItem item = cartItemRepository
                .findByUserEmailAndProductId(userEmail, product.getId())
                .orElse(null);

        if (item == null) {
            if (qty > product.getStockQuantity()) throw new IllegalArgumentException("Requested quantity exceeds stock.");
            item = new CartItem(userEmail, product, qty);
        } else {
            int newQty = item.getQuantity() + qty;
            if (newQty > product.getStockQuantity()) throw new IllegalArgumentException("Requested quantity exceeds stock.");
            item.setQuantity(newQty);
        }

        cartItemRepository.save(item);
        return getCart(userEmail);
    }

    @Transactional
    public CartResponse updateItem(String userEmail, Long productId, UpdateCartItemRequest request) {
        if (request.getQuantity() <= 0) return removeItem(userEmail, productId);

        CartItem item = cartItemRepository.findByUserEmailAndProductId(userEmail, productId)
                .orElseThrow(() -> new IllegalArgumentException("Cart item not found."));

        if (request.getQuantity() > item.getProduct().getStockQuantity())
            throw new IllegalArgumentException("Requested quantity exceeds stock.");

        item.setQuantity(request.getQuantity());
        cartItemRepository.save(item);
        return getCart(userEmail);
    }

    @Transactional
    public CartResponse removeItem(String userEmail, Long productId) {
        CartItem item = cartItemRepository.findByUserEmailAndProductId(userEmail, productId)
                .orElseThrow(() -> new IllegalArgumentException("Cart item not found."));
        cartItemRepository.delete(item);
        return getCart(userEmail);
    }

    @Transactional
    public void clearCart(String userEmail) {
        cartItemRepository.deleteByUserEmail(userEmail);
    }
}

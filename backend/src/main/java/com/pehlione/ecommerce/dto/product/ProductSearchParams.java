package com.pehlione.ecommerce.dto.product;

import com.pehlione.ecommerce.domain.Product;

import java.math.BigDecimal;

public class ProductSearchParams {

    private String search;
    private Long categoryId;
    private BigDecimal minPrice;
    private BigDecimal maxPrice;
    private Product.ProductStatus status;
    private int page = 0;
    private int size = 20;
    private String sort = "id";
    private String direction = "desc";

    public String getSearch() { return search; }
    public void setSearch(String search) { this.search = (search != null && search.isBlank()) ? null : search; }

    public Long getCategoryId() { return categoryId; }
    public void setCategoryId(Long categoryId) { this.categoryId = categoryId; }

    public BigDecimal getMinPrice() { return minPrice; }
    public void setMinPrice(BigDecimal minPrice) { this.minPrice = minPrice; }

    public BigDecimal getMaxPrice() { return maxPrice; }
    public void setMaxPrice(BigDecimal maxPrice) { this.maxPrice = maxPrice; }

    public Product.ProductStatus getStatus() { return status; }
    public void setStatus(Product.ProductStatus status) { this.status = status; }

    public int getPage() { return page; }
    public void setPage(int page) { this.page = Math.max(0, page); }

    public int getSize() { return Math.min(Math.max(size, 1), 100); }
    public void setSize(int size) { this.size = size; }

    public String getSort() { return sort; }
    public void setSort(String sort) { this.sort = sort; }

    public String getDirection() { return direction; }
    public void setDirection(String direction) { this.direction = direction; }
}

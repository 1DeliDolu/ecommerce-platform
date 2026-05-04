package com.pehlione.ecommerce.dto.product;

import com.pehlione.ecommerce.domain.ProductImage;

public class ProductImageResponse {

    private Long id;
    private String originalFileName;
    private String storedFileName;
    private String relativePath;
    private String url;
    private String contentType;
    private long fileSize;
    private int imageOrder;
    private boolean primary;

    public ProductImageResponse(ProductImage image) {
        this.id = image.getId();
        this.originalFileName = image.getOriginalFileName();
        this.storedFileName = image.getStoredFileName();
        this.relativePath = image.getRelativePath();
        this.url = "/uploads/" + image.getRelativePath();
        this.contentType = image.getContentType();
        this.fileSize = image.getFileSize();
        this.imageOrder = image.getImageOrder();
        this.primary = image.isPrimaryImage();
    }

    public Long getId() {
        return id;
    }

    public String getOriginalFileName() {
        return originalFileName;
    }

    public String getStoredFileName() {
        return storedFileName;
    }

    public String getRelativePath() {
        return relativePath;
    }

    public String getUrl() {
        return url;
    }

    public String getContentType() {
        return contentType;
    }

    public long getFileSize() {
        return fileSize;
    }

    public int getImageOrder() {
        return imageOrder;
    }

    public boolean isPrimary() {
        return primary;
    }
}

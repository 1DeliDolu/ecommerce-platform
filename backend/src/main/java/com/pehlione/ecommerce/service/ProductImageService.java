package com.pehlione.ecommerce.service;

import com.pehlione.ecommerce.domain.Product;
import com.pehlione.ecommerce.domain.ProductImage;
import com.pehlione.ecommerce.dto.product.ProductImageResponse;
import com.pehlione.ecommerce.repository.ProductImageRepository;
import com.pehlione.ecommerce.repository.ProductRepository;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.*;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

@Service
public class ProductImageService {

    private static final int MAX_IMAGES_PER_PRODUCT = 5;
    private static final long MAX_FILE_SIZE = 5 * 1024 * 1024;

    private final ProductService productService;
    private final ProductRepository productRepository;
    private final ProductImageRepository productImageRepository;

    public ProductImageService(
            ProductService productService,
            ProductRepository productRepository,
            ProductImageRepository productImageRepository
    ) {
        this.productService = productService;
        this.productRepository = productRepository;
        this.productImageRepository = productImageRepository;
    }

    public List<ProductImageResponse> uploadImages(Long productId, MultipartFile[] files) {
        Product product = productService.getProductOrThrow(productId);

        if (files == null || files.length == 0) {
            throw new IllegalArgumentException("At least one image is required.");
        }

        long existingCount = productImageRepository.countByProductId(productId);

        if (existingCount + files.length > MAX_IMAGES_PER_PRODUCT) {
            throw new IllegalArgumentException("Maximum 5 images are allowed per product.");
        }

        int nextOrder = (int) existingCount + 1;

        for (MultipartFile file : files) {
            validateImage(file);

            boolean primary = existingCount == 0 && nextOrder == 1;

            ProductImage image = storeImage(product, file, nextOrder, primary);
            product.getImages().add(image);

            nextOrder++;
        }

        Product saved = productRepository.save(product);

        return saved.getImages()
                .stream()
                .map(ProductImageResponse::new)
                .toList();
    }

    public void deleteImage(Long productId, Long imageId) {
        Product product = productService.getProductOrThrow(productId);

        ProductImage image = product.getImages()
                .stream()
                .filter(item -> item.getId().equals(imageId))
                .findFirst()
                .orElseThrow(() -> new IllegalArgumentException("Image not found: " + imageId));

        deletePhysicalFile(image);

        boolean deletedImageWasPrimary = image.isPrimaryImage();

        product.getImages().remove(image);
        productImageRepository.delete(image);

        if (deletedImageWasPrimary && !product.getImages().isEmpty()) {
            product.getImages().get(0).setPrimaryImage(true);
        }

        reorderImages(product);
        productRepository.save(product);
    }

    public ProductImageResponse setPrimaryImage(Long productId, Long imageId) {
        Product product = productService.getProductOrThrow(productId);

        ProductImage selected = product.getImages()
                .stream()
                .filter(item -> item.getId().equals(imageId))
                .findFirst()
                .orElseThrow(() -> new IllegalArgumentException("Image not found: " + imageId));

        for (ProductImage image : product.getImages()) {
            image.setPrimaryImage(image.getId().equals(selected.getId()));
        }

        productRepository.save(product);

        return new ProductImageResponse(selected);
    }

    private ProductImage storeImage(
            Product product,
            MultipartFile file,
            int imageOrder,
            boolean primary
    ) {
        try {
            String categorySlug = product.getCategory().getSlug();
            String productSlug = product.getSlug();
            String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd-HHmmss-SSS"));
            String extension = resolveExtension(file.getOriginalFilename(), file.getContentType());

            String storedFileName = productSlug + "-" + imageOrder + "-" + timestamp + extension;
            String relativeFolder = "products/" + categorySlug + "/" + productSlug;
            Path folderPath = Paths.get("uploads").resolve(relativeFolder);

            Files.createDirectories(folderPath);

            Path targetPath = folderPath.resolve(storedFileName);
            Files.copy(file.getInputStream(), targetPath, StandardCopyOption.REPLACE_EXISTING);

            String relativePath = relativeFolder + "/" + storedFileName;

            return new ProductImage(
                    product,
                    safeOriginalName(file.getOriginalFilename()),
                    storedFileName,
                    relativePath,
                    file.getContentType(),
                    file.getSize(),
                    imageOrder,
                    primary
            );
        } catch (IOException exception) {
            throw new IllegalStateException("Image could not be stored.", exception);
        }
    }

    private void validateImage(MultipartFile file) {
        if (file.isEmpty()) {
            throw new IllegalArgumentException("Empty file is not allowed.");
        }

        if (file.getSize() > MAX_FILE_SIZE) {
            throw new IllegalArgumentException("Image size must be less than 5MB.");
        }

        String contentType = file.getContentType();

        if (contentType == null ||
                !List.of("image/jpeg", "image/png", "image/webp").contains(contentType)) {
            throw new IllegalArgumentException("Only JPEG, PNG and WEBP images are allowed.");
        }
    }

    private String resolveExtension(String originalFileName, String contentType) {
        if ("image/jpeg".equals(contentType)) {
            return ".jpg";
        }

        if ("image/png".equals(contentType)) {
            return ".png";
        }

        if ("image/webp".equals(contentType)) {
            return ".webp";
        }

        if (originalFileName != null && originalFileName.contains(".")) {
            return originalFileName.substring(originalFileName.lastIndexOf(".")).toLowerCase();
        }

        return ".img";
    }

    private String safeOriginalName(String originalFileName) {
        if (originalFileName == null || originalFileName.isBlank()) {
            return "unknown";
        }

        return originalFileName.replaceAll("[^a-zA-Z0-9._-]", "_");
    }

    private void deletePhysicalFile(ProductImage image) {
        try {
            Path filePath = Paths.get("uploads").resolve(image.getRelativePath());

            if (Files.exists(filePath)) {
                Files.delete(filePath);
            }
        } catch (IOException exception) {
            throw new IllegalStateException("Image file could not be deleted.", exception);
        }
    }

    private void reorderImages(Product product) {
        int order = 1;

        for (ProductImage image : product.getImages()) {
            image.setImageOrder(order);
            order++;
        }
    }
}

package com.nguyentuanduc.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import com.nguyentuanduc.entity.converter.StringListConverter;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "products")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Product {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(updatable = false, nullable = false)
    private UUID id;

    @Column(nullable = false, unique = true)
    private String slug;

    @Column(name = "product_name", nullable = false, length = 255)
    private String productName;

    @Column(length = 255)
    private String sku;

    @Column(name = "sale_price", nullable = false)
    private BigDecimal salePrice;

    @Column(name = "compare_price")
    private BigDecimal comparePrice;

    @Column(name = "buying_price")
    private BigDecimal buyingPrice;

    @Column(nullable = false)
    @Builder.Default
    private Integer quantity = 0;

    @Column(name = "short_description", nullable = false, length = 165)
    private String shortDescription;

    @Column(name = "product_description", nullable = false, columnDefinition = "TEXT")
    private String productDescription;

    @Column(name = "product_type", length = 64)
    @Builder.Default
    private String productType = "simple";

    @Builder.Default
    private Boolean published = false;

    @Column(name = "disable_out_of_stock", nullable = false)
    @Builder.Default
    private Boolean disableOutOfStock = true;

    @Column(columnDefinition = "TEXT")
    private String note;

    @Column(name = "created_by")
    private UUID createdBy;

    @Column(name = "updated_by")
    private UUID updatedBy;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    // ── Additional fields to support e_commerce_app_design (Flutter) ────
    @Column(length = 255)
    private String brand;

    @Convert(converter = StringListConverter.class)
    @Column(name = "image_urls", columnDefinition = "TEXT")
    @Builder.Default
    private List<String> imageUrls = new ArrayList<>();

    @Convert(converter = StringListConverter.class)
    @Column(name = "colors", columnDefinition = "TEXT")
    @Builder.Default
    private List<String> colors = new ArrayList<>();

    @Convert(converter = StringListConverter.class)
    @Column(name = "sizes", columnDefinition = "TEXT")
    @Builder.Default
    private List<String> sizes = new ArrayList<>();

    @Builder.Default
    private Double rating = 0.0;

    @Column(name = "review_count")
    @Builder.Default
    private Integer reviewCount = 0;

    @Column(name = "is_new")
    @Builder.Default
    private Boolean isNew = false;

    @Column(name = "discount_percent")
    private Integer discountPercent;
}

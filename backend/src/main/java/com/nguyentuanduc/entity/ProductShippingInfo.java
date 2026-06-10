package com.nguyentuanduc.entity;

import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.util.UUID;

@Entity
@Table(name = "product_shipping_info")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ProductShippingInfo {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(updatable = false, nullable = false)
    private UUID id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id")
    private Product product;

    @Column(nullable = false)
    @Builder.Default
    private BigDecimal weight = BigDecimal.ZERO;

    @Column(name = "weight_unit", length = 10)
    private String weightUnit;

    @Column(nullable = false)
    @Builder.Default
    private BigDecimal volume = BigDecimal.ZERO;

    @Column(name = "volume_unit", length = 10)
    private String volumeUnit;

    @Column(name = "dimension_width", nullable = false)
    @Builder.Default
    private BigDecimal dimensionWidth = BigDecimal.ZERO;

    @Column(name = "dimension_height", nullable = false)
    @Builder.Default
    private BigDecimal dimensionHeight = BigDecimal.ZERO;

    @Column(name = "dimension_depth", nullable = false)
    @Builder.Default
    private BigDecimal dimensionDepth = BigDecimal.ZERO;

    @Column(name = "dimension_unit", length = 10)
    private String dimensionUnit;
}

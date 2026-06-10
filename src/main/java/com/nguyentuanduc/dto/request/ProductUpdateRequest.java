package com.nguyentuanduc.dto.request;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ProductUpdateRequest {
    private String productName;
    private String brand;
    private BigDecimal salePrice;
    private BigDecimal comparePrice;
    private String shortDescription;
    private String productDescription;
    private List<String> tags; // ví dụ: ["New"], ["Sale"], ["New", "Sale"]
    private Integer discountPercent;
}

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
public class ProductCreateRequest {
    private String productName;
    private String brand;
    private BigDecimal salePrice;
    private BigDecimal comparePrice;
    private String shortDescription;
    private String productDescription;
    private String categoryName; // E.g. "Women", "Men", "Kids"
    private List<String> tags; // E.g. ["New"], ["Sale"]
    private Integer discountPercent;
    private List<String> imageUrls;
    private List<String> colors;
    private List<String> sizes;
}

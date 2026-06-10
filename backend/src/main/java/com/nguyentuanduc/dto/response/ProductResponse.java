package com.nguyentuanduc.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ProductResponse {
    private String id;
    private String name;
    private String brand;
    private Double price;
    private Double originalPrice;
    private List<String> imageUrls;
    private List<String> colors;
    private List<String> sizes;
    private Double rating;
    private Integer reviewCount;
    private Boolean isNew;
    private Integer discountPercent;
    private String category;
    private String description;
    private Boolean isFavorite;
}

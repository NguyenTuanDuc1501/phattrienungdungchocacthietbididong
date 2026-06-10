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
public class ReviewResponse {
    private String id;
    private String productId;
    private String customerId;
    private String customerName;
    private String customerAvatar;
    private Integer rating;
    private String title;
    private String comment;
    private List<String> imageUrls;
    private Integer helpfulCount;
    private String createdAt;
}

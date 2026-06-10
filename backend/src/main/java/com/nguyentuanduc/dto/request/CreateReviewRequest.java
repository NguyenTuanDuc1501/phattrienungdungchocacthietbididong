package com.nguyentuanduc.dto.request;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CreateReviewRequest {
    private String productId;
    private Integer rating;
    private String title;
    private String comment;
    private List<String> imageUrls;
}

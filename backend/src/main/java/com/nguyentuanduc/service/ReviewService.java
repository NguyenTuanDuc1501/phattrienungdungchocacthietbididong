package com.nguyentuanduc.service;

import com.nguyentuanduc.dto.request.CreateReviewRequest;
import com.nguyentuanduc.dto.response.ReviewResponse;
import com.nguyentuanduc.entity.StaffAccount;
import com.nguyentuanduc.entity.Product;
import com.nguyentuanduc.entity.ProductReview;
import com.nguyentuanduc.entity.ReviewImage;
import com.nguyentuanduc.repository.StaffAccountRepository;
import com.nguyentuanduc.repository.ProductRepository;
import com.nguyentuanduc.repository.ProductReviewRepository;
import com.nguyentuanduc.repository.ReviewImageRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ReviewService {

    private final ProductReviewRepository reviewRepository;
    private final ReviewImageRepository imageRepository;
    private final ProductRepository productRepository;
    private final StaffAccountRepository staffAccountRepository;

    public List<ReviewResponse> getReviewsByProductId(UUID productId) {
        return reviewRepository.findByProductIdOrderByCreatedAtDesc(productId).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Transactional
    public ReviewResponse createReview(CreateReviewRequest request, UUID userId) {
        UUID productId = UUID.fromString(request.getProductId());
        
        // Kiểm tra xem đã review chưa
        reviewRepository.findByProductIdAndUserId(productId, userId).ifPresent(r -> {
            throw new RuntimeException("Bạn đã đánh giá sản phẩm này rồi");
        });

        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy sản phẩm"));

        StaffAccount user = staffAccountRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy tài khoản người dùng"));

        ProductReview review = ProductReview.builder()
                .product(product)
                .user(user)
                .rating(request.getRating())
                .title(request.getTitle())
                .comment(request.getComment())
                .isApproved(true)
                .build();

        ProductReview savedReview = reviewRepository.save(review);

        if (request.getImageUrls() != null && !request.getImageUrls().isEmpty()) {
            List<ReviewImage> images = request.getImageUrls().stream()
                    .map(url -> ReviewImage.builder()
                            .review(savedReview)
                            .imageUrl(url)
                            .build())
                    .collect(Collectors.toList());
            imageRepository.saveAll(images);
            savedReview.setImages(images);
        }

        // Cập nhật rating và reviewCount cho Product
        Double avgRating = reviewRepository.findAverageRatingByProductId(productId);
        Long reviewCount = reviewRepository.countByProductId(productId);
        
        product.setRating(avgRating);
        product.setReviewCount(reviewCount.intValue());
        productRepository.save(product);

        return mapToResponse(savedReview);
    }

    @Transactional
    public void deleteReview(UUID reviewId, UUID userId) {
        ProductReview review = reviewRepository.findById(reviewId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy đánh giá"));

        if (!review.getUser().getId().equals(userId)) {
            throw new RuntimeException("Bạn không có quyền xóa đánh giá này");
        }

        UUID productId = review.getProduct().getId();

        reviewRepository.delete(review);

        // Cập nhật lại rating và reviewCount cho Product
        Product product = productRepository.findById(productId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy sản phẩm"));
                
        Double avgRating = reviewRepository.findAverageRatingByProductId(productId);
        Long reviewCount = reviewRepository.countByProductId(productId);

        product.setRating(avgRating);
        product.setReviewCount(reviewCount.intValue());
        productRepository.save(product);
    }

    private ReviewResponse mapToResponse(ProductReview review) {
        List<String> imageUrls = review.getImages().stream()
                .map(ReviewImage::getImageUrl)
                .collect(Collectors.toList());

        String userName = review.getUser().getFullName();
        String userAvatar = review.getUser().getAvatarUrl(); 

        return ReviewResponse.builder()
                .id(review.getId().toString())
                .productId(review.getProduct().getId().toString())
                .customerId(review.getUser().getId().toString()) // Map user.id sang customerId cho tương thích frontend
                .customerName(userName)
                .customerAvatar(userAvatar)
                .rating(review.getRating())
                .title(review.getTitle())
                .comment(review.getComment())
                .imageUrls(imageUrls)
                .helpfulCount(review.getHelpfulCount())
                .createdAt(review.getCreatedAt() != null ? review.getCreatedAt().toString() : null)
                .build();
    }
}

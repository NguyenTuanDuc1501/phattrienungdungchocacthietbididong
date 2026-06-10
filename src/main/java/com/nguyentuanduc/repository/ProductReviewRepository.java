package com.nguyentuanduc.repository;

import com.nguyentuanduc.entity.ProductReview;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface ProductReviewRepository extends JpaRepository<ProductReview, UUID> {
    List<ProductReview> findByProductIdOrderByCreatedAtDesc(UUID productId);
    Optional<ProductReview> findByProductIdAndUserId(UUID productId, UUID userId);
    
    @Query("SELECT COALESCE(AVG(pr.rating), 0.0) FROM ProductReview pr WHERE pr.product.id = :productId")
    Double findAverageRatingByProductId(@Param("productId") UUID productId);
    
    Long countByProductId(UUID productId);
}

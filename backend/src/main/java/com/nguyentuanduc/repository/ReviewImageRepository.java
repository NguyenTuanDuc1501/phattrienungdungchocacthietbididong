package com.nguyentuanduc.repository;

import com.nguyentuanduc.entity.ReviewImage;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface ReviewImageRepository extends JpaRepository<ReviewImage, UUID> {
    List<ReviewImage> findByReviewId(UUID reviewId);
    void deleteByReviewId(UUID reviewId);
}

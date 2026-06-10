package com.nguyentuanduc.repository;

import com.nguyentuanduc.entity.ProductCoupon;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface ProductCouponRepository extends JpaRepository<ProductCoupon, UUID> {
    List<ProductCoupon> findByProductId(UUID productId);
    List<ProductCoupon> findByCouponId(UUID couponId);
}

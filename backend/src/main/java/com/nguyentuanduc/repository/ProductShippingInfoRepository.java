package com.nguyentuanduc.repository;

import com.nguyentuanduc.entity.ProductShippingInfo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface ProductShippingInfoRepository extends JpaRepository<ProductShippingInfo, UUID> {
    Optional<ProductShippingInfo> findByProductId(UUID productId);
}

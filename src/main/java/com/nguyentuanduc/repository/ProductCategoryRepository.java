package com.nguyentuanduc.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.nguyentuanduc.entity.ProductCategory;

import java.util.List;
import java.util.UUID;

@Repository
public interface ProductCategoryRepository extends JpaRepository<ProductCategory, UUID> {
    List<ProductCategory> findByProductId(UUID productId);

    void deleteByProductId(UUID productId);
}

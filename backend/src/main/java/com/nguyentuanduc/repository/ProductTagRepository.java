package com.nguyentuanduc.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.nguyentuanduc.entity.ProductTag;
import com.nguyentuanduc.entity.ProductTagId;

import java.util.List;
import java.util.UUID;

@Repository
public interface ProductTagRepository extends JpaRepository<ProductTag, ProductTagId> {
    List<ProductTag> findByProductId(UUID productId);

    void deleteByProductId(UUID productId);
}

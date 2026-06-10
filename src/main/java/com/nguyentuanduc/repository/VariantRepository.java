package com.nguyentuanduc.repository;

import com.nguyentuanduc.entity.Variant;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface VariantRepository extends JpaRepository<Variant, UUID> {
    List<Variant> findByProductId(UUID productId);
    List<Variant> findByVariantOptionRefId(UUID variantOptionRefId);
}

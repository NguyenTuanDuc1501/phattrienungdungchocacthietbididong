package com.nguyentuanduc.repository;

import com.nguyentuanduc.entity.VariantValue;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface VariantValueRepository extends JpaRepository<VariantValue, UUID> {
    List<VariantValue> findByVariantId(UUID variantId);
}

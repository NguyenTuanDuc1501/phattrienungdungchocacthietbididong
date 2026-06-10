package com.nguyentuanduc.repository;

import com.nguyentuanduc.entity.ProductSupplier;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface ProductSupplierRepository extends JpaRepository<ProductSupplier, UUID> {
    List<ProductSupplier> findByProductId(UUID productId);
    List<ProductSupplier> findBySupplierId(UUID supplierId);
}

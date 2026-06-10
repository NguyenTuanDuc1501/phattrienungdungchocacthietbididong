package com.nguyentuanduc.repository;

import com.nguyentuanduc.entity.Sell;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface SellRepository extends JpaRepository<Sell, UUID> {
    Optional<Sell> findByProductId(UUID productId);
}

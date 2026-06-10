package com.nguyentuanduc.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import com.nguyentuanduc.entity.Product;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface ProductRepository extends JpaRepository<Product, UUID> {

    Optional<Product> findBySlug(String slug);

    List<Product> findByIsNewTrue();

    @Query("SELECT p FROM Product p WHERE p.discountPercent IS NOT NULL AND p.discountPercent > 0")
    List<Product> findSaleProducts();

    @Query("SELECT p FROM Product p JOIN ProductCategory pc ON p.id = pc.product.id WHERE LOWER(pc.category.categoryName) = LOWER(:categoryName)")
    List<Product> findByCategoryName(@Param("categoryName") String categoryName);

    @Query("SELECT p FROM Product p JOIN ProductCategory pc ON p.id = pc.product.id WHERE pc.category.id = :categoryId")
    List<Product> findByCategoryId(@Param("categoryId") UUID categoryId);

    @Query("SELECT p FROM Product p JOIN ProductCategory pc ON p.id = pc.product.id WHERE pc.category.id IN :categoryIds")
    List<Product> findByCategoryIds(@Param("categoryIds") List<UUID> categoryIds);
}

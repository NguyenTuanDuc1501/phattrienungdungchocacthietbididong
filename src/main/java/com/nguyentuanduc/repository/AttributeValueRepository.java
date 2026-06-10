package com.nguyentuanduc.repository;

import com.nguyentuanduc.entity.AttributeValue;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface AttributeValueRepository extends JpaRepository<AttributeValue, UUID> {
    List<AttributeValue> findByAttributeId(UUID attributeId);
}

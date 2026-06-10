package com.nguyentuanduc.repository;

import com.nguyentuanduc.entity.ShippingCountryZone;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface ShippingCountryZoneRepository extends JpaRepository<ShippingCountryZone, UUID> {
}

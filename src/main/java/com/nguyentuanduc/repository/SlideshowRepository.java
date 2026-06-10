package com.nguyentuanduc.repository;

import com.nguyentuanduc.entity.Slideshow;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface SlideshowRepository extends JpaRepository<Slideshow, UUID> {
    List<Slideshow> findByPublishedTrueOrderByDisplayOrderAsc();
}

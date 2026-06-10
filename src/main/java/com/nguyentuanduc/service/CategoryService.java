package com.nguyentuanduc.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.nguyentuanduc.dto.response.CategoryResponse;
import com.nguyentuanduc.entity.Category;
import com.nguyentuanduc.repository.CategoryRepository;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class CategoryService {

    private final CategoryRepository categoryRepository;

    public List<CategoryResponse> getCategories(UUID parentId) {
        List<Category> categories;
        if (parentId == null) {
            categories = categoryRepository.findByParentIsNullAndActiveTrue();
        } else {
            categories = categoryRepository.findByParentIdAndActiveTrue(parentId);
        }
        return categories.stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    public List<CategoryResponse> getAllCategories() {
        return categoryRepository.findAll().stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    private CategoryResponse mapToResponse(Category category) {
        boolean hasChildren = categoryRepository.countByParentId(category.getId()) > 0;
        return CategoryResponse.builder()
                .id(category.getId().toString())
                .name(category.getCategoryName())
                .slug(category.getSlug())
                .parentId(category.getParent() != null ? category.getParent().getId().toString() : null)
                .imageUrl(category.getImageUrl())
                .hasChildren(hasChildren)
                .build();
    }
}

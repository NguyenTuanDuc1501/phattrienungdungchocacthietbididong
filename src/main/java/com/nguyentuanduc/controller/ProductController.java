package com.nguyentuanduc.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.nguyentuanduc.dto.request.ProductCreateRequest;
import com.nguyentuanduc.dto.request.ProductUpdateRequest;
import com.nguyentuanduc.dto.response.ApiResponse;
import com.nguyentuanduc.dto.response.ProductResponse;
import com.nguyentuanduc.service.ProductService;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/products")
@RequiredArgsConstructor
public class ProductController {

    private final ProductService productService;

    @GetMapping
    public ResponseEntity<ApiResponse<List<ProductResponse>>> getAllProducts() {
        List<ProductResponse> products = productService.getAllProducts();
        return ResponseEntity.ok(ApiResponse.success("Lấy danh sách sản phẩm thành công", products));
    }

    @GetMapping("/new")
    public ResponseEntity<ApiResponse<List<ProductResponse>>> getNewProducts() {
        List<ProductResponse> products = productService.getNewProducts();
        return ResponseEntity.ok(ApiResponse.success("Lấy danh sách sản phẩm mới thành công", products));
    }

    @GetMapping("/sale")
    public ResponseEntity<ApiResponse<List<ProductResponse>>> getSaleProducts() {
        List<ProductResponse> products = productService.getSaleProducts();
        return ResponseEntity.ok(ApiResponse.success("Lấy danh sách sản phẩm giảm giá thành công", products));
    }

    @GetMapping("/category/{categoryName}")
    public ResponseEntity<ApiResponse<List<ProductResponse>>> getProductsByCategory(@PathVariable String categoryName) {
        List<ProductResponse> products = productService.getProductsByCategory(categoryName);
        return ResponseEntity.ok(ApiResponse.success("Lấy danh sách sản phẩm theo danh mục thành công", products));
    }

    @GetMapping("/by-category/{categoryId}")
    public ResponseEntity<ApiResponse<List<ProductResponse>>> getProductsByCategoryId(@PathVariable UUID categoryId) {
        List<ProductResponse> products = productService.getProductsByCategoryId(categoryId);
        return ResponseEntity.ok(ApiResponse.success("Lấy danh sách sản phẩm theo danh mục thành công", products));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<ProductResponse>> getProductById(@PathVariable UUID id) {
        ProductResponse product = productService.getProductById(id);
        return ResponseEntity.ok(ApiResponse.success("Lấy thông tin chi tiết sản phẩm thành công", product));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<ProductResponse>> updateProduct(@PathVariable UUID id,
            @RequestBody ProductUpdateRequest request) {
        ProductResponse updated = productService.updateProduct(id, request);
        return ResponseEntity.ok(ApiResponse.success("Cập nhật sản phẩm thành công", updated));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<ProductResponse>> createProduct(@RequestBody ProductCreateRequest request) {
        ProductResponse created = productService.createProduct(request);
        return ResponseEntity.ok(ApiResponse.success("Thêm sản phẩm mới thành công", created));
    }
}

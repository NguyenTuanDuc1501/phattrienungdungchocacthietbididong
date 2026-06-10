package com.nguyentuanduc.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.nguyentuanduc.dto.response.ApiResponse;
import com.nguyentuanduc.dto.response.UserResponse;
import com.nguyentuanduc.service.StaffAccountService;

@RestController
@RequestMapping("/api/user")
@RequiredArgsConstructor
public class StaffAccountController {

    private final StaffAccountService staffAccountService;

    /**
     * GET /api/user/me
     * Lấy thông tin tài khoản đang đăng nhập (cần Bearer token)
     */
    @GetMapping("/me")
    public ResponseEntity<ApiResponse<UserResponse>> getCurrentUser(Authentication authentication) {
        String userId = authentication.getName(); // getName() trả về userId (UUID)
        UserResponse user = staffAccountService.getCurrentUser(userId);
        return ResponseEntity.ok(ApiResponse.success("Lấy thông tin tài khoản thành công", user));
    }

    /**
     * DELETE /api/user/me
     * Xóa tài khoản đang đăng nhập (cần Bearer token)
     */
    @DeleteMapping("/me")
    public ResponseEntity<ApiResponse<Void>> deleteCurrentUser(Authentication authentication) {
        String userId = authentication.getName();
        staffAccountService.deleteCurrentUser(userId);
        return ResponseEntity.ok(ApiResponse.success("Xóa tài khoản thành công", null));
    }
}

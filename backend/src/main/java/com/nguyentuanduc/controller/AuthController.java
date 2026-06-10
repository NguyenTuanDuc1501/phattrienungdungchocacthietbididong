package com.nguyentuanduc.controller;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.nguyentuanduc.dto.request.LoginRequest;
import com.nguyentuanduc.dto.request.OAuth2Request;
import com.nguyentuanduc.dto.request.RefreshTokenRequest;
import com.nguyentuanduc.dto.request.RegisterRequest;
import com.nguyentuanduc.dto.response.ApiResponse;
import com.nguyentuanduc.dto.response.AuthResponse;
import com.nguyentuanduc.service.AuthService;
import com.nguyentuanduc.service.OAuth2Service;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;
    private final OAuth2Service oAuth2Service;

    /**
     * POST /api/auth/register
     * Đăng ký bằng email/password
     */
    @PostMapping("/register")
    public ResponseEntity<ApiResponse<AuthResponse>> register(
            @Valid @RequestBody RegisterRequest request) {
        AuthResponse response = authService.register(request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("Đăng ký thành công", response));
    }

    /**
     * POST /api/auth/login
     * Đăng nhập bằng email/password
     */
    @PostMapping("/login")
    public ResponseEntity<ApiResponse<AuthResponse>> login(
            @Valid @RequestBody LoginRequest request) {
        AuthResponse response = authService.login(request);
        return ResponseEntity.ok(ApiResponse.success("Đăng nhập thành công", response));
    }

    /**
     * POST /api/auth/logout
     * Đăng xuất (xóa refresh token)
     */
    @PostMapping("/logout")
    public ResponseEntity<ApiResponse<Void>> logout(
            @Valid @RequestBody RefreshTokenRequest request) {
        authService.logout(request.getRefreshToken());
        return ResponseEntity.ok(ApiResponse.success("Đăng xuất thành công", null));
    }

    /**
     * POST /api/auth/refresh
     * Làm mới access token
     */
    @PostMapping("/refresh")
    public ResponseEntity<ApiResponse<AuthResponse>> refreshToken(
            @Valid @RequestBody RefreshTokenRequest request) {
        AuthResponse response = authService.refreshToken(request.getRefreshToken());
        return ResponseEntity.ok(ApiResponse.success("Token đã được làm mới", response));
    }

    /**
     * POST /api/auth/oauth2/google
     * Đăng nhập bằng Google (gửi idToken từ Flutter)
     */
    @PostMapping("/oauth2/google")
    public ResponseEntity<ApiResponse<AuthResponse>> loginWithGoogle(
            @Valid @RequestBody OAuth2Request request) {
        AuthResponse response = oAuth2Service.loginWithGoogle(request.getToken(), request.isRegister());
        return ResponseEntity.ok(ApiResponse.success("Đăng nhập Google thành công", response));
    }

    /**
     * POST /api/auth/oauth2/facebook
     * Đăng nhập bằng Facebook (gửi accessToken từ Flutter)
     */
    @PostMapping("/oauth2/facebook")
    public ResponseEntity<ApiResponse<AuthResponse>> loginWithFacebook(
            @Valid @RequestBody OAuth2Request request) {
        AuthResponse response = oAuth2Service.loginWithFacebook(request.getToken(), request.isRegister());
        return ResponseEntity.ok(ApiResponse.success("Đăng nhập Facebook thành công", response));
    }
}

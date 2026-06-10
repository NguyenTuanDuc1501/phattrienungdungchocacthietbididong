package com.nguyentuanduc.controller;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.graphql.data.method.annotation.Argument;
import org.springframework.graphql.data.method.annotation.MutationMapping;
import org.springframework.graphql.data.method.annotation.QueryMapping;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;

import com.nguyentuanduc.dto.request.LoginRequest;
import com.nguyentuanduc.dto.request.OAuth2Request;
import com.nguyentuanduc.dto.request.RefreshTokenRequest;
import com.nguyentuanduc.dto.request.RegisterRequest;
import com.nguyentuanduc.dto.response.AuthResponse;
import com.nguyentuanduc.dto.response.UserResponse;
import com.nguyentuanduc.exception.CustomException;
import com.nguyentuanduc.service.AuthService;
import com.nguyentuanduc.service.OAuth2Service;
import com.nguyentuanduc.service.StaffAccountService;

@Controller
@RequiredArgsConstructor
public class AuthGraphqlController {

    private final AuthService authService;
    private final OAuth2Service oAuth2Service;
    private final StaffAccountService staffAccountService;

    @QueryMapping
    public UserResponse me(Authentication authentication) {
        if (authentication == null || authentication.getName() == null) {
            throw new CustomException("Bạn chưa đăng nhập", HttpStatus.UNAUTHORIZED);
        }
        return staffAccountService.getCurrentUser(authentication.getName());
    }

    @MutationMapping
    public AuthResponse register(@Argument @Valid RegisterRequest input) {
        return authService.register(input);
    }

    @MutationMapping
    public AuthResponse login(@Argument @Valid LoginRequest input) {
        return authService.login(input);
    }

    @MutationMapping
    public AuthResponse refreshToken(@Argument @Valid RefreshTokenRequest input) {
        return authService.refreshToken(input.getRefreshToken());
    }

    @MutationMapping
    public boolean logout(@Argument @Valid RefreshTokenRequest input) {
        authService.logout(input.getRefreshToken());
        return true;
    }

    @MutationMapping
    public AuthResponse loginWithGoogle(@Argument @Valid OAuth2Request input) {
        return oAuth2Service.loginWithGoogle(input.getToken(), input.isRegister());
    }

    @MutationMapping
    public AuthResponse loginWithFacebook(@Argument @Valid OAuth2Request input) {
        return oAuth2Service.loginWithFacebook(input.getToken(), input.isRegister());
    }
}

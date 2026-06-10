package com.nguyentuanduc.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.nguyentuanduc.config.JwtProperties;
import com.nguyentuanduc.dto.request.LoginRequest;
import com.nguyentuanduc.dto.request.RegisterRequest;
import com.nguyentuanduc.dto.response.AuthResponse;
import com.nguyentuanduc.dto.response.UserResponse;
import com.nguyentuanduc.entity.RefreshToken;
import com.nguyentuanduc.entity.Role;
import com.nguyentuanduc.entity.StaffAccount;
import com.nguyentuanduc.exception.CustomException;
import com.nguyentuanduc.repository.RefreshTokenRepository;
import com.nguyentuanduc.repository.RoleRepository;
import com.nguyentuanduc.repository.StaffAccountRepository;
import com.nguyentuanduc.security.JwtTokenProvider;

import java.time.LocalDateTime;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class AuthService {

    private final StaffAccountRepository staffAccountRepository;
    private final RoleRepository roleRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider jwtTokenProvider;
    private final AuthenticationManager authenticationManager;
    private final JwtProperties jwtProperties;

    /**
     * Đăng ký bằng email/password
     */
    @Transactional
    public AuthResponse register(RegisterRequest request) {
        String normalizedEmail = normalizeEmail(request.getEmail());

        if (staffAccountRepository.existsByEmail(normalizedEmail)) {
            throw new CustomException("Email đã được sử dụng", HttpStatus.CONFLICT);
        }

        Role defaultRole = roleRepository.findByRoleName("ROLE_USER")
                .orElseThrow(() -> new CustomException("Không tìm thấy vai trò ROLE_USER hệ thống",
                        HttpStatus.INTERNAL_SERVER_ERROR));

        StaffAccount user = StaffAccount.builder()
                .email(normalizedEmail)
                .password(passwordEncoder.encode(request.getPassword()))
                .fullName(request.getFullName().trim())
                .provider(StaffAccount.AuthProvider.LOCAL)
                .role(defaultRole)
                .isActive(true)
                .build();

        user = staffAccountRepository.save(user);
        log.info("User registered: {}", user.getEmail());
        return buildAuthResponse(user);
    }

    /**
     * Đăng nhập bằng email/password
     */
    @Transactional
    public AuthResponse login(LoginRequest request) {
        String normalizedEmail = normalizeEmail(request.getEmail());

        try {
            authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(
                            normalizedEmail, request.getPassword()));
        } catch (BadCredentialsException e) {
            throw new CustomException("Email hoặc password không đúng", HttpStatus.UNAUTHORIZED);
        }

        StaffAccount user = staffAccountRepository.findByEmail(normalizedEmail)
                .orElseThrow(() -> new CustomException("Không tìm thấy tài khoản", HttpStatus.NOT_FOUND));

        if (!user.getIsActive()) {
            throw new CustomException("Tài khoản đã bị vô hiệu hóa", HttpStatus.FORBIDDEN);
        }

        log.info("User logged in: {}", user.getEmail());
        return buildAuthResponse(user);
    }

    /**
     * Làm mới access token bằng refresh token
     */
    @Transactional
    public AuthResponse refreshToken(String refreshToken) {
        RefreshToken token = refreshTokenRepository.findByToken(refreshToken)
                .orElseThrow(() -> new CustomException("Refresh token không hợp lệ", HttpStatus.UNAUTHORIZED));

        if (token.getExpiresAt().isBefore(LocalDateTime.now())) {
            refreshTokenRepository.delete(token);
            throw new CustomException("Refresh token đã hết hạn, vui lòng đăng nhập lại",
                    HttpStatus.UNAUTHORIZED);
        }

        StaffAccount user = token.getUser();
        refreshTokenRepository.delete(token);

        return buildAuthResponse(user);
    }

    /**
     * Đăng xuất
     */
    @Transactional
    public void logout(String refreshToken) {
        refreshTokenRepository.deleteByToken(refreshToken);
        log.info("User logged out");
    }

    /**
     * Tạo AuthResponse (dùng chung cho LOCAL và OAuth2)
     */
    public AuthResponse buildAuthResponse(StaffAccount user) {
        String accessToken = jwtTokenProvider.generateAccessToken(user.getId(), user.getEmail());
        String refreshToken = createRefreshToken(user);

        return AuthResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .tokenType("Bearer")
                .user(UserResponse.fromUser(user))
                .build();
    }

    /**
     * Tạo và lưu refresh token mới
     */
    private String createRefreshToken(StaffAccount user) {
        // Xóa refresh token cũ của user
        refreshTokenRepository.deleteByUser(user);

        String tokenValue = UUID.randomUUID().toString().replace("-", "") +
                UUID.randomUUID().toString().replace("-", "");

        RefreshToken refreshToken = RefreshToken.builder()
                .token(tokenValue)
                .user(user)
                .expiresAt(LocalDateTime.now().plusSeconds(jwtProperties.refreshExpiration() / 1000))
                .build();

        refreshTokenRepository.save(refreshToken);
        return tokenValue;
    }

    private String normalizeEmail(String email) {
        return email.toLowerCase().trim();
    }
}

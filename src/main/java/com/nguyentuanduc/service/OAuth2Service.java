package com.nguyentuanduc.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

import com.nguyentuanduc.config.OAuth2Properties;
import com.nguyentuanduc.dto.response.AuthResponse;
import com.nguyentuanduc.entity.Role;
import com.nguyentuanduc.entity.StaffAccount;
import com.nguyentuanduc.exception.CustomException;
import com.nguyentuanduc.repository.RoleRepository;
import com.nguyentuanduc.repository.StaffAccountRepository;

import java.util.Map;
import java.util.Optional;

@Slf4j
@Service
@RequiredArgsConstructor
public class OAuth2Service {

    private final StaffAccountRepository staffAccountRepository;
    private final RoleRepository roleRepository;
    private final AuthService authService;
    private final OAuth2Properties oAuth2Properties;

    /**
     * Đăng nhập bằng Google
     * Flutter lấy idToken từ google_sign_in → gửi lên đây
     */
    @Transactional
    public AuthResponse loginWithGoogle(String idToken, boolean isRegister) {
        Map<String, Object> payload = verifyGoogleToken(idToken);

        String providerId = (String) payload.get("sub");
        String email = (String) payload.get("email");
        String fullName = (String) payload.get("name");
        String avatarUrl = (String) payload.get("picture");

        if (email == null || providerId == null) {
            throw new CustomException("Google token không chứa đủ thông tin", HttpStatus.BAD_REQUEST);
        }

        log.info("Google login: email={}, isRegister={}", email, isRegister);
        return processOAuth2Login(email, fullName, avatarUrl, providerId, StaffAccount.AuthProvider.GOOGLE, isRegister);
    }

    /**
     * Đăng nhập bằng Facebook
     * Flutter lấy accessToken từ flutter_facebook_auth → gửi lên đây
     */
    @Transactional
    public AuthResponse loginWithFacebook(String accessToken, boolean isRegister) {
        Map<String, Object> payload = verifyFacebookToken(accessToken);

        String providerId = (String) payload.get("id");
        String fullName = (String) payload.get("name");
        String email = (String) payload.get("email");

        // Facebook có thể không trả email nếu user không cấp quyền
        if (email == null || email.isBlank()) {
            email = providerId + "@facebook.placeholder.com";
        }

        // Lấy avatar URL
        String avatarUrl = null;
        Object pictureObj = payload.get("picture");
        if (pictureObj instanceof Map) {
            Object dataObj = ((Map<?, ?>) pictureObj).get("data");
            if (dataObj instanceof Map) {
                avatarUrl = (String) ((Map<?, ?>) dataObj).get("url");
            }
        }

        log.info("Facebook login: email={}, isRegister={}", email, isRegister);
        return processOAuth2Login(email, fullName, avatarUrl, providerId, StaffAccount.AuthProvider.FACEBOOK,
                isRegister);
    }

    // ==================== Private Methods ====================

    @SuppressWarnings("unchecked")
    private Map<String, Object> verifyGoogleToken(String idToken) {
        try {
            RestTemplate restTemplate = new RestTemplate();
            String url = "https://oauth2.googleapis.com/tokeninfo?id_token=" + idToken;
            Map<String, Object> payload = restTemplate.getForObject(url, Map.class);

            if (payload == null || payload.containsKey("error_description")) {
                throw new CustomException("Google token không hợp lệ", HttpStatus.UNAUTHORIZED);
            }

            // Verify audience - bảo mật quan trọng!
            String aud = (String) payload.get("aud");
            String expectedClientId = oAuth2Properties.google() != null ? oAuth2Properties.google().clientId() : null;
            if (expectedClientId == null || expectedClientId.isBlank()) {
                throw new CustomException("Thiếu cấu hình Google client id", HttpStatus.INTERNAL_SERVER_ERROR);
            }

            if (!expectedClientId.equals(aud)) {
                log.warn("Google token audience mismatch. Expected: {}, Got: {}", expectedClientId, aud);
                throw new CustomException("Google token không đúng ứng dụng", HttpStatus.UNAUTHORIZED);
            }

            return payload;
        } catch (CustomException e) {
            throw e;
        } catch (RestClientException e) {
            log.error("Google token verification failed: {}", e.getMessage());
            throw new CustomException("Không thể xác thực Google token", HttpStatus.UNAUTHORIZED);
        }
    }

    @SuppressWarnings("unchecked")
    private Map<String, Object> verifyFacebookToken(String accessToken) {
        try {
            RestTemplate restTemplate = new RestTemplate();
            String url = "https://graph.facebook.com/me"
                    + "?fields=id,name,email,picture"
                    + "&access_token=" + accessToken;

            Map<String, Object> payload = restTemplate.getForObject(url, Map.class);

            if (payload == null || payload.containsKey("error")) {
                throw new CustomException("Facebook token không hợp lệ", HttpStatus.UNAUTHORIZED);
            }

            return payload;
        } catch (CustomException e) {
            throw e;
        } catch (RestClientException e) {
            log.error("Facebook token verification failed: {}", e.getMessage());
            throw new CustomException("Không thể xác thực Facebook token", HttpStatus.UNAUTHORIZED);
        }
    }

    private AuthResponse processOAuth2Login(String email, String fullName, String avatarUrl,
            String providerId, StaffAccount.AuthProvider provider, boolean isRegister) {
        // Tìm user theo providerId trước
        Optional<StaffAccount> existingUser = staffAccountRepository.findByProviderIdAndProvider(providerId, provider);

        // Nếu không có, thử tìm theo email
        if (existingUser.isEmpty()) {
            existingUser = staffAccountRepository.findByEmail(email);
        }

        StaffAccount user;
        if (existingUser.isPresent()) {
            if (isRegister) {
                throw new CustomException("Tài khoản này đã tồn tại. Vui lòng sử dụng tính năng Đăng nhập.",
                        HttpStatus.CONFLICT);
            }
            // Cập nhật thông tin mới nhất từ OAuth2 provider
            user = existingUser.get();
            user.setFullName(fullName);
            user.setAvatarUrl(avatarUrl);
            user.setProviderId(providerId);
            user.setProvider(provider);
            log.info("OAuth2 user updated: {}", email);
        } else {
            if (!isRegister) {
                throw new CustomException("Tài khoản chưa tồn tại. Vui lòng đăng ký trước khi đăng nhập.",
                        HttpStatus.NOT_FOUND);
            }

            Role defaultRole = roleRepository.findByRoleName("ROLE_USER")
                    .orElseThrow(() -> new CustomException("Không tìm thấy vai trò ROLE_USER hệ thống",
                            HttpStatus.INTERNAL_SERVER_ERROR));

            // Tạo tài khoản mới
            user = StaffAccount.builder()
                    .email(email)
                    .fullName(fullName)
                    .avatarUrl(avatarUrl)
                    .provider(provider)
                    .providerId(providerId)
                    .role(defaultRole)
                    .isActive(true)
                    .build();
            log.info("OAuth2 new user created: {}", email);
        }

        user = staffAccountRepository.save(user);
        return authService.buildAuthResponse(user);
    }
}

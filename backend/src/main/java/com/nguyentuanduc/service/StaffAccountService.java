package com.nguyentuanduc.service;

import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.nguyentuanduc.dto.response.UserResponse;
import com.nguyentuanduc.entity.StaffAccount;
import com.nguyentuanduc.exception.CustomException;
import com.nguyentuanduc.repository.RefreshTokenRepository;
import com.nguyentuanduc.repository.StaffAccountRepository;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class StaffAccountService {

    private final StaffAccountRepository staffAccountRepository;
    private final RefreshTokenRepository refreshTokenRepository;

    @Transactional(readOnly = true)
    public UserResponse getCurrentUser(String userId) {
        StaffAccount user = staffAccountRepository.findById(UUID.fromString(userId))
                .orElseThrow(() -> new CustomException("Không tìm thấy tài khoản", HttpStatus.NOT_FOUND));
        return UserResponse.fromUser(user);
    }

    @Transactional
    public void deleteCurrentUser(String userId) {
        StaffAccount user = staffAccountRepository.findById(UUID.fromString(userId))
                .orElseThrow(() -> new CustomException("Không tìm thấy tài khoản", HttpStatus.NOT_FOUND));
        refreshTokenRepository.deleteByUser(user);
        staffAccountRepository.delete(user);
    }
}

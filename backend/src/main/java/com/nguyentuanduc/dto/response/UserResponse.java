package com.nguyentuanduc.dto.response;

import lombok.*;

import java.time.LocalDateTime;
import java.util.UUID;

import com.nguyentuanduc.entity.StaffAccount;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserResponse {

    private UUID id;
    private String email;
    private String fullName;
    private String avatarUrl;
    private StaffAccount.AuthProvider provider;
    private LocalDateTime createdAt;

    public static UserResponse fromUser(StaffAccount user) {
        return UserResponse.builder()
                .id(user.getId())
                .email(user.getEmail())
                .fullName(user.getFullName())
                .avatarUrl(user.getAvatarUrl())
                .provider(user.getProvider())
                .createdAt(user.getCreatedAt())
                .build();
    }
}

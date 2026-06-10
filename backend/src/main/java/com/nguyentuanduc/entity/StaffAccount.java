package com.nguyentuanduc.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "staff_accounts")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class StaffAccount {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(updatable = false, nullable = false)
    private UUID id;

    @Column(unique = true, nullable = false, length = 255)
    private String email;

    @Column(length = 255)
    private String password; // NULL nếu đăng nhập bằng OAuth2

    @Column(name = "full_name", length = 255)
    private String fullName;

    @Column(name = "avatar_url", columnDefinition = "TEXT")
    private String avatarUrl;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 50)
    private AuthProvider provider;

    @Column(name = "provider_id", length = 255)
    private String providerId;

    @Column(name = "is_active")
    @Builder.Default
    private Boolean isActive = true;

    // ── RBAC Relation ───────────────────────────────────────────────────
    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "role_id", nullable = false)
    private Role role;

    // ── New Attributes from Schema & Extended Proposals ─────────────────
    @Column(name = "first_name", length = 100)
    private String firstName;

    @Column(name = "last_name", length = 100)
    private String lastName;

    @Column(name = "phone_number", length = 100)
    private String phoneNumber;

    @Column(length = 50)
    private String gender; // Proposed: Giới tính

    @Column(name = "date_of_birth")
    private LocalDate dateOfBirth; // Proposed: Ngày sinh

    @Column(name = "hire_date")
    private LocalDate hireDate; // Proposed: Ngày vào làm (chỉ cho staff/admin)

    @Column(name = "last_login_at")
    private LocalDateTime lastLoginAt; // Proposed: Lần đăng nhập cuối

    @Column(name = "failed_login_attempts")
    @Builder.Default
    private Integer failedLoginAttempts = 0; // Proposed: Đếm số lần đăng nhập sai

    @Column(name = "lockout_until")
    private LocalDateTime lockoutUntil; // Proposed: Khoá tài khoản tạm thời tới khi nào

    @Column(columnDefinition = "TEXT")
    private String placeholder;

    @Column(name = "created_by")
    private UUID createdBy;

    @Column(name = "updated_by")
    private UUID updatedBy;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    public enum AuthProvider {
        LOCAL, // Đăng ký bằng email/password
        GOOGLE, // Đăng nhập bằng Google
        FACEBOOK // Đăng nhập bằng Facebook
    }
}

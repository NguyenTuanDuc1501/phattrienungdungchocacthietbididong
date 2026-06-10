package com.nguyentuanduc.security;

import lombok.RequiredArgsConstructor;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.nguyentuanduc.entity.StaffAccount;
import com.nguyentuanduc.repository.StaffAccountRepository;

import java.util.Collections;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class UserDetailsServiceImpl implements UserDetailsService {

    private final StaffAccountRepository staffAccountRepository;

    /**
     * Load user bằng email (dùng cho login email/password)
     */
    @Override
    @Transactional(readOnly = true)
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        StaffAccount user = staffAccountRepository.findByEmail(email.toLowerCase().trim())
                .orElseThrow(() -> new UsernameNotFoundException(
                        "Không tìm thấy tài khoản với email: " + email));
        return buildUserDetails(user);
    }

    /**
     * Load user bằng userId (dùng cho JWT filter)
     */
    @Transactional(readOnly = true)
    public UserDetails loadUserById(String userId) {
        StaffAccount user = staffAccountRepository.findById(UUID.fromString(userId))
                .orElseThrow(() -> new UsernameNotFoundException(
                        "Không tìm thấy tài khoản với id: " + userId));
        return buildUserDetails(user);
    }

    private UserDetails buildUserDetails(StaffAccount user) {
        String roleName = user.getRole() != null ? user.getRole().getRoleName() : "ROLE_USER";
        return new org.springframework.security.core.userdetails.User(
                user.getId().toString(),
                user.getPassword() != null ? user.getPassword() : "",
                user.getIsActive(),
                true, true, true,
                Collections.singletonList(new SimpleGrantedAuthority(roleName)));
    }
}

package com.nguyentuanduc.entity;

import jakarta.persistence.*;
import lombok.*;

import java.util.UUID;

@Entity
@Table(name = "roles")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Role {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(updatable = false, nullable = false)
    private UUID id;

    @Column(name = "role_name", unique = true, nullable = false, length = 255)
    private String roleName;

    @Column(columnDefinition = "TEXT")
    private String privileges;
}

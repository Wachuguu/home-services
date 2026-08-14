package com.tasker.model;

import jakarta.persistence.*;
import lombok.*;
import org.locationtech.jts.geom.Point;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "users")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@EntityListeners(AuditingEntityListener.class)
public class User {
    @Id
    @GeneratedValue
    private UUID id;

    private String email;
    private String passwordHash;
    private String fullName;
    private String phoneNumber;

    @Enumerated(EnumType.STRING)
    private UserRole role;

    private String profileImageUrl;

    @Column(columnDefinition = "geography(Point, 4326)")
    private Point location;

    private String address;

    @Builder.Default
    private Boolean isAvailable = true;

    @Builder.Default
    private BigDecimal rating = BigDecimal.ZERO;

    @Builder.Default
    private Integer totalReviews = 0;

    private String fcmToken;

    @CreatedDate
    private LocalDateTime createdAt;

    @LastModifiedDate
    private LocalDateTime updatedAt;

    @OneToMany(mappedBy = "provider")
    private List<ProviderSkill> skills;
}

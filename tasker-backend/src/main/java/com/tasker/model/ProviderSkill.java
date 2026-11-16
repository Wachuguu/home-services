package com.tasker.model;

import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "provider_skills", uniqueConstraints = {
        @UniqueConstraint(columnNames = {"provider_id", "category_id"})
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ProviderSkill {
    @Id
    @GeneratedValue
    private UUID id;

    @ManyToOne
    @JoinColumn(name = "provider_id")
    private User provider;

    @ManyToOne
    @JoinColumn(name = "category_id")
    private ServiceCategory category;

    private Integer experienceYears;
    private BigDecimal hourlyRate;

    @Builder.Default
    private Boolean verified = false;

    private LocalDateTime createdAt;
}

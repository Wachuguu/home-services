package com.homeServices.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.time.LocalDateTime;

public record CreateJobRequest(
        @NotNull Integer categoryId,
        @NotBlank String title,
        String description,
        @NotNull Double latitude,
        @NotNull Double longitude,
        String address,
        LocalDateTime scheduledAt,
        BigDecimal estimatedCost
) {}

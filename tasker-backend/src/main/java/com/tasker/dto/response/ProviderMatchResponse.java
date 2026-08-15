package com.homeServices.dto.response;

import java.math.BigDecimal;
import java.util.UUID;

public record ProviderMatchResponse(
        UUID providerId,
        String fullName,
        String phoneNumber,
        Double distanceKm,
        BigDecimal rating,
        Integer totalReviews,
        BigDecimal hourlyRate,
        Integer experienceYears,
        Boolean verified,
        String profileImageUrl
) {}

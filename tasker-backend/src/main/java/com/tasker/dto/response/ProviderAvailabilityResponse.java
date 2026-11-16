package com.tasker.dto.response;

import java.util.UUID;

public record ProviderAvailabilityResponse(
        UUID providerId,
        boolean isAvailable,
        String message
) {}

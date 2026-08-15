package com.homeServices.dto.request;

import jakarta.validation.constraints.NotNull;

public record UpdateLocationRequest(
        @NotNull Double latitude,
        @NotNull Double longitude,
        String address
) {}

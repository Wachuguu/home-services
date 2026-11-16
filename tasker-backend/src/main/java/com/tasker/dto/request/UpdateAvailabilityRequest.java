package com.tasker.dto.request;

import com.fasterxml.jackson.annotation.JsonAlias;
import jakarta.validation.constraints.NotNull;

public record UpdateAvailabilityRequest(
        @NotNull(message = "isAvailable must not be null")
        @JsonAlias({"available", "online", "isOnline"})
        Boolean isAvailable
) {}

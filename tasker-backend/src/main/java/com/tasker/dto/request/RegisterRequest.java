package com.tasker.dto.request;

import com.tasker.model.UserRole;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record RegisterRequest(
        @NotBlank String email,
        @NotBlank @Size(min = 8) String password,
        @NotBlank String fullName,
        @NotBlank String phoneNumber,
        @NotNull UserRole role
) {}

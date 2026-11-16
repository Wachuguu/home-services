package com.tasker.dto.response;

import com.tasker.model.UserRole;
import java.util.UUID;

public record AuthResponse(
        String token,
        String tokenType,
        UUID userId,
        UserRole role,
        String fullName
) {}

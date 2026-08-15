package com.homeServices.dto.response;

import com.homeServices.model.UserRole;
import java.util.UUID;

public record AuthResponse(
        String token,
        String tokenType,
        UUID userId,
        UserRole role,
        String fullName
) {}

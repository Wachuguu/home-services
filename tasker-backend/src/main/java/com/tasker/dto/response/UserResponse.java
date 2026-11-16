package com.tasker.dto.response;

import com.tasker.model.User;
import com.tasker.model.UserRole;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

public record UserResponse(
        UUID id,
        String email,
        String fullName,
        String phoneNumber,
        UserRole role,
        Double latitude,
        Double longitude,
        String address,
        Boolean isAvailable,
        BigDecimal rating,
        Integer totalReviews,
        List<SkillResponse> skills
) {
    public record SkillResponse(
            Integer categoryId,
            String categoryName,
            Integer experienceYears,
            BigDecimal hourlyRate,
            Boolean verified
    ) {}

    public static UserResponse fromEntity(User user) {
        Double lat = user.getLocation() != null ? user.getLocation().getY() : null;
        Double lng = user.getLocation() != null ? user.getLocation().getX() : null;

        List<SkillResponse> skillResponses = null;
        if (user.getSkills() != null) {
            skillResponses = user.getSkills().stream()
                    .map(skill -> new SkillResponse(
                            skill.getCategory().getId(),
                            skill.getCategory().getName(),
                            skill.getExperienceYears(),
                            skill.getHourlyRate(),
                            skill.getVerified()
                    ))
                    .collect(Collectors.toList());
        }

        return new UserResponse(
                user.getId(),
                user.getEmail(),
                user.getFullName(),
                user.getPhoneNumber(),
                user.getRole(),
                lat,
                lng,
                user.getAddress(),
                user.getIsAvailable(),
                user.getRating(),
                user.getTotalReviews(),
                skillResponses
        );
    }
}

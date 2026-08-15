package com.homeServices.dto.response;

import com.homeServices.model.Job;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

public record JobResponse(
        UUID id,
        UUID clientId,
        String clientName,
        UUID providerId,
        String providerName,
        Integer categoryId,
        String categoryName,
        String title,
        String description,
        String status,
        Double latitude,
        Double longitude,
        String address,
        BigDecimal estimatedCost,
        BigDecimal finalCost,
        LocalDateTime scheduledAt,
        LocalDateTime startedAt,
        LocalDateTime completedAt,
        LocalDateTime createdAt
) {
    public static JobResponse fromEntity(Job job) {
        Double lat = job.getLocation() != null ? job.getLocation().getY() : null;
        Double lng = job.getLocation() != null ? job.getLocation().getX() : null;

        return new JobResponse(
                job.getId(),
                job.getClient().getId(),
                job.getClient().getFullName(),
                job.getProvider() != null ? job.getProvider().getId() : null,
                job.getProvider() != null ? job.getProvider().getFullName() : null,
                job.getCategory().getId(),
                job.getCategory().getName(),
                job.getTitle(),
                job.getDescription(),
                job.getStatus().name(),
                lat,
                lng,
                job.getAddress(),
                job.getEstimatedCost(),
                job.getFinalCost(),
                job.getScheduledAt(),
                job.getStartedAt(),
                job.getCompletedAt(),
                job.getCreatedAt()
        );
    }
}

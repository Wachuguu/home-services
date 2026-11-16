package com.tasker.service;

import com.tasker.dto.response.ProviderAvailabilityResponse;
import com.tasker.dto.response.ProviderMatchResponse;
import com.tasker.exception.ResourceNotFoundException;
import com.tasker.model.User;
import com.tasker.repository.NearbyProviderProjection;
import com.tasker.repository.UserRepository;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Service
public class LocationService {

    private static final int DEFAULT_LIMIT = 50;
    private static final int MAX_LIMIT = 100;
    private static final int MAX_RADIUS_KM = 100;

    private final UserRepository userRepository;

    @Value("${app.search.default-radius-km:10}")
    private int defaultRadiusKm;

    public LocationService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public List<ProviderMatchResponse> findNearbyProviders(Integer categoryId, double latitude, double longitude, Integer radiusKm) {
        return findNearbyProviders(categoryId, latitude, longitude, radiusKm, null);
    }

    public List<ProviderMatchResponse> findNearbyProviders(Integer categoryId, double latitude, double longitude, Integer radiusKm, Integer limit) {
        validateSearchParams(categoryId, latitude, longitude, radiusKm, limit);

        int searchRadiusKm = (radiusKm != null) ? radiusKm : (defaultRadiusKm > 0 ? defaultRadiusKm : 10);
        double radiusMeters = searchRadiusKm * 1000.0;
        int searchLimit = (limit != null) ? limit : DEFAULT_LIMIT;

        List<NearbyProviderProjection> projections = userRepository.findNearbyAvailableProvidersByCategory(
                categoryId, longitude, latitude, radiusMeters, searchLimit);

        List<ProviderMatchResponse> responses = new ArrayList<>();
        for (NearbyProviderProjection p : projections) {
            Double distanceKm = p.getDistanceMeters() != null ? p.getDistanceMeters() / 1000.0 : 0.0;
            responses.add(new ProviderMatchResponse(
                    p.getProviderId(),
                    p.getFullName(),
                    p.getPhoneNumber(),
                    distanceKm,
                    p.getRating(),
                    p.getTotalReviews(),
                    p.getHourlyRate(),
                    p.getExperienceYears(),
                    p.getVerified(),
                    p.getProfileImageUrl()
            ));
        }
        return responses;
    }

    @Transactional
    public ProviderAvailabilityResponse updateProviderAvailability(UUID providerId, boolean isAvailable) {
        User user = userRepository.findById(providerId)
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", providerId));
        user.setIsAvailable(isAvailable);
        user = userRepository.save(user);
        return new ProviderAvailabilityResponse(
                user.getId(),
                Boolean.TRUE.equals(user.getIsAvailable()),
                "Provider availability updated successfully"
        );
    }

    private void validateSearchParams(Integer categoryId, double latitude, double longitude, Integer radiusKm, Integer limit) {
        if (categoryId == null || categoryId <= 0) {
            throw new IllegalArgumentException("Category ID must be provided and positive");
        }
        if (latitude < -90.0 || latitude > 90.0) {
            throw new IllegalArgumentException("Latitude must be between -90 and 90 degrees");
        }
        if (longitude < -180.0 || longitude > 180.0) {
            throw new IllegalArgumentException("Longitude must be between -180 and 180 degrees");
        }
        if (radiusKm != null && radiusKm <= 0) {
            throw new IllegalArgumentException("Radius must be greater than 0 km");
        }
        if (radiusKm != null && radiusKm > MAX_RADIUS_KM) {
            throw new IllegalArgumentException("Radius cannot exceed " + MAX_RADIUS_KM + " km");
        }
        if (limit != null && limit <= 0) {
            throw new IllegalArgumentException("Limit must be greater than 0");
        }
        if (limit != null && limit > MAX_LIMIT) {
            throw new IllegalArgumentException("Limit cannot exceed " + MAX_LIMIT);
        }
    }
}

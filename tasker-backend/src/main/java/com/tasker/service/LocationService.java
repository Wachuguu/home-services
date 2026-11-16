package com.tasker.service;

import com.tasker.dto.response.ProviderMatchResponse;
import com.tasker.model.User;
import com.tasker.repository.UserRepository;
import org.locationtech.jts.geom.Coordinate;
import org.locationtech.jts.geom.GeometryFactory;
import org.locationtech.jts.geom.Point;
import org.locationtech.jts.geom.PrecisionModel;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

@Service
public class LocationService {

    private final UserRepository userRepository;
    private final GeometryFactory geometryFactory = new GeometryFactory(new PrecisionModel(), 4326);

    @Value("${app.search.default-radius-km:10}")
    private int defaultRadiusKm;

    public LocationService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public List<ProviderMatchResponse> findNearbyProviders(Integer categoryId, double latitude, double longitude, Integer radiusKm) {
        Point point = geometryFactory.createPoint(new Coordinate(longitude, latitude));
        int searchRadiusKm = radiusKm != null ? radiusKm : defaultRadiusKm;
        double radiusMeters = searchRadiusKm * 1000.0;

        List<User> users = userRepository.findNearbyAvailableProvidersByCategory(categoryId, point, radiusMeters);

        List<ProviderMatchResponse> responses = new ArrayList<>();
        for (User user : users) {
            // Note: The native query returns the user entity. In a real scenario, you'd extract the distance and skill info
            // from the result set directly using an interface projection. For simplicity, we just return the user details here.
            // A more complex query mapper might be needed for full accuracy of distance and specific skill rate.
            responses.add(new ProviderMatchResponse(
                    user.getId(),
                    user.getFullName(),
                    user.getPhoneNumber(),
                    0.0, // distanceKm would ideally be mapped from ST_Distance
                    user.getRating(),
                    user.getTotalReviews(),
                    BigDecimal.ZERO, // hourlyRate mapped from projection
                    0, // experienceYears
                    true, // verified
                    user.getProfileImageUrl()
            ));
        }
        return responses;
    }
}

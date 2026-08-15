package com.homeServices.service;

import com.homeServices.dto.request.UpdateLocationRequest;
import com.homeServices.dto.response.UserResponse;
import com.homeServices.exception.ResourceNotFoundException;
import com.homeServices.model.User;
import com.homeServices.repository.ProviderSkillRepository;
import com.homeServices.repository.UserRepository;
import org.locationtech.jts.geom.Coordinate;
import org.locationtech.jts.geom.GeometryFactory;
import org.locationtech.jts.geom.Point;
import org.locationtech.jts.geom.PrecisionModel;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
public class UserService {

    private final UserRepository userRepository;
    private final ProviderSkillRepository providerSkillRepository;
    private final GeometryFactory geometryFactory = new GeometryFactory(new PrecisionModel(), 4326);

    public UserService(UserRepository userRepository, ProviderSkillRepository providerSkillRepository) {
        this.userRepository = userRepository;
        this.providerSkillRepository = providerSkillRepository;
    }

    public UserResponse getUserById(UUID id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", id));
        return UserResponse.fromEntity(user);
    }

    @Transactional
    public UserResponse updateLocation(UUID userId, UpdateLocationRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", userId));

        Point point = geometryFactory.createPoint(new Coordinate(request.longitude(), request.latitude()));
        user.setLocation(point);
        if (request.address() != null) {
            user.setAddress(request.address());
        }

        user = userRepository.save(user);
        return UserResponse.fromEntity(user);
    }

    @Transactional
    public void updateFcmToken(UUID userId, String fcmToken) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", userId));
        user.setFcmToken(fcmToken);
        userRepository.save(user);
    }

    public UserResponse getProviderProfile(UUID providerId) {
        User user = userRepository.findById(providerId)
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", providerId));
        return UserResponse.fromEntity(user);
    }
}

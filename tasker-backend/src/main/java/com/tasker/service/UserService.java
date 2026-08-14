package com.tasker.service;

import com.tasker.dto.request.UpdateLocationRequest;
import com.tasker.dto.response.UserResponse;
import com.tasker.exception.ResourceNotFoundException;
import com.tasker.model.User;
import com.tasker.repository.ProviderSkillRepository;
import com.tasker.repository.UserRepository;
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

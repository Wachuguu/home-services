package com.tasker.repository;

import com.tasker.model.User;
import org.locationtech.jts.geom.Point;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface UserRepository extends JpaRepository<User, UUID> {
    Optional<User> findByEmail(String email);
    Optional<User> findByPhoneNumber(String phoneNumber);
    boolean existsByEmail(String email);
    boolean existsByPhoneNumber(String phoneNumber);

    @Query(value = "SELECT " +
            "u.id AS provider_id, " +
            "u.full_name AS full_name, " +
            "u.phone_number AS phone_number, " +
            "u.rating AS rating, " +
            "u.total_reviews AS total_reviews, " +
            "u.profile_image_url AS profile_image_url, " +
            "ps.hourly_rate AS hourly_rate, " +
            "ps.experience_years AS experience_years, " +
            "ps.verified AS verified, " +
            "ST_Distance(u.location, ST_SetSRID(ST_MakePoint(:longitude, :latitude), 4326)::geography) AS distance_meters " +
            "FROM users u " +
            "JOIN provider_skills ps ON u.id = ps.provider_id " +
            "WHERE u.role = 'PROVIDER' " +
            "AND u.is_available = true " +
            "AND ps.category_id = :categoryId " +
            "AND u.location IS NOT NULL " +
            "AND ST_DWithin(u.location, ST_SetSRID(ST_MakePoint(:longitude, :latitude), 4326)::geography, :radiusMeters) " +
            "ORDER BY distance_meters ASC " +
            "LIMIT :limit", nativeQuery = true)
    List<NearbyProviderProjection> findNearbyAvailableProvidersByCategory(
            @Param("categoryId") Integer categoryId,
            @Param("longitude") double longitude,
            @Param("latitude") double latitude,
            @Param("radiusMeters") double radiusMeters,
            @Param("limit") int limit);

    default List<NearbyProviderProjection> findNearbyAvailableProvidersByCategory(
            Integer categoryId,
            Point point,
            double radiusMeters) {
        return findNearbyAvailableProvidersByCategory(categoryId, point.getX(), point.getY(), radiusMeters, 50);
    }
}

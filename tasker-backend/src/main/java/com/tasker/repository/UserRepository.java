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

    @Query(value = "SELECT u.*, ps.hourly_rate, ps.experience_years, ps.verified, ST_Distance(u.location, :point) as distance " +
            "FROM users u " +
            "JOIN provider_skills ps ON u.id = ps.provider_id " +
            "WHERE u.role = 'PROVIDER' AND u.is_available = true " +
            "AND ps.category_id = :categoryId " +
            "AND ST_DWithin(u.location, :point, :radiusMeters) " +
            "ORDER BY distance ASC", nativeQuery = true)
    List<User> findNearbyAvailableProvidersByCategory(@Param("categoryId") Integer categoryId, 
                                                      @Param("point") Point point, 
                                                      @Param("radiusMeters") double radiusMeters);
}

package com.homeServices.repository;

import com.homeServices.model.ProviderSkill;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface ProviderSkillRepository extends JpaRepository<ProviderSkill, UUID> {
    List<ProviderSkill> findByProviderId(UUID providerId);
    Optional<ProviderSkill> findByProviderIdAndCategoryId(UUID providerId, Integer categoryId);
    List<ProviderSkill> findByVerifiedFalse();
}

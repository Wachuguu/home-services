package com.tasker.repository;

import java.math.BigDecimal;
import java.util.UUID;

public interface NearbyProviderProjection {
    UUID getProviderId();
    String getFullName();
    String getPhoneNumber();
    Double getDistanceMeters();
    BigDecimal getRating();
    Integer getTotalReviews();
    BigDecimal getHourlyRate();
    Integer getExperienceYears();
    Boolean getVerified();
    String getProfileImageUrl();
}

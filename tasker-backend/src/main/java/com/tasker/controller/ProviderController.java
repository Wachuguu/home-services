package com.tasker.controller;

import com.tasker.dto.request.UpdateAvailabilityRequest;
import com.tasker.dto.response.ProviderAvailabilityResponse;
import com.tasker.dto.response.ProviderMatchResponse;
import com.tasker.model.UserRole;
import com.tasker.security.UserPrincipal;
import com.tasker.service.LocationService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/providers")
public class ProviderController {

    private final LocationService locationService;

    public ProviderController(LocationService locationService) {
        this.locationService = locationService;
    }

    @PutMapping("/me/availability")
    @PreAuthorize("hasRole('PROVIDER')")
    public ResponseEntity<ProviderAvailabilityResponse> updateAvailability(
            @AuthenticationPrincipal UserPrincipal principal,
            @RequestBody @Valid UpdateAvailabilityRequest request) {

        if (principal == null) {
            throw new AccessDeniedException("Authentication required");
        }
        if (principal.getRole() != UserRole.PROVIDER) {
            throw new AccessDeniedException("Only providers can update availability");
        }

        ProviderAvailabilityResponse response = locationService.updateProviderAvailability(
                principal.getId(), request.isAvailable());
        return ResponseEntity.ok(response);
    }

    @GetMapping("/nearby")
    public ResponseEntity<List<ProviderMatchResponse>> getNearbyProviders(
            @RequestParam Integer categoryId,
            @RequestParam double lat,
            @RequestParam double lng,
            @RequestParam(required = false) Integer radiusKm,
            @RequestParam(required = false) Integer limit) {
        return ResponseEntity.ok(locationService.findNearbyProviders(categoryId, lat, lng, radiusKm, limit));
    }
}

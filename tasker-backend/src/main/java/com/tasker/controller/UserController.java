package com.homeServices.controller;

import com.homeServices.dto.request.UpdateLocationRequest;
import com.homeServices.dto.response.ProviderMatchResponse;
import com.homeServices.dto.response.UserResponse;
import com.homeServices.security.UserPrincipal;
import com.homeServices.service.LocationService;
import com.homeServices.service.UserService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/users")
public class UserController {

    private final UserService userService;
    private final LocationService locationService;

    public UserController(UserService userService, LocationService locationService) {
        this.userService = userService;
        this.locationService = locationService;
    }

    @GetMapping("/me")
    public ResponseEntity<UserResponse> getCurrentUser(@AuthenticationPrincipal UserPrincipal principal) {
        return ResponseEntity.ok(userService.getUserById(principal.getId()));
    }

    @PutMapping("/me/location")
    public ResponseEntity<UserResponse> updateLocation(@AuthenticationPrincipal UserPrincipal principal,
                                                       @RequestBody @Valid UpdateLocationRequest request) {
        return ResponseEntity.ok(userService.updateLocation(principal.getId(), request));
    }

    @PutMapping("/me/fcm-token")
    public ResponseEntity<Void> updateFcmToken(@AuthenticationPrincipal UserPrincipal principal,
                                               @RequestBody Map<String, String> body) {
        userService.updateFcmToken(principal.getId(), body.get("fcmToken"));
        return ResponseEntity.ok().build();
    }

    @GetMapping("/providers/{categoryId}/nearby")
    public ResponseEntity<List<ProviderMatchResponse>> getNearbyProviders(
            @PathVariable Integer categoryId,
            @RequestParam double lat,
            @RequestParam double lng,
            @RequestParam(required = false) Integer radiusKm) {
        return ResponseEntity.ok(locationService.findNearbyProviders(categoryId, lat, lng, radiusKm));
    }
}

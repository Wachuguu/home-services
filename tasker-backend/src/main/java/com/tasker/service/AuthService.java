package com.homeServices.service;

import com.homeServices.dto.request.LoginRequest;
import com.homeServices.dto.request.RegisterRequest;
import com.homeServices.dto.response.AuthResponse;
import com.homeServices.exception.DuplicateResourceException;
import com.homeServices.exception.ResourceNotFoundException;
import com.homeServices.model.User;
import com.homeServices.repository.UserRepository;
import com.homeServices.security.JwtTokenProvider;
import com.homeServices.security.UserPrincipal;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AuthService {

    private final UserRepository userRepository;
    private final BCryptPasswordEncoder passwordEncoder;
    private final JwtTokenProvider jwtTokenProvider;

    public AuthService(UserRepository userRepository, BCryptPasswordEncoder passwordEncoder, JwtTokenProvider jwtTokenProvider) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtTokenProvider = jwtTokenProvider;
    }

    @Transactional
    public AuthResponse register(RegisterRequest request) {
        if (userRepository.existsByEmail(request.email())) {
            throw new DuplicateResourceException("Email already in use");
        }
        if (userRepository.existsByPhoneNumber(request.phoneNumber())) {
            throw new DuplicateResourceException("Phone number already in use");
        }

        User user = User.builder()
                .email(request.email())
                .passwordHash(passwordEncoder.encode(request.password()))
                .fullName(request.fullName())
                .phoneNumber(request.phoneNumber())
                .role(request.role())
                .build();

        user = userRepository.save(user);

        UserPrincipal principal = UserPrincipal.fromUser(user);
        String token = jwtTokenProvider.generateToken(principal);

        return new AuthResponse(token, "Bearer", user.getId(), user.getRole(), user.getFullName());
    }

    public AuthResponse login(LoginRequest request) {
        User user = userRepository.findByEmail(request.email())
                .orElseThrow(() -> new ResourceNotFoundException("User", "email", request.email()));

        if (!passwordEncoder.matches(request.password(), user.getPasswordHash())) {
            throw new RuntimeException("Invalid credentials"); // Could be custom exception
        }

        UserPrincipal principal = UserPrincipal.fromUser(user);
        String token = jwtTokenProvider.generateToken(principal);

        return new AuthResponse(token, "Bearer", user.getId(), user.getRole(), user.getFullName());
    }
}

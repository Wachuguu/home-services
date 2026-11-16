package com.tasker.service;

import com.tasker.dto.request.LoginRequest;
import com.tasker.dto.request.RegisterRequest;
import com.tasker.dto.response.AuthResponse;
import com.tasker.exception.DuplicateResourceException;
import com.tasker.exception.ResourceNotFoundException;
import com.tasker.model.User;
import com.tasker.repository.UserRepository;
import com.tasker.security.JwtTokenProvider;
import com.tasker.security.UserPrincipal;
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
        if (!request.email().contains("@")) {
            throw new IllegalArgumentException("missing required email syntax");
        }
        if (userRepository.existsByEmail(request.email())) {
            throw new DuplicateResourceException("email already exists");
        }
        if (userRepository.existsByPhoneNumber(request.phoneNumber())) {
            throw new DuplicateResourceException("there is a user that has the same registered number");
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

    @Transactional
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

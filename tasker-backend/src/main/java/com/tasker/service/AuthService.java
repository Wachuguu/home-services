package com.tasker.service;

import com.tasker.dto.request.LoginRequest;
import com.tasker.dto.request.RegisterRequest;
import com.tasker.dto.response.AuthResponse;
import com.tasker.exception.DuplicateResourceException;
import com.tasker.exception.ResourceNotFoundException;
import com.tasker.model.User;
import com.tasker.model.UserRole;
import com.tasker.repository.UserRepository;
import com.tasker.security.JwtTokenProvider;
import com.tasker.security.UserPrincipal;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AuthService {

    private static final Logger log = LoggerFactory.getLogger(AuthService.class);

    private final UserRepository userRepository;
    private final BCryptPasswordEncoder passwordEncoder;
    private final JwtTokenProvider jwtTokenProvider;

    @Value("${ADMIN_EMAIL:#{null}}")
    private String adminEmail;

    @Value("${ADMIN_PASSWORD:#{null}}")
    private String adminPassword;

    @Value("${ADMIN_PHONE:#{null}}")
    private String adminPhone;

    public AuthService(UserRepository userRepository, BCryptPasswordEncoder passwordEncoder, JwtTokenProvider jwtTokenProvider) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtTokenProvider = jwtTokenProvider;
    }

    @EventListener(ApplicationReadyEvent.class)
    @Transactional
    public void bootstrapAdmin() {
        if (adminEmail == null || adminEmail.isBlank() || adminPassword == null || adminPassword.isBlank()) {
            log.info("Admin bootstrap skipped: ADMIN_EMAIL or ADMIN_PASSWORD not set");
            return;
        }

        String email = adminEmail.trim();
        if (!email.contains("@")) {
            log.error("Admin bootstrap failed: ADMIN_EMAIL missing '@' character");
            return;
        }

        if (userRepository.existsByEmail(email)) {
            log.info("Admin user already exists with email: {}", email);
            return;
        }

        String phone = adminPhone != null && !adminPhone.isBlank() ? adminPhone.trim() : "0700000000";
        if (userRepository.existsByPhoneNumber(phone)) {
            phone = "07" + String.format("%08d", Math.abs(email.hashCode()) % 100000000);
        }

        User admin = User.builder()
                .email(email)
                .passwordHash(passwordEncoder.encode(adminPassword))
                .fullName("System Administrator")
                .phoneNumber(phone)
                .role(UserRole.ADMIN)
                .build();

        userRepository.save(admin);
        log.info("Successfully bootstrapped admin user with email: {}", email);
    }

    @Transactional
    public AuthResponse register(RegisterRequest request) {
        if (request.role() == null || request.role() == UserRole.ADMIN || (request.role() != UserRole.CLIENT && request.role() != UserRole.PROVIDER)) {
            throw new IllegalArgumentException("Registration accepts only CLIENT or PROVIDER role");
        }
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

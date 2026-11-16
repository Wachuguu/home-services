package com.tasker.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Arrays;
import java.util.Date;
import java.util.UUID;

@Component
public class JwtTokenProvider {

    private final Environment environment;

    @Value("${app.jwt.secret:#{null}}")
    private String jwtSecret;

    @Value("${app.jwt.expiration-ms:86400000}")
    private long jwtExpirationMs;

    public JwtTokenProvider(Environment environment) {
        this.environment = environment;
    }

    @PostConstruct
    public void validateSecret() {
        boolean isProd = Arrays.asList(environment.getActiveProfiles()).contains("prod");
        if (isProd) {
            if (jwtSecret == null || jwtSecret.isBlank()) {
                throw new IllegalStateException("JWT secret (app.jwt.secret / JWT_SECRET) is missing in prod profile");
            }
            if (jwtSecret.getBytes(StandardCharsets.UTF_8).length < 32) {
                throw new IllegalStateException("JWT secret must be at least 32 bytes (256 bits) in prod profile");
            }
        } else {
            if (jwtSecret == null || jwtSecret.isBlank()) {
                throw new IllegalStateException("JWT secret (app.jwt.secret) is missing");
            }
            if (jwtSecret.getBytes(StandardCharsets.UTF_8).length < 32) {
                throw new IllegalStateException("JWT secret must be at least 32 bytes (256 bits)");
            }
        }
    }

    private SecretKey getSigningKey() {
        return Keys.hmacShaKeyFor(jwtSecret.getBytes(StandardCharsets.UTF_8));
    }

    public String generateToken(UserPrincipal principal) {
        Date now = new Date();
        Date expiryDate = new Date(now.getTime() + jwtExpirationMs);

        return Jwts.builder()
                .subject(principal.getId().toString())
                .claim("role", principal.getRole().name())
                .issuedAt(now)
                .expiration(expiryDate)
                .signWith(getSigningKey())
                .compact();
    }

    public UUID getUserIdFromToken(String token) {
        Claims claims = Jwts.parser()
                .verifyWith(getSigningKey())
                .build()
                .parseSignedClaims(token)
                .getPayload();

        return UUID.fromString(claims.getSubject());
    }

    public boolean validateToken(String token) {
        try {
            Jwts.parser()
                    .verifyWith(getSigningKey())
                    .build()
                    .parseSignedClaims(token);
            return true;
        } catch (Exception ex) {
            return false;
        }
    }
}

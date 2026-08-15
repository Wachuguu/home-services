package com.tasker.service;

import com.tasker.repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.util.Map;
import java.util.UUID;

@Service
public class NotificationService {
    
    private static final Logger log = LoggerFactory.getLogger(NotificationService.class);
    private final UserRepository userRepository;

    public NotificationService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public void sendNotification(UUID userId, String title, String body, Map<String, String> data) {
        userRepository.findById(userId).ifPresent(user -> {
            if (user.getFcmToken() != null && !user.getFcmToken().isEmpty()) {
                try {
                    com.google.firebase.messaging.Message.Builder messageBuilder = com.google.firebase.messaging.Message.builder()
                            .setToken(user.getFcmToken())
                            .setNotification(com.google.firebase.messaging.Notification.builder()
                                    .setTitle(title)
                                    .setBody(body)
                                    .build());
                    
                    if (data != null && !data.isEmpty()) {
                        messageBuilder.putAllData(data);
                    }

                    com.google.firebase.messaging.FirebaseMessaging.getInstance().send(messageBuilder.build());
                    log.info("Sent FCM notification to user {}: Title: {}, Body: {}", userId, title, body);
                } catch (Exception e) {
                    log.error("Failed to send FCM notification to user {}", userId, e);
                }
            } else {
                log.warn("User {} has no FCM token. Skipping notification.", userId);
            }
        });
    }
}

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
                // In a real app, integrate Firebase Admin SDK here
                // Message message = Message.builder().setToken(user.getFcmToken()).setNotification(Notification.builder().setTitle(title).setBody(body).build()).putAllData(data).build();
                // FirebaseMessaging.getInstance().send(message);
                log.info("Sending FCM notification to user {}: Title: {}, Body: {}", userId, title, body);
            } else {
                log.warn("User {} has no FCM token. Skipping notification.", userId);
            }
        });
    }
}

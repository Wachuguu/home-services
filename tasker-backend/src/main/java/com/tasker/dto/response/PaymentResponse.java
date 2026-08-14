package com.tasker.dto.response;

import com.tasker.model.Payment;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

public record PaymentResponse(
        UUID id,
        UUID jobId,
        BigDecimal amount,
        String status,
        String mpesaReceiptNumber,
        LocalDateTime createdAt
) {
    public static PaymentResponse fromEntity(Payment payment) {
        return new PaymentResponse(
                payment.getId(),
                payment.getJob().getId(),
                payment.getAmount(),
                payment.getStatus().name(),
                payment.getMpesaReceiptNumber(),
                payment.getCreatedAt()
        );
    }
}

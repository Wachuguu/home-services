package com.homeServices.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.util.UUID;

public record InitiatePaymentRequest(
        @NotNull UUID jobId,
        @NotBlank String phoneNumber,
        @NotNull BigDecimal amount
) {}

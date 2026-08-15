package com.homeServices.controller;

import com.homeServices.dto.request.InitiatePaymentRequest;
import com.homeServices.dto.response.PaymentResponse;
import com.homeServices.security.UserPrincipal;
import com.homeServices.service.PaymentService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/payments")
public class PaymentController {

    private final PaymentService paymentService;

    public PaymentController(PaymentService paymentService) {
        this.paymentService = paymentService;
    }

    @PostMapping("/initiate")
    public ResponseEntity<PaymentResponse> initiatePayment(@AuthenticationPrincipal UserPrincipal principal,
                                                           @RequestBody @Valid InitiatePaymentRequest request) {
        return ResponseEntity.ok(paymentService.initiatePayment(principal.getId(), request));
    }

    @GetMapping("/{jobId}")
    public ResponseEntity<PaymentResponse> getPaymentByJobId(@PathVariable UUID jobId) {
        return ResponseEntity.ok(paymentService.getPaymentByJobId(jobId));
    }
}

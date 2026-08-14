package com.tasker.service;

import com.tasker.dto.request.InitiatePaymentRequest;
import com.tasker.dto.response.PaymentResponse;
import com.tasker.exception.InvalidJobStateException;
import com.tasker.exception.PaymentException;
import com.tasker.exception.ResourceNotFoundException;
import com.tasker.model.Job;
import com.tasker.model.JobStatus;
import com.tasker.model.Payment;
import com.tasker.model.PaymentStatus;
import com.tasker.repository.JobRepository;
import com.tasker.repository.PaymentRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Map;
import java.util.UUID;

@Service
public class PaymentService {

    private final PaymentRepository paymentRepository;
    private final JobRepository jobRepository;
    private final MpesaService mpesaService;
    private final NotificationService notificationService;

    public PaymentService(PaymentRepository paymentRepository, JobRepository jobRepository,
                          MpesaService mpesaService, NotificationService notificationService) {
        this.paymentRepository = paymentRepository;
        this.jobRepository = jobRepository;
        this.mpesaService = mpesaService;
        this.notificationService = notificationService;
    }

    @Transactional
    public PaymentResponse initiatePayment(UUID clientId, InitiatePaymentRequest request) {
        Job job = jobRepository.findById(request.jobId())
                .orElseThrow(() -> new ResourceNotFoundException("Job", "id", request.jobId()));

        if (job.getStatus() == JobStatus.COMPLETED || job.getStatus() == JobStatus.CANCELLED) {
            throw new InvalidJobStateException("Cannot initiate payment for completed or cancelled job");
        }

        Map<String, Object> mpesaResponse = mpesaService.initiateSTKPush(
                request.phoneNumber(), request.amount(), job.getId().toString());

        String checkoutRequestId = (String) mpesaResponse.get("CheckoutRequestID");
        if (checkoutRequestId == null) {
            throw new PaymentException("Failed to initiate payment");
        }

        Payment payment = Payment.builder()
                .job(job)
                .client(job.getClient())
                .provider(job.getProvider())
                .amount(request.amount())
                .status(PaymentStatus.PENDING)
                .mpesaCheckoutRequestId(checkoutRequestId)
                .build();

        payment = paymentRepository.save(payment);
        return PaymentResponse.fromEntity(payment);
    }

    @Transactional
    public void handleSTKCallback(Map<String, Object> callbackData) {
        try {
            Map<String, Object> body = (Map<String, Object>) callbackData.get("Body");
            Map<String, Object> stkCallback = (Map<String, Object>) body.get("stkCallback");
            String checkoutRequestId = (String) stkCallback.get("CheckoutRequestID");
            Integer resultCode = (Integer) stkCallback.get("ResultCode");

            Payment payment = paymentRepository.findByMpesaCheckoutRequestId(checkoutRequestId)
                    .orElseThrow(() -> new ResourceNotFoundException("Payment", "checkoutRequestId", checkoutRequestId));

            if (resultCode == 0) {
                payment.setStatus(PaymentStatus.HELD);
                payment.setEscrowHeldAt(LocalDateTime.now());
                
                Map<String, Object> callbackMetadata = (Map<String, Object>) stkCallback.get("CallbackMetadata");
                // Extract receipt number logic here
                payment.setMpesaReceiptNumber("DUMMY_RECEIPT"); // Placeholder
            } else {
                payment.setStatus(PaymentStatus.FAILED);
            }

            paymentRepository.save(payment);
        } catch (Exception e) {
            // Log error
        }
    }

    @Transactional
    public PaymentResponse releasePayment(UUID jobId) {
        Payment payment = paymentRepository.findByJobId(jobId)
                .orElseThrow(() -> new ResourceNotFoundException("Payment", "jobId", jobId));

        if (payment.getStatus() != PaymentStatus.HELD) {
            throw new PaymentException("Payment is not in HELD state");
        }

        String providerPhone = payment.getProvider().getPhoneNumber();
        Map<String, Object> result = mpesaService.initiateB2CPayment(providerPhone, payment.getAmount(), "Job completed");

        payment.setStatus(PaymentStatus.RELEASED);
        payment.setReleasedAt(LocalDateTime.now());
        payment = paymentRepository.save(payment);

        return PaymentResponse.fromEntity(payment);
    }

    @Transactional
    public void handleB2CCallback(Map<String, Object> resultData) {
        // Handle B2C result
    }

    public PaymentResponse getPaymentByJobId(UUID jobId) {
        Payment payment = paymentRepository.findByJobId(jobId)
                .orElseThrow(() -> new ResourceNotFoundException("Payment", "jobId", jobId));
        return PaymentResponse.fromEntity(payment);
    }
}

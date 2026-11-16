package com.tasker.repository;

import com.tasker.model.Payment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface PaymentRepository extends JpaRepository<Payment, UUID> {
    Optional<Payment> findByJobId(UUID jobId);
    Optional<Payment> findByMpesaCheckoutRequestId(String checkoutRequestId);
}

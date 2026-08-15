package com.homeServices.repository;

import com.homeServices.model.Job;
import com.homeServices.model.JobStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface JobRepository extends JpaRepository<Job, UUID> {
    List<Job> findByClientIdOrderByCreatedAtDesc(UUID clientId);
    List<Job> findByProviderIdOrderByCreatedAtDesc(UUID providerId);
    List<Job> findByStatus(JobStatus status);
    List<Job> findByClientIdAndStatus(UUID clientId, JobStatus status);
}

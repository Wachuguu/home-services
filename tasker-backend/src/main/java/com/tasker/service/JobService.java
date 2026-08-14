package com.tasker.service;

import com.tasker.dto.request.CreateJobRequest;
import com.tasker.dto.response.JobResponse;
import com.tasker.exception.InvalidJobStateException;
import com.tasker.exception.ResourceNotFoundException;
import com.tasker.model.Job;
import com.tasker.model.JobStatus;
import com.tasker.model.ServiceCategory;
import com.tasker.model.User;
import com.tasker.repository.JobRepository;
import com.tasker.repository.ServiceCategoryRepository;
import com.tasker.repository.UserRepository;
import org.locationtech.jts.geom.Coordinate;
import org.locationtech.jts.geom.GeometryFactory;
import org.locationtech.jts.geom.Point;
import org.locationtech.jts.geom.PrecisionModel;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class JobService {

    private final JobRepository jobRepository;
    private final UserRepository userRepository;
    private final ServiceCategoryRepository serviceCategoryRepository;
    private final LocationService locationService;
    private final NotificationService notificationService;
    private final GeometryFactory geometryFactory = new GeometryFactory(new PrecisionModel(), 4326);

    public JobService(JobRepository jobRepository, UserRepository userRepository,
                      ServiceCategoryRepository serviceCategoryRepository,
                      LocationService locationService, NotificationService notificationService) {
        this.jobRepository = jobRepository;
        this.userRepository = userRepository;
        this.serviceCategoryRepository = serviceCategoryRepository;
        this.locationService = locationService;
        this.notificationService = notificationService;
    }

    @Transactional
    public JobResponse createJob(UUID clientId, CreateJobRequest request) {
        User client = userRepository.findById(clientId)
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", clientId));
        ServiceCategory category = serviceCategoryRepository.findById(request.categoryId())
                .orElseThrow(() -> new ResourceNotFoundException("ServiceCategory", "id", request.categoryId()));

        Point location = geometryFactory.createPoint(new Coordinate(request.longitude(), request.latitude()));

        Job job = Job.builder()
                .client(client)
                .category(category)
                .title(request.title())
                .description(request.description())
                .status(JobStatus.REQUESTED)
                .location(location)
                .address(request.address())
                .scheduledAt(request.scheduledAt())
                .estimatedCost(request.estimatedCost())
                .build();

        job = jobRepository.save(job);
        return JobResponse.fromEntity(job);
    }

    public JobResponse getJob(UUID jobId) {
        Job job = jobRepository.findById(jobId)
                .orElseThrow(() -> new ResourceNotFoundException("Job", "id", jobId));
        return JobResponse.fromEntity(job);
    }

    public List<JobResponse> getJobsByClient(UUID clientId) {
        return jobRepository.findByClientIdOrderByCreatedAtDesc(clientId).stream()
                .map(JobResponse::fromEntity).collect(Collectors.toList());
    }

    public List<JobResponse> getJobsByProvider(UUID providerId) {
        return jobRepository.findByProviderIdOrderByCreatedAtDesc(providerId).stream()
                .map(JobResponse::fromEntity).collect(Collectors.toList());
    }

    @Transactional
    public JobResponse matchProvider(UUID jobId, UUID providerId) {
        Job job = jobRepository.findById(jobId)
                .orElseThrow(() -> new ResourceNotFoundException("Job", "id", jobId));
        
        if (job.getStatus() != JobStatus.REQUESTED) {
            throw new InvalidJobStateException("Job must be in REQUESTED state to match a provider");
        }

        User provider = userRepository.findById(providerId)
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", providerId));

        job.setProvider(provider);
        job.setStatus(JobStatus.MATCHED);
        job = jobRepository.save(job);

        notificationService.sendNotification(providerId, "New Job Match", "You have been matched to a new job.", Map.of("jobId", jobId.toString()));

        return JobResponse.fromEntity(job);
    }

    @Transactional
    public JobResponse startJob(UUID jobId, UUID providerId) {
        Job job = jobRepository.findById(jobId)
                .orElseThrow(() -> new ResourceNotFoundException("Job", "id", jobId));

        if (job.getStatus() != JobStatus.MATCHED) {
            throw new InvalidJobStateException("Job must be in MATCHED state to start");
        }
        if (!job.getProvider().getId().equals(providerId)) {
            throw new InvalidJobStateException("Only the assigned provider can start the job");
        }

        job.setStatus(JobStatus.IN_PROGRESS);
        job.setStartedAt(LocalDateTime.now());
        job = jobRepository.save(job);

        return JobResponse.fromEntity(job);
    }

    @Transactional
    public JobResponse completeJob(UUID jobId, UUID providerId) {
        Job job = jobRepository.findById(jobId)
                .orElseThrow(() -> new ResourceNotFoundException("Job", "id", jobId));

        if (job.getStatus() != JobStatus.IN_PROGRESS) {
            throw new InvalidJobStateException("Job must be in IN_PROGRESS state to complete");
        }
        if (!job.getProvider().getId().equals(providerId)) {
            throw new InvalidJobStateException("Only the assigned provider can complete the job");
        }

        job.setStatus(JobStatus.COMPLETED);
        job.setCompletedAt(LocalDateTime.now());
        job = jobRepository.save(job);

        return JobResponse.fromEntity(job);
    }

    @Transactional
    public JobResponse cancelJob(UUID jobId, UUID userId) {
        Job job = jobRepository.findById(jobId)
                .orElseThrow(() -> new ResourceNotFoundException("Job", "id", jobId));

        if (job.getStatus() == JobStatus.COMPLETED || job.getStatus() == JobStatus.CANCELLED) {
            throw new InvalidJobStateException("Job cannot be cancelled in its current state");
        }

        job.setStatus(JobStatus.CANCELLED);
        job = jobRepository.save(job);

        return JobResponse.fromEntity(job);
    }
}

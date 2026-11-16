package com.tasker.controller;

import com.tasker.dto.request.CreateJobRequest;
import com.tasker.dto.response.JobResponse;
import com.tasker.model.UserRole;
import com.tasker.security.UserPrincipal;
import com.tasker.service.JobService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/jobs")
public class JobController {

    private final JobService jobService;

    public JobController(JobService jobService) {
        this.jobService = jobService;
    }

    @PostMapping
    public ResponseEntity<JobResponse> createJob(@AuthenticationPrincipal UserPrincipal principal,
                                                 @RequestBody @Valid CreateJobRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(jobService.createJob(principal.getId(), request));
    }

    @GetMapping("/{id}")
    public ResponseEntity<JobResponse> getJob(@PathVariable UUID id) {
        return ResponseEntity.ok(jobService.getJob(id));
    }

    @GetMapping("/my-jobs")
    public ResponseEntity<List<JobResponse>> getMyJobs(@AuthenticationPrincipal UserPrincipal principal) {
        if (principal.getRole() == UserRole.CLIENT) {
            return ResponseEntity.ok(jobService.getJobsByClient(principal.getId()));
        } else {
            return ResponseEntity.ok(jobService.getJobsByProvider(principal.getId()));
        }
    }

    @PostMapping("/{id}/match")
    public ResponseEntity<JobResponse> matchProvider(@PathVariable UUID id, @RequestBody Map<String, String> body) {
        UUID providerId = UUID.fromString(body.get("providerId"));
        return ResponseEntity.ok(jobService.matchProvider(id, providerId));
    }

    @PutMapping("/{id}/start")
    public ResponseEntity<JobResponse> startJob(@PathVariable UUID id, @AuthenticationPrincipal UserPrincipal principal) {
        return ResponseEntity.ok(jobService.startJob(id, principal.getId()));
    }

    @PutMapping("/{id}/complete")
    public ResponseEntity<JobResponse> completeJob(@PathVariable UUID id, @AuthenticationPrincipal UserPrincipal principal) {
        return ResponseEntity.ok(jobService.completeJob(id, principal.getId()));
    }

    @PutMapping("/{id}/cancel")
    public ResponseEntity<JobResponse> cancelJob(@PathVariable UUID id, @AuthenticationPrincipal UserPrincipal principal) {
        return ResponseEntity.ok(jobService.cancelJob(id, principal.getId()));
    }
}

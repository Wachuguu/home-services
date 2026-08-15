package com.homeServices.service;

import com.homeServices.model.Review;
import com.homeServices.model.Job;
import com.homeServices.model.JobStatus;
import com.homeServices.model.User;
import com.homeServices.repository.JobRepository;
import com.homeServices.repository.ReviewRepository;
import com.homeServices.repository.UserRepository;
import com.homeServices.exception.InvalidJobStateException;
import com.homeServices.exception.ResourceNotFoundException;
import com.homeServices.exception.DuplicateResourceException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;
import java.util.UUID;

@Service
public class ReviewService {

    private final ReviewRepository reviewRepository;
    private final UserRepository userRepository;
    private final JobRepository jobRepository;

    public ReviewService(ReviewRepository reviewRepository, UserRepository userRepository, JobRepository jobRepository) {
        this.reviewRepository = reviewRepository;
        this.userRepository = userRepository;
        this.jobRepository = jobRepository;
    }

    @Transactional
    public Review createReview(UUID reviewerId, UUID jobId, Integer rating, String comment) {
        Job job = jobRepository.findById(jobId)
                .orElseThrow(() -> new ResourceNotFoundException("Job", "id", jobId));

        if (job.getStatus() != JobStatus.COMPLETED) {
            throw new InvalidJobStateException("Can only review completed jobs");
        }

        if (reviewRepository.existsByJobId(jobId)) {
            throw new DuplicateResourceException("Review already exists for this job");
        }

        User reviewer = userRepository.findById(reviewerId)
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", reviewerId));
        
        User reviewee = job.getProvider();

        Review review = Review.builder()
                .job(job)
                .reviewer(reviewer)
                .reviewee(reviewee)
                .rating(rating)
                .comment(comment)
                .build();

        review = reviewRepository.save(review);

        // Update provider rating
        int totalReviews = reviewee.getTotalReviews() + 1;
        BigDecimal currentRating = reviewee.getRating();
        BigDecimal newRating = currentRating.multiply(new BigDecimal(totalReviews - 1))
                .add(new BigDecimal(rating))
                .divide(new BigDecimal(totalReviews), 2, RoundingMode.HALF_UP);

        reviewee.setTotalReviews(totalReviews);
        reviewee.setRating(newRating);
        userRepository.save(reviewee);

        return review;
    }

    public List<Review> getReviewsByProvider(UUID providerId) {
        return reviewRepository.findByRevieweeIdOrderByCreatedAtDesc(providerId);
    }
}

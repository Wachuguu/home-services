package com.tasker.service;

import com.tasker.model.ProviderSkill;
import com.tasker.repository.JobRepository;
import com.tasker.repository.PaymentRepository;
import com.tasker.repository.ProviderSkillRepository;
import com.tasker.repository.UserRepository;
import com.tasker.exception.ResourceNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
public class AdminService {

    private final ProviderSkillRepository providerSkillRepository;
    private final UserRepository userRepository;
    private final JobRepository jobRepository;
    private final PaymentRepository paymentRepository;

    public AdminService(ProviderSkillRepository providerSkillRepository, UserRepository userRepository,
                        JobRepository jobRepository, PaymentRepository paymentRepository) {
        this.providerSkillRepository = providerSkillRepository;
        this.userRepository = userRepository;
        this.jobRepository = jobRepository;
        this.paymentRepository = paymentRepository;
    }

    public List<ProviderSkill> getUnverifiedSkills() {
        return providerSkillRepository.findByVerifiedFalse();
    }

    @Transactional
    public ProviderSkill verifySkill(UUID skillId) {
        ProviderSkill skill = providerSkillRepository.findById(skillId)
                .orElseThrow(() -> new ResourceNotFoundException("ProviderSkill", "id", skillId));
        skill.setVerified(true);
        return providerSkillRepository.save(skill);
    }

    public Map<String, Long> getDashboardStats() {
        Map<String, Long> stats = new HashMap<>();
        stats.put("users", userRepository.count());
        stats.put("jobs", jobRepository.count());
        stats.put("payments", paymentRepository.count());
        return stats;
    }
}

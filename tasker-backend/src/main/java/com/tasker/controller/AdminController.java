package com.tasker.controller;

import com.tasker.model.ProviderSkill;
import com.tasker.service.AdminService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/admin")
public class AdminController {

    private final AdminService adminService;

    public AdminController(AdminService adminService) {
        this.adminService = adminService;
    }

    @GetMapping("/providers/unverified-skills")
    public ResponseEntity<List<ProviderSkill>> getUnverifiedSkills() {
        return ResponseEntity.ok(adminService.getUnverifiedSkills());
    }

    @PutMapping("/providers/skills/{skillId}/verify")
    public ResponseEntity<ProviderSkill> verifySkill(@PathVariable UUID skillId) {
        return ResponseEntity.ok(adminService.verifySkill(skillId));
    }

    @GetMapping("/stats")
    public ResponseEntity<Map<String, Long>> getDashboardStats() {
        return ResponseEntity.ok(adminService.getDashboardStats());
    }
}

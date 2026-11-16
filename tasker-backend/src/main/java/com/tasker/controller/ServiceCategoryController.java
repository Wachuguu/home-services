package com.tasker.controller;

import com.tasker.dto.response.ServiceCategoryResponse;
import com.tasker.exception.ResourceNotFoundException;
import com.tasker.repository.ServiceCategoryRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/categories")
public class ServiceCategoryController {

    private final ServiceCategoryRepository categoryRepository;

    public ServiceCategoryController(ServiceCategoryRepository categoryRepository) {
        this.categoryRepository = categoryRepository;
    }

    @GetMapping
    public ResponseEntity<List<ServiceCategoryResponse>> getAllCategories() {
        try {
            List<ServiceCategoryResponse> categories = categoryRepository.findAll().stream()
                    .map(ServiceCategoryResponse::fromEntity).collect(Collectors.toList());
            return ResponseEntity.ok(categories);
        } catch (Exception e) {
            return ResponseEntity.ok(new java.util.ArrayList<>());
        }
    }

    @GetMapping("/{id}")
    public ResponseEntity<ServiceCategoryResponse> getCategoryById(@PathVariable Integer id) {
        return ResponseEntity.ok(ServiceCategoryResponse.fromEntity(
                categoryRepository.findById(id)
                        .orElseThrow(() -> new ResourceNotFoundException("ServiceCategory", "id", id))
        ));
    }
}

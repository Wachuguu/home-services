package com.homeServices.controller;

import com.homeServices.dto.response.ServiceCategoryResponse;
import com.homeServices.exception.ResourceNotFoundException;
import com.homeServices.repository.ServiceCategoryRepository;
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

    @GetMapping("/")
    public ResponseEntity<List<ServiceCategoryResponse>> getAllCategories() {
        return ResponseEntity.ok(categoryRepository.findAll().stream()
                .map(ServiceCategoryResponse::fromEntity).collect(Collectors.toList()));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ServiceCategoryResponse> getCategoryById(@PathVariable Integer id) {
        return ResponseEntity.ok(ServiceCategoryResponse.fromEntity(
                categoryRepository.findById(id)
                        .orElseThrow(() -> new ResourceNotFoundException("ServiceCategory", "id", id))
        ));
    }
}

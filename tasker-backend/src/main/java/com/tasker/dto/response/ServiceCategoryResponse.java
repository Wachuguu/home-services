package com.homeServices.dto.response;

import com.homeServices.model.ServiceCategory;

import java.math.BigDecimal;

public record ServiceCategoryResponse(
        Integer id,
        String name,
        String description,
        String iconName,
        BigDecimal basePrice
) {
    public static ServiceCategoryResponse fromEntity(ServiceCategory category) {
        return new ServiceCategoryResponse(
                category.getId(),
                category.getName(),
                category.getDescription(),
                category.getIconName(),
                category.getBasePrice()
        );
    }
}

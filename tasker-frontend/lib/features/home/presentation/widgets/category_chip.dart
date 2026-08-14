import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../categories/domain/models/service_category.dart';

class CategoryChip extends StatelessWidget {
  final ServiceCategory category;
  final VoidCallback onTap;

  const CategoryChip({super.key, required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.backgroundElevated,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(ServiceCategory.getIconData(category.iconName), size: 18, color: AppColors.primaryBlueLight),
            const SizedBox(width: 8),
            Text(category.name, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

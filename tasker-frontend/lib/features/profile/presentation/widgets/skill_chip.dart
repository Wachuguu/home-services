import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

class SkillChip extends StatelessWidget {
  final String skillName;
  final IconData icon;
  final bool isVerified;

  const SkillChip({
    super.key,
    required this.skillName,
    required this.icon,
    this.isVerified = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isVerified ? AppColors.success.withOpacity(0.5) : AppColors.borderSubtle,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primaryBlueLight),
          const SizedBox(width: 8),
          Text(skillName, style: const TextStyle(fontSize: 14)),
          if (isVerified) ...[
            const SizedBox(width: 4),
            const Icon(Icons.verified, size: 14, color: AppColors.success),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

class JobStatusBadge extends StatelessWidget {
  final String status;
  const JobStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'REQUESTED': color = AppColors.warning; break;
      case 'MATCHED': color = AppColors.primaryBlueLight; break;
      case 'IN_PROGRESS': color = AppColors.primaryBlueLight; break;
      case 'COMPLETED': color = AppColors.success; break;
      case 'CANCELLED': color = AppColors.error; break;
      default: color = AppColors.textMuted;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status.replaceAll('_', ' '),
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../domain/models/job.dart';
import 'job_status_badge.dart';

class JobCard extends StatelessWidget {
  final Job job;

  const JobCard({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(job.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                JobStatusBadge(status: job.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(job.categoryName, style: const TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 12),
            Text('KES ${job.estimatedCost.toStringAsFixed(0)}',
                style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w600)),
          ],
        ),
      );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/gradient_app_bar.dart';
import '../widgets/job_status_badge.dart';

class JobDetailScreen extends ConsumerWidget {
  final String jobId;
  const JobDetailScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      appBar: const GradientAppBar(title: 'Job Details'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Status', style: TextStyle(color: AppColors.textMuted)),
                JobStatusBadge(status: 'MATCHED'),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.backgroundSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Fix leaking sink', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Plumbing', style: TextStyle(color: AppColors.primaryBlueLight)),
                  const SizedBox(height: 16),
                  const Text('Description', style: TextStyle(color: AppColors.textMuted)),
                  const SizedBox(height: 4),
                  const Text('The pipe under the kitchen sink is leaking heavily and needs replacement.'),
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.borderSubtle),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Estimated Cost', style: TextStyle(color: AppColors.textMuted)),
                      Text('KES 1,500', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.success)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/gradient_app_bar.dart';
import '../widgets/job_status_badge.dart';
import '../../data/datasources/job_remote_ds.dart';
import '../../domain/models/job.dart';
import '../controllers/job_controller.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

final jobDetailProvider =
    FutureProvider.family<Job, String>((ref, jobId) async {
  return ref.read(jobRemoteDsProvider).getJob(jobId);
});

class JobDetailScreen extends ConsumerWidget {
  final String jobId;
  const JobDetailScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobAsync = ref.watch(jobDetailProvider(jobId));
    final authUser = ref.watch(authControllerProvider).value;

    return jobAsync.when(
      loading: () => const AppScaffold(
        appBar: GradientAppBar(title: 'Job Details'),
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => AppScaffold(
        appBar: const GradientAppBar(title: 'Job Details'),
        body: Center(
            child: Text('$e', style: const TextStyle(color: AppColors.error))),
      ),
      data: (job) {
        final isProvider = authUser?.role == 'PROVIDER';

        return AppScaffold(
          appBar: const GradientAppBar(title: 'Job Details'),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Status row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Status',
                        style: TextStyle(color: AppColors.textMuted)),
                    JobStatusBadge(status: job.status),
                  ],
                ),
                const SizedBox(height: 24),

                // Job info card
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
                      Text(job.title,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(job.categoryName,
                          style: const TextStyle(
                              color: AppColors.primaryBlueLight)),
                      if (job.description.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text('Description',
                            style: TextStyle(color: AppColors.textMuted)),
                        const SizedBox(height: 4),
                        Text(job.description),
                      ],
                      const SizedBox(height: 16),
                      const Divider(color: AppColors.borderSubtle),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Estimated Cost',
                              style: TextStyle(color: AppColors.textMuted)),
                          Text(
                            'KES ${job.estimatedCost.toStringAsFixed(0)}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: AppColors.success),
                          ),
                        ],
                      ),
                      if (job.address.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 14, color: AppColors.textMuted),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(job.address,
                                  style: const TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 12)),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Role-based action buttons
                if (isProvider) ...[
                  if (job.status == 'MATCHED')
                    _ActionButton(
                      label: 'Start Job',
                      color: AppColors.primaryBlue,
                      onPressed: () =>
                          _updateStatus(context, ref, 'start'),
                    ),
                  if (job.status == 'IN_PROGRESS')
                    _ActionButton(
                      label: 'Mark Complete',
                      color: AppColors.success,
                      onPressed: () =>
                          _updateStatus(context, ref, 'complete'),
                    ),
                ] else ...[
                  if (job.status == 'MATCHED')
                    _ActionButton(
                      label: 'Pay Now',
                      color: AppColors.mPesaGreen,
                      onPressed: () => context.push('/payment/$jobId'),
                    ),
                ],
                if (job.status == 'REQUESTED' || job.status == 'MATCHED')
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: _ActionButton(
                      label: 'Cancel Job',
                      color: AppColors.error,
                      onPressed: () =>
                          _updateStatus(context, ref, 'cancel'),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _updateStatus(
      BuildContext context, WidgetRef ref, String action) async {
    try {
      await ref
          .read(jobControllerProvider.notifier)
          .updateJobStatus(jobId, action);
      ref.invalidate(jobDetailProvider(jobId));
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppColors.error),
        );
      }
    }
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton(
      {required this.label, required this.color, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: onPressed,
        child: Text(label,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
      ),
    );
  }
}

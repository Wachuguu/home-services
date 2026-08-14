import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/gradient_app_bar.dart';
import '../controllers/job_controller.dart';
import '../widgets/job_card.dart';

class JobListScreen extends ConsumerWidget {
  const JobListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsync = ref.watch(jobControllerProvider);

    return AppScaffold(
      appBar: const GradientAppBar(title: 'My Jobs'),
      body: jobsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Error: $e', style: const TextStyle(color: AppColors.error)),
        ),
        data: (jobs) => jobs.isEmpty
            ? const Center(
                child: Text(
                  'No jobs yet',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 16),
                ),
              )
            : RefreshIndicator(
                onRefresh: () => ref.refresh(jobControllerProvider.future),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: jobs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) => InkWell(
                    onTap: () => context.push('/jobs/${jobs[i].id}'),
                    borderRadius: BorderRadius.circular(16),
                    child: JobCard(job: jobs[i]),
                  ),
                ),
              ),
      ),
    );
  }
}

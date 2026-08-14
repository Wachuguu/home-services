import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../jobs/domain/models/job.dart';
import '../../data/datasources/job_remote_ds.dart';

class JobController extends AsyncNotifier<List<Job>> {
  @override
  Future<List<Job>> build() async {
    return fetchMyJobs();
  }

  Future<List<Job>> fetchMyJobs() async {
    return ref.read(jobRemoteDsProvider).getMyJobs();
  }

  Future<Job> createJob(Map<String, dynamic> data) async {
    final newJob = await ref.read(jobRemoteDsProvider).createJob(data);
    ref.invalidateSelf();
    return newJob;
  }

  Future<void> updateJobStatus(String jobId, String action) async {
    await ref.read(jobRemoteDsProvider).updateJobStatus(jobId, action);
    ref.invalidateSelf();
  }
}

final jobControllerProvider =
    AsyncNotifierProvider<JobController, List<Job>>(() => JobController());

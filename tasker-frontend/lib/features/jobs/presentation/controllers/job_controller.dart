import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/job.dart';
import '../../data/datasources/job_remote_ds.dart';

part 'job_controller.g.dart';

@riverpod
class JobController extends _$JobController {
  @override
  FutureOr<List<Job>> build() async {
    return fetchMyJobs();
  }

  Future<List<Job>> fetchMyJobs() async {
    return await ref.read(jobRemoteDsProvider).getMyJobs();
  }
  
  Future<Job> createJob(Map<String, dynamic> data) async {
    final newJob = await ref.read(jobRemoteDsProvider).createJob(data);
    ref.invalidateSelf();
    return newJob;
  }
}

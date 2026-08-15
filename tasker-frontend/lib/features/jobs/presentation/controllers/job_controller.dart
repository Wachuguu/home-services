import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../jobs/domain/models/job.dart';
import '../../data/datasources/job_remote_ds.dart';

class JobController extends AsyncNotifier<List<Job>> {
  @override
  Future<List<Job>> build() async {
    return fetchMyJobs();
  }

  Future<List<Job>> fetchMyJobs() async {
    try {
      return await ref.read(jobRemoteDsProvider).getMyJobs();
    } on DioException catch (e) {
      throw Exception("Failed to load jobs. Please try again.");
    } catch (e) {
      throw Exception("An unexpected error occurred.");
    }
  }

  Future<Job> createJob(Map<String, dynamic> data) async {
    try {
      final newJob = await ref.read(jobRemoteDsProvider).createJob(data);
      ref.invalidateSelf();
      return newJob;
    } on DioException catch (e) {
      String errorMessage = "Failed to create job.";
      if (e.response?.data != null && e.response?.data is Map && e.response!.data['message'] != null) {
        errorMessage = e.response!.data['message'];
      }
      throw Exception(errorMessage);
    }
  }

  Future<void> updateJobStatus(String jobId, String action) async {
    try {
      await ref.read(jobRemoteDsProvider).updateJobStatus(jobId, action);
      ref.invalidateSelf();
    } on DioException catch (e) {
      String errorMessage = "Failed to update job status.";
      if (e.response?.data != null && e.response?.data is Map && e.response!.data['message'] != null) {
        errorMessage = e.response!.data['message'];
      }
      throw Exception(errorMessage);
    }
  }
}

final jobControllerProvider =
    AsyncNotifierProvider<JobController, List<Job>>(() => JobController());

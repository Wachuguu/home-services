import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../domain/models/job.dart';
import '../../domain/models/provider_match.dart';

final jobRemoteDsProvider = Provider<JobRemoteDs>((ref) {
  return JobRemoteDs(ref.watch(dioClientProvider));
});

class JobRemoteDs {
  final Dio _dio;

  JobRemoteDs(this._dio);

  Future<Job> createJob(Map<String, dynamic> data) async {
    final response = await _dio.post(ApiEndpoints.jobs, data: data);
    return Job.fromJson(response.data);
  }

  Future<Job> getJob(String id) async {
    final response = await _dio.get(ApiEndpoints.jobById(id));
    return Job.fromJson(response.data);
  }

  Future<List<Job>> getMyJobs() async {
    final response = await _dio.get(ApiEndpoints.myJobs);
    return (response.data as List).map((e) => Job.fromJson(e)).toList();
  }

  Future<Job> matchProvider(String jobId, String providerId) async {
    final response = await _dio.post(ApiEndpoints.matchProvider(jobId), data: {'providerId': providerId});
    return Job.fromJson(response.data);
  }

  Future<Job> startJob(String jobId) async {
    final response = await _dio.put(ApiEndpoints.startJob(jobId));
    return Job.fromJson(response.data);
  }

  Future<Job> completeJob(String jobId) async {
    final response = await _dio.put(ApiEndpoints.completeJob(jobId));
    return Job.fromJson(response.data);
  }

  Future<Job> cancelJob(String jobId) async {
    final response = await _dio.put(ApiEndpoints.cancelJob(jobId));
    return Job.fromJson(response.data);
  }

  Future<Job> updateJobStatus(String jobId, String action) async {
    switch (action) {
      case 'start':
        return startJob(jobId);
      case 'complete':
        return completeJob(jobId);
      case 'cancel':
        return cancelJob(jobId);
      default:
        throw ArgumentError('Unknown job action: $action');
    }
  }

  Future<List<ProviderMatch>> getNearbyProviders(String categoryId, double lat, double lng, double radiusKm) async {
    final response = await _dio.get(
      ApiEndpoints.nearbyProviders(categoryId),
      queryParameters: {'lat': lat, 'lng': lng, 'radiusKm': radiusKm},
    );
    return (response.data as List).map((e) => ProviderMatch.fromJson(e)).toList();
  }
}

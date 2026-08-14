import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../domain/models/service_category.dart';

final categoryRemoteDsProvider = Provider<CategoryRemoteDs>((ref) {
  return CategoryRemoteDs(ref.watch(dioClientProvider));
});

class CategoryRemoteDs {
  final Dio _dio;

  CategoryRemoteDs(this._dio);

  Future<List<ServiceCategory>> getCategories() async {
    final response = await _dio.get(ApiEndpoints.categories);
    final data = response.data as List;
    return data.map((json) => ServiceCategory.fromJson(json)).toList();
  }
}

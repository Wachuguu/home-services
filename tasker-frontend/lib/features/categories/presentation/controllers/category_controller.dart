import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../categories/domain/models/service_category.dart';
import '../../data/datasources/category_remote_ds.dart';

class CategoryController extends AsyncNotifier<List<ServiceCategory>> {
  @override
  Future<List<ServiceCategory>> build() async {
    return fetchCategories();
  }

  Future<List<ServiceCategory>> fetchCategories() async {
    try {
      return await ref.read(categoryRemoteDsProvider).getCategories();
    } on DioException catch (e) {
      throw Exception("Failed to load categories. Please try again.");
    } catch (e) {
      throw Exception("An unexpected error occurred.");
    }
  }
}

final categoryControllerProvider =
    AsyncNotifierProvider<CategoryController, List<ServiceCategory>>(
        () => CategoryController());

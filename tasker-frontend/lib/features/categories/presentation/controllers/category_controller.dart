import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../categories/domain/models/service_category.dart';
import '../../data/datasources/category_remote_ds.dart';

class CategoryController extends AsyncNotifier<List<ServiceCategory>> {
  @override
  Future<List<ServiceCategory>> build() async {
    return fetchCategories();
  }

  Future<List<ServiceCategory>> fetchCategories() async {
    return ref.read(categoryRemoteDsProvider).getCategories();
  }
}

final categoryControllerProvider =
    AsyncNotifierProvider<CategoryController, List<ServiceCategory>>(
        () => CategoryController());

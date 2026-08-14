import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/service_category.dart';
import '../../data/datasources/category_remote_ds.dart';

part 'category_controller.g.dart';

@riverpod
class CategoryController extends _$CategoryController {
  @override
  FutureOr<List<ServiceCategory>> build() async {
    return fetchCategories();
  }

  Future<List<ServiceCategory>> fetchCategories() async {
    return await ref.read(categoryRemoteDsProvider).getCategories();
  }
}

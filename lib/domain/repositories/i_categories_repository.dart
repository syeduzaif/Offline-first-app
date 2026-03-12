import 'package:offline_first_app/domain/models/category.dart';

abstract class ICategoriesRepository {
  Stream<List<ProductCategory>> watchCategories();
  Future<void> refreshCategories();
}

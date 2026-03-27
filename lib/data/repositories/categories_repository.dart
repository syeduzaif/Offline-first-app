import 'package:drift/drift.dart';
import 'package:offline_first_app/data/local/database.dart';
import 'package:offline_first_app/data/local/daos/categories_dao.dart';
import 'package:offline_first_app/data/remote/api_client.dart';
import 'package:offline_first_app/data/remote/dtos/category_dto.dart';
import 'package:offline_first_app/domain/models/category.dart';

class CategoriesRepository {
  CategoriesRepository({
    required this.categoriesDao,
    required this.apiClient,
  });

  final CategoriesDao categoriesDao;
  final ApiClient apiClient;

  Stream<List<ProductCategory>> watchCategories() =>
      categoriesDao.watchAll().map(
            (rows) => rows
                .map((r) => ProductCategory(
                      slug: r.slug,
                      name: r.name,
                      url: r.url,
                    ))
                .toList(),
          );

  Future<void> refreshCategories() async {
    final response = await apiClient.getCategories();
    final data = response.data;
    if (data is! List) return;
    final list = data
        .whereType<Map>()
        .map((json) => CategoryDto.fromJson(
              json.cast<String, dynamic>(),
            ))
        .toList();
    final companions = list
        .map((dto) => CategoriesCompanion.insert(
              slug: dto.slug,
              name: dto.name,
              url: Value(dto.url),
            ))
        .toList();
    await categoriesDao.replaceAll(companions);
  }
}

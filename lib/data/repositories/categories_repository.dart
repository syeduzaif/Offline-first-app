import 'package:drift/drift.dart';
import 'package:offline_first_app/data/local/database.dart';
import 'package:offline_first_app/data/local/daos/categories_dao.dart';
import 'package:offline_first_app/data/remote/api_client.dart';
import 'package:offline_first_app/data/remote/dtos/category_dto.dart';
import 'package:offline_first_app/domain/models/category.dart';
import 'package:offline_first_app/domain/repositories/i_categories_repository.dart';

class CategoriesRepository implements ICategoriesRepository {
  CategoriesRepository({
    required this.categoriesDao,
    required this.apiClient,
  });

  final CategoriesDao categoriesDao;
  final ApiClient apiClient;

  @override
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

  @override
  Future<void> refreshCategories() async {
    final response = await apiClient.getCategories();
    final list = (response.data as List)
        .map((json) =>
            CategoryDto.fromJson(json as Map<String, dynamic>))
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

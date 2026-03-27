import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:offline_first_app/data/local/database.dart' hide Product;
import 'package:offline_first_app/data/mappers/sync_operation_mapper.dart';
import 'package:offline_first_app/domain/models/sync_operation.dart';
import 'package:offline_first_app/data/remote/api_client.dart';
import 'package:offline_first_app/data/repositories/categories_repository.dart';
import 'package:offline_first_app/data/repositories/products_repository.dart';
import 'package:offline_first_app/domain/models/category.dart';
import 'package:offline_first_app/domain/models/product.dart';
import 'package:offline_first_app/services/connectivity_service.dart';
import 'package:offline_first_app/services/sync_service.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) => throw UnimplementedError();

@Riverpod(keepAlive: true)
ApiClient apiClient(Ref ref) => throw UnimplementedError();

@Riverpod(keepAlive: true)
ProductsRepository productsRepository(Ref ref) =>
    throw UnimplementedError();

@Riverpod(keepAlive: true)
CategoriesRepository categoriesRepository(Ref ref) =>
    throw UnimplementedError();

final connectivityServiceProvider =
    ChangeNotifierProvider<ConnectivityService>(
  (ref) => throw UnimplementedError(),
);

final syncServiceProvider = ChangeNotifierProvider<SyncService>(
  (ref) => throw UnimplementedError(),
);

@riverpod
bool isOnline(Ref ref) {
  return ref.watch(connectivityServiceProvider).isOnline;
}

@riverpod
bool isSyncing(Ref ref) {
  return ref.watch(syncServiceProvider).isSyncing;
}

@riverpod
class CurrentTab extends _$CurrentTab {
  @override
  int build() => 0;

  void setTab(int index) => state = index;
}

@riverpod
Stream<int> pendingSyncCount(Ref ref) {
  return ref
      .watch(appDatabaseProvider)
      .syncQueueDao
      .watchPendingCount();
}

@riverpod
class ProductsSearchQuery extends _$ProductsSearchQuery {
  @override
  String build() => '';

  void setQuery(String value) => state = value;
}

@riverpod
class ProductsSelectedCategory
    extends _$ProductsSelectedCategory {
  @override
  String? build() => null;

  void setCategory(String? value) => state = value;
}

@riverpod
Stream<List<Product>> productsStream(Ref ref) {
  final search = ref.watch(productsSearchQueryProvider);
  final category = ref.watch(productsSelectedCategoryProvider);
  final repo = ref.watch(productsRepositoryProvider);

  if (search.isNotEmpty) return repo.searchProducts(search);
  if (category != null) {
    return repo.watchProductsByCategory(category);
  }
  return repo.watchProducts();
}

@riverpod
Stream<List<ProductCategory>> categoriesStream(Ref ref) {
  return ref.watch(categoriesRepositoryProvider).watchCategories();
}

@riverpod
Stream<Product?> productDetail(Ref ref, int id) {
  return ref.watch(productsRepositoryProvider).watchProduct(id);
}

@riverpod
Stream<List<SyncOperation>> syncOperations(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.syncQueueDao
      .watchAll()
      .map((ops) => ops.map(syncOperationFromDao).toList());
}

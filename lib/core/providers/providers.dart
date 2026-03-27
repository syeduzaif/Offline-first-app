import 'package:flutter_riverpod/flutter_riverpod.dart';
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

final appDatabaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError(),
);

final apiClientProvider = Provider<ApiClient>(
  (ref) => throw UnimplementedError(),
);

final productsRepositoryProvider = Provider<ProductsRepository>(
  (ref) => throw UnimplementedError(),
);

final categoriesRepositoryProvider = Provider<CategoriesRepository>(
  (ref) => throw UnimplementedError(),
);

final connectivityServiceProvider =
    ChangeNotifierProvider<ConnectivityService>(
  (ref) => throw UnimplementedError(),
);

final syncServiceProvider = ChangeNotifierProvider<SyncService>(
  (ref) => throw UnimplementedError(),
);

final isOnlineProvider = Provider<bool>((ref) {
  return ref.watch(connectivityServiceProvider).isOnline;
});

final isSyncingProvider = Provider<bool>((ref) {
  return ref.watch(syncServiceProvider).isSyncing;
});

final currentTabProvider = StateProvider<int>((ref) => 0);

final pendingSyncCountProvider = StreamProvider<int>((ref) {
  return ref
      .watch(appDatabaseProvider)
      .syncQueueDao
      .watchPendingCount();
});

final productsSearchQueryProvider =
    StateProvider.autoDispose<String>((ref) => '');

final productsSelectedCategoryProvider =
    StateProvider.autoDispose<String?>((ref) => null);

final productsStreamProvider =
    StreamProvider.autoDispose<List<Product>>((ref) {
  final search = ref.watch(productsSearchQueryProvider);
  final category = ref.watch(productsSelectedCategoryProvider);
  final repo = ref.watch(productsRepositoryProvider);

  if (search.isNotEmpty) return repo.searchProducts(search);
  if (category != null) {
    return repo.watchProductsByCategory(category);
  }
  return repo.watchProducts();
});

final categoriesStreamProvider =
    StreamProvider<List<ProductCategory>>((ref) {
  return ref.watch(categoriesRepositoryProvider).watchCategories();
});

final productDetailProvider =
    StreamProvider.autoDispose.family<Product?, int>((ref, id) {
  return ref.watch(productsRepositoryProvider).watchProduct(id);
});

final syncOperationsProvider =
    StreamProvider<List<SyncOperation>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.syncQueueDao
      .watchAll()
      .map((ops) => ops.map(syncOperationFromDao).toList());
});

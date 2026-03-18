import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_first_app/data/local/database.dart';
import 'package:offline_first_app/data/remote/api_client.dart';
import 'package:offline_first_app/data/repositories/categories_repository.dart';
import 'package:offline_first_app/data/repositories/products_repository.dart';
import 'package:offline_first_app/services/connectivity_service.dart';
import 'package:offline_first_app/services/sync_service.dart';

// ─── Singletons overridden in main via ProviderScope ───────────────────────

final appDatabaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('Override in ProviderScope'),
);

final connectivityServiceProvider = Provider<ConnectivityService>(
  (ref) => throw UnimplementedError('Override in ProviderScope'),
);

final syncServiceProvider = Provider<SyncService>(
  (ref) => throw UnimplementedError('Override in ProviderScope'),
);

// ─── Created from other providers ──────────────────────────────────────────

final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(),
);

final productsRepositoryProvider = Provider<ProductsRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final apiClient = ref.watch(apiClientProvider);
  return ProductsRepository(
    productsDao: db.productsDao,
    syncQueueDao: db.syncQueueDao,
    apiClient: apiClient,
    database: db,
  );
});

final categoriesRepositoryProvider =
    Provider<CategoriesRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final apiClient = ref.watch(apiClientProvider);
  return CategoriesRepository(
    categoriesDao: db.categoriesDao,
    apiClient: apiClient,
  );
});

// ─── Reactive stream providers ──────────────────────────────────────────────

/// Emits the pending sync queue count from the local DB.
final pendingSyncCountProvider = StreamProvider<int>((ref) {
  return ref.watch(appDatabaseProvider).syncQueueDao.watchPendingCount();
});

/// Emits the current online status, starting with the current value.
final connectivityStatusProvider = StreamProvider<bool>((ref) async* {
  final service = ref.watch(connectivityServiceProvider);
  yield service.isOnline;
  yield* service.onConnectivityChanged;
});

/// Emits whether a sync is currently in progress, starting with current value.
final isSyncingProvider = StreamProvider<bool>((ref) async* {
  final service = ref.watch(syncServiceProvider);
  yield service.isSyncing;
  yield* service.isSyncingStream;
});

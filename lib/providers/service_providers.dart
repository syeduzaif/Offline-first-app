import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:offline_first_app/data/local/database.dart';
import 'package:offline_first_app/data/remote/api_client.dart';
import 'package:offline_first_app/data/repositories/categories_repository.dart';
import 'package:offline_first_app/data/repositories/products_repository.dart';
import 'package:offline_first_app/domain/models/sync_operation.dart';
import 'package:offline_first_app/services/connectivity_service.dart';
import 'package:offline_first_app/services/database_service.dart';
import 'package:offline_first_app/services/sync_service.dart';

// ── Singleton service providers ──────────────────────────────────────────────
// All of these are initialized in main() and injected via ProviderScope overrides.

final databaseServiceProvider = Provider<DatabaseService>(
  (ref) => throw UnimplementedError('Override in ProviderScope'),
);

final appDatabaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('Override in ProviderScope'),
);

final apiClientProvider = Provider<ApiClient>(
  (ref) => throw UnimplementedError('Override in ProviderScope'),
);

final productsRepositoryProvider = Provider<ProductsRepository>(
  (ref) => throw UnimplementedError('Override in ProviderScope'),
);

final categoriesRepositoryProvider = Provider<CategoriesRepository>(
  (ref) => throw UnimplementedError('Override in ProviderScope'),
);

final connectivityServiceProvider = Provider<ConnectivityService>(
  (ref) => throw UnimplementedError('Override in ProviderScope'),
);

final syncServiceProvider = Provider<SyncService>(
  (ref) => throw UnimplementedError('Override in ProviderScope'),
);

// ── Reactive stream providers ─────────────────────────────────────────────────

/// Emits the current online status and every subsequent change.
final isOnlineProvider = StreamProvider<bool>((ref) async* {
  final service = ref.watch(connectivityServiceProvider);
  yield service.isOnline;
  yield* service.onConnectivityChanged;
});

/// Emits the current syncing status and every subsequent change.
final isSyncingProvider = StreamProvider<bool>((ref) async* {
  final service = ref.watch(syncServiceProvider);
  yield service.isSyncing;
  yield* service.onSyncingChanged;
});

/// Emits the count of pending sync-queue entries.
final pendingSyncCountProvider = StreamProvider<int>((ref) {
  return ref.watch(appDatabaseProvider).syncQueueDao.watchPendingCount();
});

/// Emits the full sync-queue mapped to domain objects.
final syncOperationsProvider =
    StreamProvider<List<SyncOperation>>((ref) {
  return ref
      .watch(appDatabaseProvider)
      .syncQueueDao
      .watchAll()
      .map((rows) => rows.map(_toDomain).toList());
});

SyncOperation _toDomain(SyncQueueData row) {
  return SyncOperation(
    id: row.id,
    operation: SyncOperationType.values.firstWhere(
      (e) => e.name == row.operation,
      orElse: () => SyncOperationType.update,
    ),
    entityType: row.entityType,
    entityId: row.entityId,
    payload: row.payload,
    status: SyncOperationStatus.values.firstWhere(
      (e) => e.name == row.status,
      orElse: () => SyncOperationStatus.pending,
    ),
    retryCount: row.retryCount,
    createdAt: row.createdAt,
    lastAttemptAt: row.lastAttemptAt,
    errorMessage: row.errorMessage,
  );
}

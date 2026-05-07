import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_first_app/core/services/connectivity_service.dart';
import 'package:offline_first_app/core/services/database.dart';
import 'package:offline_first_app/core/services/secure_storage.dart';
import 'package:offline_first_app/sync/sync_engine.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

// ─── Infrastructure tier (overridden in main.dart via ProviderScope.overrides) ─

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) => throw UnimplementedError();

@Riverpod(keepAlive: true)
SecureStorageService secureStorage(Ref ref) => throw UnimplementedError();

// ─── Services (manual ChangeNotifierProvider — survive hot reload) ─────────────

final connectivityServiceProvider = ChangeNotifierProvider<ConnectivityService>(
  (ref) => throw UnimplementedError(),
);

final syncEngineProvider = ChangeNotifierProvider<SyncEngine>(
  (ref) => throw UnimplementedError(),
);

// ─── Derived boolean providers ──────────────────────────────────────────────────

@riverpod
bool isOnline(Ref ref) => ref.watch(connectivityServiceProvider).isOnline;

@riverpod
bool isSyncing(Ref ref) => ref.watch(syncEngineProvider).isSyncing;

// ─── Sync queue badge count ──────────────────────────────────────────────────────

@riverpod
Stream<int> pendingSyncCount(Ref ref) =>
    ref.watch(appDatabaseProvider).syncQueueDao.watchPendingCount();

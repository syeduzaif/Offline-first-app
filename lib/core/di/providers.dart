import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_first_app/data/local/database.dart';
import 'package:offline_first_app/data/remote/api_client.dart';
import 'package:offline_first_app/data/repositories/categories_repository.dart';
import 'package:offline_first_app/data/repositories/products_repository.dart';
import 'package:offline_first_app/services/connectivity_service.dart';
import 'package:offline_first_app/services/sync_service.dart';

Never _missingOverride(String providerName) {
  throw StateError(
    '$providerName must be overridden in the root ProviderScope.',
  );
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  _missingOverride('appDatabaseProvider');
});

final apiClientProvider = Provider<ApiClient>((ref) {
  _missingOverride('apiClientProvider');
});

final productsRepositoryProvider = Provider<ProductsRepository>((ref) {
  _missingOverride('productsRepositoryProvider');
});

final categoriesRepositoryProvider = Provider<CategoriesRepository>((ref) {
  _missingOverride('categoriesRepositoryProvider');
});

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  _missingOverride('connectivityServiceProvider');
});

final syncServiceProvider = Provider<SyncService>((ref) {
  _missingOverride('syncServiceProvider');
});

final connectivityStatusProvider = StreamProvider<bool>((ref) {
  final service = ref.read(connectivityServiceProvider);
  return _emitInitial(service.isOnline, service.onConnectivityChanged);
});

final syncStatusProvider = StreamProvider<bool>((ref) {
  final service = ref.read(syncServiceProvider);
  return _emitInitial(service.isSyncing, service.onSyncingChanged);
});

Stream<bool> _emitInitial(bool initial, Stream<bool> stream) async* {
  yield initial;
  yield* stream;
}

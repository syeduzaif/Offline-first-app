import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_first_app/data/local/database.dart';
import 'package:offline_first_app/data/remote/api_client.dart';
import 'package:offline_first_app/data/repositories/categories_repository.dart';
import 'package:offline_first_app/data/repositories/products_repository.dart';
import 'package:offline_first_app/services/connectivity_service.dart';
import 'package:offline_first_app/services/sync_service.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('appDatabaseProvider must be overridden');
});

final apiClientProvider = Provider<ApiClient>((ref) {
  throw UnimplementedError('apiClientProvider must be overridden');
});

final productsRepositoryProvider = Provider<ProductsRepository>((ref) {
  throw UnimplementedError('productsRepositoryProvider must be overridden');
});

final categoriesRepositoryProvider = Provider<CategoriesRepository>((ref) {
  throw UnimplementedError('categoriesRepositoryProvider must be overridden');
});

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  throw UnimplementedError('connectivityServiceProvider must be overridden');
});

final syncServiceProvider = Provider<SyncService>((ref) {
  throw UnimplementedError('syncServiceProvider must be overridden');
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

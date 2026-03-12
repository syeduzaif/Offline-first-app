import 'dart:async';
import 'dart:convert';

import 'package:offline_first_app/data/local/database.dart';
import 'package:offline_first_app/data/local/daos/products_dao.dart';
import 'package:offline_first_app/data/local/daos/sync_queue_dao.dart';
import 'package:offline_first_app/data/remote/api_client.dart';
import 'package:offline_first_app/services/connectivity_service.dart';
import 'package:stacked/stacked.dart';

class SyncService with ListenableServiceMixin {
  SyncService({
    required this.syncQueueDao,
    required this.productsDao,
    required this.apiClient,
    required this.connectivityService,
  }) {
    listenToReactiveValues([_isSyncing]);
  }

  final SyncQueueDao syncQueueDao;
  final ProductsDao productsDao;
  final ApiClient apiClient;
  final ConnectivityService connectivityService;

  final ReactiveValue<bool> _isSyncing =
      ReactiveValue<bool>(false);
  bool get isSyncing => _isSyncing.value;

  StreamSubscription<bool>? _connectivitySub;

  void initialize() {
    _connectivitySub = connectivityService
        .onConnectivityChanged
        .listen((online) {
      if (online) syncAll();
    });
  }

  Future<void> syncAll() async {
    if (_isSyncing.value || !connectivityService.isOnline) {
      return;
    }
    _isSyncing.value = true;
    notifyListeners();

    try {
      final operations =
          await syncQueueDao.getPendingOperations();
      for (final op in operations) {
        await _processOperation(op);
      }
    } finally {
      _isSyncing.value = false;
      notifyListeners();
    }
  }

  Future<void> _processOperation(SyncQueueData op) async {
    await syncQueueDao.markInProgress(op.id);
    try {
      final payload =
          jsonDecode(op.payload) as Map<String, dynamic>;
      switch (op.operation) {
        case 'create':
          final response =
              await apiClient.createProduct(payload);
          final data =
              response.data as Map<String, dynamic>;
          final remoteId = data['id'] as int;
          await productsDao.updateRemoteId(
              op.entityId, remoteId);
          break;
        case 'update':
          await apiClient.updateProduct(
              op.entityId, payload);
          await productsDao.updateSyncStatus(
              op.entityId, 'synced');
          break;
        case 'delete':
          await apiClient.deleteProduct(op.entityId);
          await productsDao.hardDeleteProduct(op.entityId);
          break;
      }
      await syncQueueDao.markCompleted(op.id);
    } catch (e) {
      await syncQueueDao.markFailed(op.id, e.toString());
      if (op.retryCount >= 2) {
        await productsDao.updateSyncStatus(
            op.entityId, 'failed');
      }
    }
  }

  void dispose() {
    _connectivitySub?.cancel();
  }
}

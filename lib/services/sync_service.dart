import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:offline_first_app/data/local/database.dart';
import 'package:offline_first_app/data/local/daos/products_dao.dart';
import 'package:offline_first_app/data/local/daos/sync_queue_dao.dart';
import 'package:offline_first_app/data/remote/api_client.dart';
import 'package:offline_first_app/services/connectivity_service.dart';

class SyncService extends ChangeNotifier {
  SyncService({
    required this.syncQueueDao,
    required this.productsDao,
    required this.apiClient,
    required this.connectivityService,
  });

  final SyncQueueDao syncQueueDao;
  final ProductsDao productsDao;
  final ApiClient apiClient;
  final ConnectivityService connectivityService;

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  StreamSubscription<bool>? _connectivitySub;

  void initialize() {
    _connectivitySub = connectivityService
        .onConnectivityChanged
        .listen((online) {
      if (online) syncAll();
    });
  }

  Future<void> syncAll() async {
    if (_isSyncing || !connectivityService.isOnline) {
      return;
    }
    _isSyncing = true;
    notifyListeners();

    try {
      await syncQueueDao.resetInProgressToPending();
      final operations =
          await syncQueueDao.getPendingOperations();
      for (final op in operations) {
        await _processOperation(op);
      }
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> _processOperation(SyncQueueData op) async {
    await syncQueueDao.markInProgress(op.id);
    try {
      final payload =
          (jsonDecode(op.payload) as Map?)?.cast<String, dynamic>() ??
              <String, dynamic>{};
      switch (op.operation) {
        case 'create':
          final response =
              await apiClient.createProduct(payload);
          final data =
              (response.data as Map?)?.cast<String, dynamic>() ??
                  <String, dynamic>{};
          final remoteId = (data['id'] as num?)?.toInt();
          if (remoteId == null) {
            throw const FormatException('Missing remote id');
          }
          await productsDao.updateRemoteId(
              op.entityId, remoteId);
          break;
        case 'update':
          final product =
              await productsDao.getProduct(op.entityId);
          if (product?.remoteId == null && op.entityId < 0) {
            throw StateError('Create must sync before update');
          }
          final targetId = product?.remoteId ?? op.entityId;
          await apiClient.updateProduct(
              targetId, payload);
          await productsDao.updateSyncStatus(
              op.entityId, 'synced');
          break;
        case 'delete':
          final product =
              await productsDao.getProduct(op.entityId);
          if (product?.remoteId == null && op.entityId < 0) {
            throw StateError('Create must sync before delete');
          }
          final targetId = product?.remoteId ?? op.entityId;
          await apiClient.deleteProduct(targetId);
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

  Future<void> clearCompleted() =>
      syncQueueDao.clearCompleted();

  Future<void> retryOperation(int id) async {
    await syncQueueDao.resetToPending(id);
    await syncAll();
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }
}

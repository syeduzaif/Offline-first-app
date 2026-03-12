import 'dart:async';

import 'package:offline_first_app/app/app.locator.dart';
import 'package:offline_first_app/data/local/database.dart';
import 'package:offline_first_app/domain/models/sync_operation.dart';
import 'package:offline_first_app/services/sync_service.dart';
import 'package:stacked/stacked.dart';

class SyncQueueViewModel extends ReactiveViewModel {
  final _syncService = locator<SyncService>();
  final _db = locator<AppDatabase>();

  List<SyncOperation> _operations = [];
  List<SyncOperation> get operations => _operations;

  StreamSubscription<List<SyncQueueData>>? _opsSub;

  bool get isSyncing => _syncService.isSyncing;

  void initialize() {
    _opsSub = _db.syncQueueDao.watchAll().listen((ops) {
      _operations = ops.map(_toDomain).toList();
      notifyListeners();
    });
  }

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

  Future<void> syncNow() async {
    await _syncService.syncAll();
  }

  Future<void> clearCompleted() async {
    await _db.syncQueueDao.clearCompleted();
  }

  Future<void> retryOperation(int id) async {
    await _db.syncQueueDao.resetToPending(id);
    await _syncService.syncAll();
  }

  @override
  List<ListenableServiceMixin> get listenableServices =>
      [_syncService];

  @override
  void dispose() {
    _opsSub?.cancel();
    super.dispose();
  }
}

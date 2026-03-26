import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_first_app/core/di/providers.dart';
import 'package:offline_first_app/data/local/database.dart';
import 'package:offline_first_app/domain/models/sync_operation.dart';
import 'package:offline_first_app/services/sync_service.dart';

class SyncQueueState {
  const SyncQueueState({
    this.operations = const [],
    this.isSyncing = false,
  });

  final List<SyncOperation> operations;
  final bool isSyncing;

  SyncQueueState copyWith({
    List<SyncOperation>? operations,
    bool? isSyncing,
  }) {
    return SyncQueueState(
      operations: operations ?? this.operations,
      isSyncing: isSyncing ?? this.isSyncing,
    );
  }
}

final syncQueueControllerProvider =
    NotifierProvider<SyncQueueController, SyncQueueState>(
  SyncQueueController.new,
);

class SyncQueueController extends Notifier<SyncQueueState> {
  late final SyncService _syncService;
  late final AppDatabase _db;

  StreamSubscription<List<SyncQueueData>>? _opsSub;

  @override
  SyncQueueState build() {
    _syncService = ref.read(syncServiceProvider);
    _db = ref.read(appDatabaseProvider);

    _opsSub = _db.syncQueueDao.watchAll().listen((ops) {
      final mapped = ops.map(_toDomain).toList();
      state = state.copyWith(operations: mapped);
    });

    ref.listen(syncStatusProvider, (previous, next) {
      final syncing = next.value ?? false;
      state = state.copyWith(isSyncing: syncing);
    });

    ref.onDispose(() {
      _opsSub?.cancel();
    });

    return SyncQueueState(isSyncing: _syncService.isSyncing);
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
}

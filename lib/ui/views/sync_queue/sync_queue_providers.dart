import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_first_app/data/local/database.dart';
import 'package:offline_first_app/domain/models/sync_operation.dart';
import 'package:offline_first_app/providers/core_providers.dart';

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

/// Live stream of all sync queue operations.
final syncOperationsProvider =
    StreamProvider<List<SyncOperation>>((ref) {
  return ref
      .watch(appDatabaseProvider)
      .syncQueueDao
      .watchAll()
      .map((rows) => rows.map(_toDomain).toList());
});

import 'package:offline_first_app/data/local/database.dart'
    hide Product;
import 'package:offline_first_app/domain/models/sync_operation.dart';

SyncOperation syncOperationFromDao(SyncQueueData row) {
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

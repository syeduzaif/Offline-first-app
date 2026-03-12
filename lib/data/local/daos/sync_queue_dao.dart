import 'package:drift/drift.dart';
import 'package:offline_first_app/data/local/database.dart';
import 'package:offline_first_app/data/local/tables/sync_queue_table.dart';

part 'sync_queue_dao.g.dart';

@DriftAccessor(tables: [SyncQueue])
class SyncQueueDao extends DatabaseAccessor<AppDatabase>
    with _$SyncQueueDaoMixin {
  SyncQueueDao(super.db);

  Stream<List<SyncQueueData>> watchAll() => (select(syncQueue)
        ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
      .watch();

  Stream<int> watchPendingCount() {
    final countExpr = syncQueue.id.count();
    final query = selectOnly(syncQueue)
      ..addColumns([countExpr])
      ..where(syncQueue.status.isIn(['pending', 'failed']));
    return query
        .map((row) => row.read(countExpr) ?? 0)
        .watchSingle();
  }

  Future<List<SyncQueueData>> getPendingOperations() =>
      (select(syncQueue)
            ..where((t) =>
                t.status.isIn(['pending', 'failed']))
            ..where(
                (t) => t.retryCount.isSmallerThanValue(3))
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .get();

  Future<int> enqueue(SyncQueueCompanion entry) =>
      into(syncQueue).insert(entry);

  Future<void> markInProgress(int opId) =>
      (update(syncQueue)..where((t) => t.id.equals(opId)))
          .write(SyncQueueCompanion(
        status: const Value('inProgress'),
        lastAttemptAt: Value(DateTime.now()),
      ));

  Future<void> markCompleted(int opId) =>
      (update(syncQueue)..where((t) => t.id.equals(opId)))
          .write(const SyncQueueCompanion(
        status: Value('completed'),
      ));

  Future<void> markFailed(int opId, String error) async {
    final existing = await (select(syncQueue)
          ..where((t) => t.id.equals(opId)))
        .getSingleOrNull();
    final currentRetry = existing?.retryCount ?? 0;
    await (update(syncQueue)
          ..where((t) => t.id.equals(opId)))
        .write(SyncQueueCompanion(
      status: const Value('failed'),
      errorMessage: Value(error),
      retryCount: Value(currentRetry + 1),
      lastAttemptAt: Value(DateTime.now()),
    ));
  }

  Future<void> resetToPending(int opId) =>
      (update(syncQueue)..where((t) => t.id.equals(opId)))
          .write(const SyncQueueCompanion(
        status: Value('pending'),
      ));

  Future<void> clearCompleted() =>
      (delete(syncQueue)
            ..where((t) => t.status.equals('completed')))
          .go();

  Future<void> deleteOperation(int opId) =>
      (delete(syncQueue)..where((t) => t.id.equals(opId)))
          .go();
}

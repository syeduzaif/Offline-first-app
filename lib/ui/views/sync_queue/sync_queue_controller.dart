import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:offline_first_app/providers/service_providers.dart';

class SyncQueueController {
  SyncQueueController(this._ref);

  final Ref _ref;

  Future<void> syncNow() async {
    await _ref.read(syncServiceProvider).syncAll();
  }

  Future<void> clearCompleted() async {
    await _ref.read(appDatabaseProvider).syncQueueDao.clearCompleted();
  }

  Future<void> retryOperation(int id) async {
    await _ref
        .read(appDatabaseProvider)
        .syncQueueDao
        .resetToPending(id);
    await _ref.read(syncServiceProvider).syncAll();
  }
}

final syncQueueControllerProvider = Provider<SyncQueueController>((ref) {
  return SyncQueueController(ref);
});

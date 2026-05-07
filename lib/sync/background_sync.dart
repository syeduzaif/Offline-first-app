import 'package:workmanager/workmanager.dart';

// Top-level callback required by Workmanager — must be a top-level function
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    switch (taskName) {
      case 'backgroundSync':
        return await _runBackgroundSync();
      default:
        return Future.value(true);
    }
  });
}

Future<bool> _runBackgroundSync() async {
  // TODO(Phase 2): Instantiate services independently for the background isolate.
  // Background isolates have no access to the main isolate's memory.
  // Pattern:
  //   final secureStorage = SecureStorageService();
  //   final dbKey = await secureStorage.getDatabaseKey();
  //   final db = AppDatabase(dbKey);
  //   final connectivity = ConnectivityService();
  //   await connectivity.initialize();
  //   if (!connectivity.isOnline) return true;
  //   final engine = SyncEngine(database: db, connectivityService: connectivity);
  //   await engine.syncAll();
  //   await db.close();
  return true;
}

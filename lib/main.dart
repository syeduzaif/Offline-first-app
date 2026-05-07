import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_first_app/app.dart';
import 'package:offline_first_app/core/providers/providers.dart';
import 'package:offline_first_app/core/services/connectivity_service.dart';
import 'package:offline_first_app/core/services/database.dart';
import 'package:offline_first_app/core/services/database_seeder.dart';
import 'package:offline_first_app/core/services/secure_storage.dart';
import 'package:offline_first_app/sync/background_sync.dart';
import 'package:offline_first_app/sync/sync_engine.dart';
import 'package:workmanager/workmanager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Secure storage — read DB encryption key before opening the database
  final secureStorage = SecureStorageService();
  final dbKey = await secureStorage.getDatabaseKey();

  // 2. Encrypted local database (Drift + SQLCipher)
  final db = AppDatabase(dbKey);

  // 3. Seed mock data on first launch (debug builds only)
  if (kDebugMode) await DatabaseSeeder.seed(db);

  // 4. Connectivity — must initialize before SyncEngine
  final connectivity = ConnectivityService();
  await connectivity.initialize();

  // 5. Sync engine — initialize() subscribes to connectivity stream
  final syncEngine = SyncEngine(
    database: db,
    connectivityService: connectivity,
  );
  syncEngine.initialize();

  // 6. Workmanager background sync (every 15 minutes when online)
  await Workmanager().initialize(callbackDispatcher);
  await Workmanager().registerPeriodicTask(
    'teacher-app-sync',
    'backgroundSync',
    frequency: const Duration(minutes: 15),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    constraints: Constraints(networkType: NetworkType.connected),
  );

  runApp(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        secureStorageProvider.overrideWithValue(secureStorage),
        connectivityServiceProvider.overrideWith((ref) => connectivity),
        syncEngineProvider.overrideWith((ref) => syncEngine),
      ],
      child: const MyApp(),
    ),
  );
}

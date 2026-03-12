import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:workmanager/workmanager.dart';

import 'package:offline_first_app/app/app.locator.dart';
import 'package:offline_first_app/app/app.router.dart';
import 'package:offline_first_app/core/constants/strings/app_strings.dart';
import 'package:offline_first_app/core/theme/app_theme.dart';
import 'package:offline_first_app/data/local/database.dart';
import 'package:offline_first_app/data/remote/api_client.dart';
import 'package:offline_first_app/data/repositories/categories_repository.dart';
import 'package:offline_first_app/data/repositories/products_repository.dart';
import 'package:offline_first_app/services/connectivity_service.dart';
import 'package:offline_first_app/services/database_service.dart';
import 'package:offline_first_app/services/sync_service.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // This runs in a separate isolate — all instances are independent
    // of the foreground app. Always close the DB when done to avoid
    // WAL journal corruption on iOS.
    final db = AppDatabase();
    try {
      final apiClient = ApiClient();
      final connectivity = ConnectivityService();
      await connectivity.initialize();
      final syncService = SyncService(
        syncQueueDao: db.syncQueueDao,
        productsDao: db.productsDao,
        apiClient: apiClient,
        connectivityService: connectivity,
      );
      await syncService.syncAll();
      connectivity.dispose();
      syncService.dispose();
      return true;
    } finally {
      await db.close();
    }
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Stacked generated locator
  await setupLocator();

  // 2. Database
  final dbService = DatabaseService();
  await dbService.initialize();
  locator.registerSingleton<DatabaseService>(dbService);
  locator
      .registerSingleton<AppDatabase>(dbService.database);

  // 3. API Client
  final apiClient = ApiClient();
  locator.registerSingleton<ApiClient>(apiClient);

  // 4. Repositories
  final db = dbService.database;
  final productsRepo = ProductsRepository(
    productsDao: db.productsDao,
    syncQueueDao: db.syncQueueDao,
    apiClient: apiClient,
    database: db,
  );
  locator.registerSingleton<ProductsRepository>(
      productsRepo);

  final categoriesRepo = CategoriesRepository(
    categoriesDao: db.categoriesDao,
    apiClient: apiClient,
  );
  locator.registerSingleton<CategoriesRepository>(
      categoriesRepo);

  // 5. Connectivity Service
  final connectivity = ConnectivityService();
  await connectivity.initialize();
  locator.registerSingleton<ConnectivityService>(
      connectivity);

  // 6. Sync Service
  final syncService = SyncService(
    syncQueueDao: db.syncQueueDao,
    productsDao: db.productsDao,
    apiClient: apiClient,
    connectivityService: connectivity,
  );
  syncService.initialize();
  locator.registerSingleton<SyncService>(syncService);

  // 7. Workmanager (background sync)
  await Workmanager().initialize(
    callbackDispatcher,
  );
  await Workmanager().registerPeriodicTask(
    'offline-first-sync',
    'backgroundSync',
    frequency: const Duration(minutes: 15),
    constraints: Constraints(
      networkType: NetworkType.connected,
    ),
  );

  // 8. Initial data fetch (silently fails if offline)
  try {
    await Future.wait([
      productsRepo.refreshProducts(),
      categoriesRepo.refreshCategories(),
    ]);
  } catch (_) {
    // Offline start — local DB serves cached data
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(440, 956),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: CommonStrings.appTitle,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          navigatorKey: StackedService.navigatorKey,
          onGenerateRoute:
              StackedRouter().onGenerateRoute,
        );
      },
    );
  }
}

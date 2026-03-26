import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:workmanager/workmanager.dart';

import 'package:offline_first_app/app/app_router.dart';
import 'package:offline_first_app/core/constants/strings/app_strings.dart';
import 'package:offline_first_app/core/di/providers.dart';
import 'package:offline_first_app/core/theme/app_theme.dart';
import 'package:offline_first_app/data/local/database.dart';
import 'package:offline_first_app/data/remote/api_client.dart';
import 'package:offline_first_app/data/repositories/categories_repository.dart';
import 'package:offline_first_app/data/repositories/products_repository.dart';
import 'package:offline_first_app/services/connectivity_service.dart';
import 'package:offline_first_app/services/sync_service.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
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
      // Always close the isolate-local database in finally.
      // On iOS, leaving a background isolate DB open can corrupt WAL state.
      await db.close();
    }
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Database
  final db = AppDatabase();

  // API Client
  final apiClient = ApiClient();

  // Repositories
  final productsRepo = ProductsRepository(
    productsDao: db.productsDao,
    syncQueueDao: db.syncQueueDao,
    apiClient: apiClient,
    database: db,
  );

  final categoriesRepo = CategoriesRepository(
    categoriesDao: db.categoriesDao,
    apiClient: apiClient,
  );

  // Connectivity Service
  final connectivity = ConnectivityService();
  await connectivity.initialize();

  // Sync Service
  final syncService = SyncService(
    syncQueueDao: db.syncQueueDao,
    productsDao: db.productsDao,
    apiClient: apiClient,
    connectivityService: connectivity,
  );
  syncService.initialize();

  // Workmanager (background sync)
  await Workmanager().initialize(callbackDispatcher);
  await Workmanager().registerPeriodicTask(
    'offline-first-sync',
    'backgroundSync',
    frequency: const Duration(minutes: 15),
    constraints: Constraints(networkType: NetworkType.connected),
  );

  // Initial data fetch (silently fails if offline)
  try {
    await Future.wait([
      productsRepo.refreshProducts(),
      categoriesRepo.refreshCategories(),
    ]);
  } catch (_) {
    // Offline start — local DB serves cached data
  }

  runApp(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        apiClientProvider.overrideWithValue(apiClient),
        productsRepositoryProvider.overrideWithValue(productsRepo),
        categoriesRepositoryProvider.overrideWithValue(categoriesRepo),
        connectivityServiceProvider.overrideWithValue(connectivity),
        syncServiceProvider.overrideWithValue(syncService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.read(goRouterProvider);

    return ScreenUtilInit(
      designSize: const Size(440, 956),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: CommonStrings.appTitle,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          routerConfig: router,
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:workmanager/workmanager.dart';

import 'package:offline_first_app/core/constants/strings/app_strings.dart';
import 'package:offline_first_app/core/theme/app_theme.dart';
import 'package:offline_first_app/data/local/database.dart';
import 'package:offline_first_app/data/remote/api_client.dart';
import 'package:offline_first_app/data/repositories/categories_repository.dart';
import 'package:offline_first_app/data/repositories/products_repository.dart';
import 'package:offline_first_app/providers/core_providers.dart';
import 'package:offline_first_app/services/connectivity_service.dart';
import 'package:offline_first_app/services/sync_service.dart';
import 'package:offline_first_app/ui/views/main/main_view.dart';

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
      await db.close();
    }
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Database
  final db = AppDatabase();

  // 2. API Client
  final apiClient = ApiClient();

  // 3. Connectivity Service
  final connectivity = ConnectivityService();
  await connectivity.initialize();

  // 4. Sync Service
  final syncService = SyncService(
    syncQueueDao: db.syncQueueDao,
    productsDao: db.productsDao,
    apiClient: apiClient,
    connectivityService: connectivity,
  );
  syncService.initialize();

  // 5. Workmanager (background sync)
  await Workmanager().initialize(callbackDispatcher);
  await Workmanager().registerPeriodicTask(
    'offline-first-sync',
    'backgroundSync',
    frequency: const Duration(minutes: 15),
    constraints: Constraints(networkType: NetworkType.connected),
  );

  // 6. Initial data fetch (silently fails if offline)
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
  try {
    await Future.wait([
      productsRepo.refreshProducts(),
      categoriesRepo.refreshCategories(),
    ]);
  } catch (_) {}

  runApp(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        connectivityServiceProvider.overrideWithValue(connectivity),
        syncServiceProvider.overrideWithValue(syncService),
      ],
      child: const MyApp(),
    ),
  );
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
          home: const MainView(),
        );
      },
    );
  }
}

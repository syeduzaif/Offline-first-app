# Technical Requirements Document (TRD)
## Offline-First Product Catalog App

**Version:** 1.0
**Date:** March 2026
**Stack:** Flutter 3.x / Dart 3.11+

---

## 1. Architecture

### Pattern
Feature-first MVVM with Riverpod providers and ChangeNotifier-based controllers (migration-safe).

```
UI Layer        → Views + Widgets (Flutter)
ViewModel Layer → Riverpod ChangeNotifier controllers (state + logic)
Service Layer   → SyncService, ConnectivityService (ChangeNotifier)
Repository Layer→ ProductsRepository, CategoriesRepository
Data Layer      → Local (Drift/SQLite) + Remote (Dio/DummyJSON)
```

### Dependency Injection
Riverpod providers with app-level overrides in `main.dart`.

---

## 2. Tech Stack

| Concern | Library | Version |
|---|---|---|
| UI Framework | Flutter | 3.x |
| State Management | flutter_riverpod, riverpod | ^3.3.1 / ^3.2.1 |
| Navigation | go_router | ^17.1.0 |
| Local Database | drift (SQLite) | ^2.24.0 |
| SQLite Native | sqlite3_flutter_libs | ^0.5.32 |
| HTTP Client | dio | ^5.4.0 |
| Retry Logic | dio_smart_retry | ^7.0.1 |
| Connectivity | connectivity_plus | ^6.1.4 |
| Background Tasks | workmanager | ^0.9.0 |
| Code Generation | freezed, json_serializable, drift_dev | various |
| UI Scaling | flutter_screenutil | ^5.9.3 |
| Icons | iconsax | ^0.0.8 |
| Image Caching | cached_network_image | ^3.4.1 |
| Bottom Nav | google_nav_bar | ^5.0.7 |
| Utilities | path_provider, uuid, intl | various |

---

## 3. Project Structure

```
lib/
├── app/
│   └── app_router.dart           # go_router config
├── core/
│   ├── constants/                # Colors, paddings, text styles, strings
│   ├── di/                       # Riverpod providers
│   └── theme/                    # AppTheme
├── data/
│   ├── local/
│   │   ├── database.dart         # AppDatabase (Drift)
│   │   ├── tables/               # Products, Categories, SyncQueue tables
│   │   └── daos/                 # ProductsDao, CategoriesDao, SyncQueueDao
│   ├── remote/
│   │   ├── api_client.dart       # Dio client
│   │   ├── api_constants.dart    # Base URL, endpoints, timeouts
│   │   └── dtos/                 # ProductDto, CategoryDto (freezed)
│   └── repositories/
│       ├── products_repository.dart
│       └── categories_repository.dart
├── domain/
│   ├── models/                   # Product, Category, SyncOperation (freezed)
│   ├── repositories/             # IProductsRepository, ICategoriesRepository
│   └── models/sync_status.dart
├── services/
│   ├── connectivity_service.dart
│   └── sync_service.dart
├── ui/
│   ├── views/
│   │   ├── main/                 # MainView + MainViewModel + BottomNavBar
│   │   ├── products/             # ProductsView + ViewModel + widgets
│   │   ├── product_detail/       # ProductDetailView + ViewModel + widgets
│   │   ├── add_product/          # AddProductView + ViewModel + ProductForm
│   │   ├── edit_product/         # EditProductView + ViewModel
│   │   └── sync_queue/           # SyncQueueView + ViewModel + widgets
│   └── widgets/                  # Shared: EmptyState, LoadingIndicator, etc.
└── main.dart                     # Bootstrap, provider overrides, WorkManager init
```

---

## 4. Local Database (Drift / SQLite)

### Tables

#### `products`
| Column | Type | Notes |
|---|---|---|
| id | INTEGER PK autoincrement | Local ID |
| title | TEXT | |
| description | TEXT | |
| price | REAL | |
| discountPercentage | REAL | default 0.0 |
| rating | REAL | default 0.0 |
| stock | INTEGER | default 0 |
| brand | TEXT | |
| category | TEXT | |
| thumbnail | TEXT | |
| images | TEXT | JSON-encoded `List<String>` |
| syncStatus | TEXT | `synced` \| `pending` \| `failed` |
| lastModified | DATETIME | auto |
| remoteId | INTEGER | nullable, set after API create |
| isDeleted | BOOLEAN | soft delete flag |

#### `sync_queue`
| Column | Type | Notes |
|---|---|---|
| id | INTEGER PK autoincrement | |
| operation | TEXT | `create` \| `update` \| `delete` |
| entityType | TEXT | `product` |
| entityId | INTEGER | local product ID |
| payload | TEXT | JSON-encoded mutation data |
| status | TEXT | `pending` \| `inProgress` \| `completed` \| `failed` |
| retryCount | INTEGER | default 0 |
| createdAt | DATETIME | |
| lastAttemptAt | DATETIME | nullable |
| errorMessage | TEXT | nullable |

#### `categories`
Stores category slug and name for offline filter support.

### DAOs
- **ProductsDao** — CRUD, soft delete, hard delete, upsert, watch streams, search, filter by category, pagination.
- **SyncQueueDao** — enqueue, getPendingOperations (retry < 3), markInProgress, markCompleted, markFailed, resetToPending, clearCompleted, watchAll, watchPendingCount.
- **CategoriesDao** — upsert, watchCategories.

---

## 5. Remote API (DummyJSON)

Base URL: `https://dummyjson.com`

| Endpoint | Method | Usage |
|---|---|---|
| `/products` | GET | Paginated product list (limit, skip) |
| `/products/:id` | GET | Single product |
| `/products/search` | GET | Search (q, limit, skip) |
| `/products/category/:slug` | GET | Filter by category |
| `/products/add` | POST | Create product |
| `/products/:id` | PUT | Update product |
| `/products/:id` | DELETE | Delete product |
| `/products/categories` | GET | All categories |

**Note:** DummyJSON is a mock API — mutations return success responses but do not persist data server-side.

### HTTP Client Config
- Connect timeout: 15s
- Receive timeout: 15s
- Retry interceptor: 3 retries, backoff 1s → 2s → 4s

---

## 6. Sync Engine

### SyncService

Singleton provided via Riverpod. Extends `ChangeNotifier` for reactive UI updates.

**Initialization (`initialize()`):**
- Subscribes to `ConnectivityService.onConnectivityChanged`.
- Calls `syncAll()` whenever the device comes online.

**Sync flow (`syncAll()`):**
1. Guard: skip if already syncing or offline.
2. Set `isSyncing = true`, notify listeners.
3. Fetch all pending queue operations (status `pending` or `failed`, retryCount < 3), ordered by `createdAt ASC`.
4. For each operation call `_processOperation()`.
5. Set `isSyncing = false`, notify listeners.

**`_processOperation(op)`:**
1. Mark operation `inProgress`.
2. Decode JSON payload.
3. Switch on `op.operation`:
   - `create` → POST to API → update local `remoteId`.
   - `update` → PUT to API → update local `syncStatus` to `synced`.
   - `delete` → DELETE from API → hard-delete local record.
4. On success: mark operation `completed`.
5. On failure: mark operation `failed`, increment `retryCount`. If `retryCount >= 2`, mark product `syncStatus` as `failed`.

**Trigger points:**
- App start (connectivity already up).
- Connectivity restored (stream event).
- After create/update in AddProductViewModel and EditProductViewModel.
- Manual "Sync Now" button in SyncQueueView.
- Retry button on individual failed operations.
- WorkManager background task (every 15 min, network required).

---

## 7. Connectivity Service

`ConnectivityService` wraps `connectivity_plus`.

- Maintains a reactive `isOnline` boolean.
- Emits on `onConnectivityChanged` broadcast stream only when status actually changes (debounced by value comparison).
- Initialized once at app start with current connectivity state.

---

## 8. Background Sync (WorkManager)

- Registered in `main()` with `registerPeriodicTask`.
- Task name: `offline-first-sync`, unique name: `backgroundSync`.
- Frequency: 15 minutes (minimum; OS may defer).
- Constraint: `NetworkType.connected`.
- The `callbackDispatcher` (annotated `@pragma('vm:entry-point')`) instantiates its own `AppDatabase`, `ApiClient`, `ConnectivityService`, and `SyncService` — fully isolated from the main isolate.

---

## 9. Navigation

Uses `go_router` with path-based routes.

```
/ (MainView)
/product/add
/product/:id
/product/:id/edit
```

---

## 10. State Management

- Riverpod `ChangeNotifierProvider` wraps feature controllers.
- Views are `ConsumerWidget`/`ConsumerStatefulWidget` with `ref.watch`.
- Local DB streams (Drift) drive product list, category list, sync queue list reactively.

---

## 11. Code Generation

Run after any model/table/route change:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Generates:
- `*.freezed.dart` — immutable models + copyWith
- `*.g.dart` — JSON serialization, Drift DAOs, Drift database

---

## 12. UI / Theming

- Design canvas: 440×956 (ScreenUtil).
- All spacing uses `AppPaddings`, `AppLayout`, `AppTextStyles`, `AppColors` constants.
- Bottom nav is a floating pill rendered in a `Stack` inside `MainView` — child views account for nav height via bottom list padding (`AppLayout.bottomNavBarHeight`).
- FAB on Products screen offset upward by `AppLayout.bottomNavBarHeight` to clear the floating nav.
- Snackbar: Flutter's native `ScaffoldMessenger.showSnackBar`.

---

## 13. Startup Sequence

```
1. WidgetsFlutterBinding.ensureInitialized()
2. Create AppDatabase
3. Create ApiClient
4. Construct ProductsRepository, CategoriesRepository
5. ConnectivityService.initialize() — check + subscribe
6. SyncService.initialize()    — subscribe to connectivity stream
7. Workmanager().initialize() + registerPeriodicTask
8. Initial data fetch (refreshProducts + refreshCategories) — silent fail if offline
9. runApp(ProviderScope overrides + MyApp)
```

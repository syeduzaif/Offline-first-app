# Architecture Patterns: Riverpod Migration

**Project:** Offline-First Product Store (Stacked → Riverpod migration)
**Researched:** 2026-03-26
**Confidence:** HIGH (Riverpod 2.x stable API, verified against training knowledge through August 2025; codebase analysis is direct)

---

## Overview

This document defines the target architecture for replacing Stacked MVVM + GetIt with Riverpod
across the UI and DI layers only. The domain layer (`lib/domain/`) and data layer
(`lib/data/`, `lib/services/`) are preserved unchanged. Riverpod becomes the single
dependency injection and state management system.

---

## Recommended Architecture: What Changes, What Stays

```
UNCHANGED                          REPLACED
─────────────────────────────────  ──────────────────────────────────────
lib/domain/           (pure Dart)  lib/app/app.locator.dart   → deleted
lib/data/local/       (Drift)      lib/app/app.router.dart    → go_router
lib/data/remote/      (Dio)        lib/core/viewmodels/       → providers/
lib/data/repositories/(concrete)   lib/ui/views/*_viewmodel.dart → notifiers
lib/services/         (services)   StackedView / ReactiveViewModel → ConsumerWidget
lib/domain/models/    (@freezed)   locator<T>() calls → ref.watch / ref.read
lib/domain/repositories/ (ifaces)  ListenableServiceMixin → StreamProvider / StateNotifier
```

The migration is strictly additive top-down replacement: providers wrap
the existing concrete classes; those classes need no modification.

---

## Provider Hierarchy

Providers form a strict directed acyclic graph. Lower layers have no knowledge of
higher layers. The hierarchy maps directly to the existing architectural layers.

```
TIER 1 — Infrastructure (no dependencies within Riverpod graph)
  appDatabaseProvider         (Provider<AppDatabase>)
  apiClientProvider           (Provider<ApiClient>)

TIER 2 — Services (depend on Tier 1)
  connectivityServiceProvider (StreamProvider<bool>)   ← replaces ConnectivityService.isOnline
  syncServiceProvider         (Provider<SyncService>)  ← holds singleton, initialized once

TIER 3 — Repositories (depend on Tier 1)
  productsRepositoryProvider  (Provider<IProductsRepository>)
  categoriesRepositoryProvider(Provider<ICategoriesRepository>)

TIER 4 — Derived / Query streams (depend on Tier 3)
  productsStreamProvider      (StreamProvider<List<Product>>)
  categoriesStreamProvider    (StreamProvider<List<ProductCategory>>)
  pendingSyncCountProvider    (StreamProvider<int>)
  productByIdProvider         (StreamProvider.family<Product?, int>)

TIER 5 — UI Notifiers (depend on Tier 2, 3, 4)
  productsNotifierProvider    (AsyncNotifierProvider / NotifierProvider)
  productDetailNotifierProvider(family AsyncNotifierProvider)
  addProductNotifierProvider  (NotifierProvider)
  editProductNotifierProvider (family NotifierProvider)
  syncQueueNotifierProvider   (AsyncNotifierProvider)
  mainShellNotifierProvider   (NotifierProvider)
```

**Why this ordering matters:** Tier 1–3 providers hold long-lived singletons (same
lifetime as the app). Tier 4 providers are derived reactive streams — they auto-dispose
when no widget is listening (`autoDispose` modifier). Tier 5 notifiers carry per-screen
state and always use `autoDispose` to release resources when the route is popped.

---

## Where Providers Are Defined

Use **co-location**: each provider lives in the file closest to what it creates.

| Provider | File |
|----------|------|
| `appDatabaseProvider` | `lib/data/local/database.dart` |
| `apiClientProvider` | `lib/data/remote/api_client.dart` |
| `connectivityServiceProvider` | `lib/services/connectivity_service.dart` |
| `syncServiceProvider` | `lib/services/sync_service.dart` |
| `productsRepositoryProvider` | `lib/data/repositories/products_repository.dart` |
| `categoriesRepositoryProvider` | `lib/data/repositories/categories_repository.dart` |
| `productsStreamProvider` | `lib/data/repositories/products_repository.dart` |
| `categoriesStreamProvider` | `lib/data/repositories/categories_repository.dart` |
| `pendingSyncCountProvider` | `lib/data/local/daos/sync_queue_dao.dart` (or database.dart) |
| `productByIdProvider` | `lib/data/repositories/products_repository.dart` |
| `productsNotifierProvider` | `lib/ui/views/products/products_notifier.dart` |
| `productDetailNotifierProvider` | `lib/ui/views/product_detail/product_detail_notifier.dart` |
| `addProductNotifierProvider` | `lib/ui/views/add_product/add_product_notifier.dart` |
| `editProductNotifierProvider` | `lib/ui/views/edit_product/edit_product_notifier.dart` |
| `syncQueueNotifierProvider` | `lib/ui/views/sync_queue/sync_queue_notifier.dart` |
| `mainShellNotifierProvider` | `lib/ui/views/main/main_notifier.dart` |

**Rationale for co-location over a central `providers.dart`:** A central file creates
a single-file bottleneck, forces circular import management, and makes feature-level
changes touch a shared file. Co-location aligns providers with the code they own, matches
the existing feature-folder convention, and scales to additional features without
coordination conflicts.

---

## Riverpod DI: Replacing GetIt

### How GetIt Worked Here

```dart
// main.dart — manual registration
locator.registerSingleton<ProductsRepository>(productsRepo);

// viewmodel — pull from global registry
final _productsRepo = locator<ProductsRepository>();
```

### How Riverpod Replaces It

Providers are definitions, not registrations. The container is implicit (ProviderScope).
Dependencies are declared as `ref.watch` / `ref.read` inside the provider body.

```dart
// Tier 1: AppDatabase — no dependencies
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);   // Riverpod manages lifecycle
  return db;
});

// Tier 1: ApiClient — no dependencies
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

// Tier 3: ProductsRepository — depends on Tier 1
final productsRepositoryProvider = Provider<IProductsRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final api = ref.watch(apiClientProvider);
  return ProductsRepository(
    productsDao: db.productsDao,
    syncQueueDao: db.syncQueueDao,
    apiClient: api,
    database: db,
  );
});

// Tier 2: ConnectivityService — exposed as a stream
final connectivityServiceProvider = StreamProvider<bool>((ref) {
  final service = ConnectivityService();
  ref.onDispose(service.dispose);
  return service.onConnectivityChanged;
});

// Tier 4: Derived stream — watchProducts mapped to StreamProvider
final productsStreamProvider = StreamProvider.autoDispose<List<Product>>((ref) {
  final repo = ref.watch(productsRepositoryProvider);
  return repo.watchProducts();
});
```

No `main.dart` registration. No `setupLocator()`. No generated locator file.
The `ProviderScope` widget at the root of the widget tree is the only bootstrap requirement.

### Replacing ListenableServiceMixin

`ConnectivityService` and `SyncService` used `ListenableServiceMixin` so ViewModels
could register themselves as listeners. Riverpod replaces this pattern with streams:

| Stacked pattern | Riverpod equivalent |
|-----------------|---------------------|
| `listenableServices: [_connectivityService]` | `ref.watch(connectivityServiceProvider)` in the notifier |
| `_connectivityService.isOnline` getter | `ref.watch(connectivityServiceProvider).value ?? true` |
| `_syncService.isSyncing` getter | `ref.watch(syncServiceProvider).isSyncing` or a separate `isSyncingProvider` |
| `notifyListeners()` in service | `SyncService` exposes a `Stream<bool> isSyncingStream` |

`SyncService` requires a minor internal change: replace `ReactiveValue<bool> _isSyncing`
with a `StreamController<bool>` or `ValueNotifier<bool>` so Riverpod can consume it
as a `StreamProvider`. The service's external interface (constructor signature, `syncAll()`,
`dispose()`) does not change — only the notification mechanism.

---

## ConsumerWidget Replaces StackedView

### Current Stacked Pattern

```dart
class ProductsView extends StackedView<ProductsViewModel> {
  @override
  ProductsViewModel viewModelBuilder(BuildContext context) => ProductsViewModel();

  @override
  void onViewModelReady(ProductsViewModel viewModel) => viewModel.initialize();

  @override
  Widget builder(BuildContext context, ProductsViewModel viewModel, Widget? child) {
    // read viewModel.products, viewModel.isOnline, etc.
  }
}
```

### Target Riverpod Pattern

```dart
class ProductsView extends ConsumerWidget {
  const ProductsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productsNotifierProvider);
    final isOnline = ref.watch(connectivityServiceProvider).value ?? true;
    final isSyncing = ref.watch(isSyncingProvider);

    // render from state fields
  }
}
```

**Key differences:**

| Aspect | Stacked | Riverpod |
|--------|---------|---------|
| ViewModel lifecycle | `StackedView` manages creation/disposal | `autoDispose` on notifier handles it |
| Initialization hook | `onViewModelReady` | Notifier `build()` method or `ref.listenSelf` |
| Reading state | `viewModel.someGetter` | `ref.watch(someProvider)` |
| Triggering actions | `viewModel.doSomething()` | `ref.read(notifierProvider.notifier).doSomething()` |
| Reactive services | `listenableServices` list | `ref.watch` inside notifier or `ref.listen` |
| DI | `locator<T>()` in constructor | `ref.watch(tProvider)` in provider body |

`ConsumerStatefulWidget` is used only when the widget needs its own mutable widget-layer
state (e.g., `TextEditingController`, `ScrollController`, `FocusNode`). The form views
(`AddProductView`, `EditProductView`) need this because they hold `TextEditingController`
instances. All other views can use the simpler `ConsumerWidget`.

---

## State Model for Notifiers

Replace `BaseViewModel.isBusy + modelError` with explicit state classes.
Use `@freezed` (already a project dependency) for notifier state:

```dart
@freezed
class ProductsState with _$ProductsState {
  const factory ProductsState({
    @Default([]) List<Product> products,
    @Default([]) List<ProductCategory> categories,
    String? selectedCategory,
    @Default('') String searchQuery,
    @Default(false) bool isLoadingMore,
    @Default(true) bool hasMore,
    @Default(false) bool isRefreshing,
    @Default(0) int currentSkip,
  }) = _ProductsState;
}
```

`AsyncNotifier<T>` is used when the notifier's `build()` must do async work
(e.g., initial data fetch on screen mount). `Notifier<T>` is used when `build()` is
synchronous and the notifier only reacts to user actions.

| ViewModel | Target type | Rationale |
|-----------|-------------|-----------|
| `ProductsViewModel` | `Notifier<ProductsState>` | Streams from Drift are the reactive source; build() is sync |
| `ProductDetailViewModel` | `AsyncNotifier<Product?>` | Needs to await `watchProduct` stream for first value |
| `AddProductViewModel` | `Notifier<AddProductState>` | Form state; actions are imperative |
| `EditProductViewModel` | `Notifier<EditProductState>` | Same as Add, initialized with existing Product |
| `SyncQueueViewModel` | `Notifier<SyncQueueState>` | Driven by Drift stream |
| `MainViewModel` | `Notifier<MainState>` | Tab index + pending count stream |

---

## Navigation: Replacing StackedRouter

`stacked_services.NavigationService` is used in ViewModels for navigation and
`StackedService.navigatorKey` is used in `MyApp`. Both must be replaced.

**Recommended replacement:** `go_router` (pub.dev/packages/go_router).

- Define a `goRouterProvider` (Provider<GoRouter>) using Riverpod, allowing routes
  to read providers if needed (e.g., redirect guards).
- Replace `_navigationService.navigateTo(Routes.X, arguments: ...)` with
  `ref.read(goRouterProvider).push('/path', extra: args)` in notifiers, or
  pass a callback from the view down to the notifier via a method parameter.
- `StackedService.navigatorKey` in `MyApp` is replaced by `GoRouter`'s own
  `routerConfig:` parameter on `MaterialApp.router`.

Navigation belongs in the view layer in Riverpod: notifiers return state or expose
methods; the view decides what to navigate to after an action completes. This is
cleaner than notifiers holding a navigation service reference.

### Snackbar and Dialog Replacement

`SnackbarService` and `DialogService` from `stacked_services` must be replaced.
Use `ScaffoldMessenger` for snackbars (pass `context` from the view, or use a
global `scaffoldMessengerKey`) and `showDialog` / `showAdaptiveDialog` from Flutter
core for confirmation dialogs. No third-party service needed.

---

## Initialization: Replacing main.dart Bootstrap

Current `main.dart` manually constructs and registers 6 singletons in order, then
calls `runApp`. With Riverpod, singletons are lazy-initialized on first access.

The new `main.dart` is significantly simpler:

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Workmanager registration only (callbackDispatcher is isolate-independent)
  await Workmanager().initialize(callbackDispatcher);
  await Workmanager().registerPeriodicTask(...);

  runApp(
    ProviderScope(
      overrides: [
        // Override here only if you need to inject test doubles or
        // pre-initialized async resources (e.g., SharedPreferences).
        // AppDatabase, ApiClient, repositories are lazy-created on demand.
      ],
      child: const MyApp(),
    ),
  );
}
```

**Async initialization of AppDatabase:** `AppDatabase()` constructor is synchronous in
Drift (the actual file open is deferred). No `await` needed before `runApp`. The first
query will open the file. If explicit pre-warming is needed, use a `FutureProvider`
at the root that awaits initialization and shows a splash screen until resolved.

**Initial data fetch** (currently `productsRepo.refreshProducts()` before `runApp`)
moves into `ProductsNotifier.build()` or a dedicated `FutureProvider` that the
products screen watches. This is preferable: it happens after the first frame renders,
giving users a loading UI rather than a blank startup delay.

**SyncService initialization** (currently `syncService.initialize()` which wires the
connectivity-triggered sync) moves inside `syncServiceProvider`'s creation body. The
stream subscription to `connectivityService.onConnectivityChanged` is set up there and
torn down via `ref.onDispose`.

---

## Workmanager Isolate: No Change Required

The `callbackDispatcher` function in `main.dart` constructs its own `AppDatabase`,
`ApiClient`, `ConnectivityService`, and `SyncService` directly — it does not use
the locator or ProviderScope. This is correct and must remain unchanged. Riverpod
`ProviderScope` is not available in background isolates started by Workmanager.
The callback dispatcher pattern is isolate-local construction; keep it that way.

---

## Drift Integration: No Change Required

All Drift DAOs, table definitions, and `AppDatabase` are unchanged. The only
integration point is the `appDatabaseProvider`:

```dart
// lib/data/local/database.dart (add at bottom of file)
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
```

Drift `Stream`-returning DAO methods (`watchAllProducts()`, `watchPendingCount()`, etc.)
become `StreamProvider` bodies. Riverpod correctly handles Dart streams: it subscribes
on first watch and cancels on last unwatch (with `autoDispose`).

---

## Dio Integration: No Change Required

`ApiClient` is a plain Dart class with no framework ties. The `apiClientProvider`
wraps it without modifications.

---

## Provider Scoping

All Tier 1–3 providers are **non-disposing singletons** for the app lifetime — do not
use `autoDispose` on them. The database connection and HTTP client should persist.

All Tier 4 and Tier 5 providers use `.autoDispose` — stream subscriptions are
cancelled and notifier state is released when no widget references them. This is
especially important for `productByIdProvider(id)` (family provider): each product
detail screen creates a subscription to its product stream, and that subscription must
be cancelled when the screen pops.

```
Provider              (no autoDispose) — singletons: db, api, repos, services
StreamProvider.autoDispose — query streams: products list, categories, pending count
AsyncNotifierProvider.autoDispose — screen state with async build
NotifierProvider.autoDispose — screen state with sync build
```

---

## Migration Order (Bottom-Up)

Migrate in dependency order. Lower tiers must be stable before higher tiers can compile.

### Step 1 — Infrastructure Providers (Tier 1)
Add `appDatabaseProvider` to `database.dart` and `apiClientProvider` to `api_client.dart`.
No behavioral changes. Wire `ProviderScope` into `MyApp` in `main.dart` alongside
the existing locator. Both DI systems coexist during migration.

**Verification:** App compiles; existing Stacked behavior unchanged.

### Step 2 — Service Providers (Tier 2)
Migrate `ConnectivityService` and `SyncService` to expose streams instead of
`ListenableServiceMixin`. Add `connectivityServiceProvider` and `syncServiceProvider`.
`SyncService` gets a `Stream<bool>` for `isSyncing`; `ConnectivityService` already
has `onConnectivityChanged` stream — only the Riverpod wrapper is new.

**Verification:** Services still construct correctly; stream values match previous
`isOnline` / `isSyncing` getters.

### Step 3 — Repository Providers (Tier 3)
Add `productsRepositoryProvider` and `categoriesRepositoryProvider` using the existing
concrete classes. Add Tier 4 derived stream providers in the same files.

**Verification:** A temporary `Consumer` widget reading `productsStreamProvider` renders
the same product list as the current `ProductsViewModel`.

### Step 4 — Migrate ViewModels to Notifiers, Feature by Feature (Tier 5)
Migrate one feature at a time. Recommended order:

1. `SyncQueueViewModel` → `SyncQueueNotifier`
   Simplest: single stream from DAO + `syncNow()` / `clearCompleted()` / `retryOperation()`.
   No navigation, no form state, no service dependencies beyond SyncService.

2. `MainViewModel` → `MainNotifier`
   Tab index state + pending count stream. Tests the shell widget pattern.

3. `ProductsViewModel` → `ProductsNotifier`
   Most complex: search debounce, category filter, scroll-driven pagination, two streams.
   The search debounce (`Timer`) is replaced with a `debounce` on the search query state,
   or kept as a `Timer` inside the notifier (both are valid).

4. `ProductDetailViewModel` → `ProductDetailNotifier`
   Family provider parameterized by `productId`. The "hangs if product deleted" bug
   is naturally fixed: when `watchProduct` emits `null`, state becomes `AsyncData(null)`
   and the view navigates back.

5. `AddProductViewModel` → `AddProductNotifier`
   Form state notifier. `TextEditingController` instances live in the `ConsumerStatefulWidget`
   view, not in the notifier (notifiers are not widgets and should not hold Flutter
   widget-layer objects).

6. `EditProductViewModel` → `EditProductNotifier`
   Same pattern as Add, initialized with the incoming `Product` argument.

**For each feature:**
- Write the notifier + state class
- Convert the view from `StackedView<VM>` to `ConsumerWidget` / `ConsumerStatefulWidget`
- Delete the `_viewmodel.dart` file (or keep temporarily until verification)
- Remove `locator<T>()` calls from the converted file

### Step 5 — Remove Stacked Infrastructure
After all 6 features are migrated and verified:
- Remove `stacked`, `stacked_services`, `stacked_generator` from `pubspec.yaml`
- Delete `lib/app/app.locator.dart`
- Delete `lib/app/app.router.dart` (replaced by go_router config)
- Delete `lib/app/app.dart` `@StackedApp` annotation / rewrite as plain `MaterialApp.router`
- Delete `lib/core/viewmodels/app_viewmodel.dart`
- Remove `setupLocator()` call from `main.dart`
- Remove `stacked.json` if present
- Run `dart pub get` and `flutter pub run build_runner build` to confirm clean build

---

## Anti-Patterns to Avoid

### Anti-Pattern 1: Calling ref.read in build()
**What:** Using `ref.read` instead of `ref.watch` in widget `build` methods.
**Why bad:** `ref.read` does not subscribe; the widget will not rebuild when state changes.
**Instead:** Use `ref.watch` in `build`. Use `ref.read` only in callbacks (button press, etc.).

### Anti-Pattern 2: Holding TextEditingControllers in Notifiers
**What:** Moving `TextEditingController` from ViewModel to Notifier.
**Why bad:** Notifiers are Dart objects with no access to the widget lifecycle; controllers
  require `dispose()` tied to a widget's `State`. They belong in `ConsumerStatefulWidget.State`.
**Instead:** Keep controllers in widget State; pass their `.text` to notifier methods.

### Anti-Pattern 3: Non-autoDispose on Screen-Scoped Providers
**What:** Declaring Tier 5 notifiers without `.autoDispose`.
**Why bad:** Navigation stack pops but the notifier lives on; stream subscriptions leak;
  stale state is served when the route is pushed again.
**Instead:** Always use `autoDispose` on per-screen notifiers.

### Anti-Pattern 4: ProviderScope.overrides for Non-Test Code
**What:** Using `ProviderScope(overrides: [...])` as a way to scope providers to
  a widget subtree in production code.
**Why bad:** Creates hidden scoping that is hard to trace; conflicts with `autoDispose` behavior.
**Instead:** Use family providers for parameterization; use `autoDispose` for lifecycle.

### Anti-Pattern 5: Recreating SyncService in ProviderScope
**What:** Creating `SyncService` as an `autoDispose` provider.
**Why bad:** Sync is a long-lived singleton; making it autoDispose means it is torn down
  when no screen is watching it, losing the connectivity listener.
**Instead:** `syncServiceProvider` is a plain `Provider` (non-disposing). The connectivity
  subscription inside it lives for the app lifetime.

### Anti-Pattern 6: Accessing Providers Directly in Services
**What:** Passing `Ref` into `ConnectivityService` or `SyncService`.
**Why bad:** Services become coupled to Riverpod; they lose testability and reusability
  in the background isolate (Workmanager).
**Instead:** Services remain plain Dart classes. Providers wrap them. The Workmanager
  callback constructs services directly without Riverpod.

---

## Scalability Considerations

| Concern | Current (Stacked) | Post-Migration (Riverpod) |
|---------|--------------------|--------------------------|
| Adding a new screen | New ViewModel + StackedView + locator registration | New Notifier + ConsumerWidget; no registration needed |
| Testing a ViewModel | Mock locator; instantiate VM manually | Override provider in ProviderContainer; no locator |
| Adding a new repository | Register in main.dart; add locator call in VM | Add a Provider; declare ref.watch in notifier |
| Sharing state between screens | Pass via navigation arguments or locator singleton | Shared non-disposing Provider; family providers for parameterized |
| Background sync isolation | callbackDispatcher constructs manually (correct) | Unchanged; Riverpod not involved |

---

## File Structure After Migration

```
lib/
├── main.dart                          # ProviderScope + Workmanager only
├── app/
│   └── app.dart                       # MaterialApp.router (go_router)
│
├── core/
│   └── constants/                     # Unchanged
│
├── domain/                            # Unchanged
├── data/                              # Unchanged + provider definitions added
│   ├── local/
│   │   └── database.dart              # + appDatabaseProvider
│   ├── remote/
│   │   └── api_client.dart            # + apiClientProvider
│   └── repositories/
│       ├── products_repository.dart   # + productsRepositoryProvider, stream providers
│       └── categories_repository.dart # + categoriesRepositoryProvider, stream providers
│
├── services/
│   ├── connectivity_service.dart      # + connectivityServiceProvider (StreamProvider)
│   └── sync_service.dart              # + syncServiceProvider, isSyncingProvider
│
└── ui/
    ├── widgets/                       # Unchanged
    └── views/
        ├── main/
        │   ├── main_view.dart         # ConsumerWidget
        │   └── main_notifier.dart     # Notifier<MainState> + mainShellNotifierProvider
        ├── products/
        │   ├── products_view.dart     # ConsumerWidget
        │   └── products_notifier.dart # Notifier<ProductsState> + productsNotifierProvider
        ├── product_detail/
        │   ├── product_detail_view.dart
        │   └── product_detail_notifier.dart  # AsyncNotifier + .family
        ├── add_product/
        │   ├── add_product_view.dart   # ConsumerStatefulWidget (holds TextEditingControllers)
        │   └── add_product_notifier.dart
        ├── edit_product/
        │   ├── edit_product_view.dart  # ConsumerStatefulWidget
        │   └── edit_product_notifier.dart
        └── sync_queue/
            ├── sync_queue_view.dart
            └── sync_queue_notifier.dart
```

Note: `_viewmodel.dart` files are deleted after each feature is migrated.
The `_wdiget.dart` naming convention is preserved on all widget files.
No other naming conventions change.

---

## Sources

- Riverpod 2.x official documentation (riverpod.dev) — provider types, autoDispose,
  family, AsyncNotifier, ref.watch vs ref.read semantics. **Confidence: HIGH** (stable
  API, confirmed through training knowledge current to August 2025).
- go_router (pub.dev/packages/go_router) — Flutter team's recommended declarative router,
  current stable series as of 2025. **Confidence: HIGH**.
- Direct codebase analysis of all ViewModel, Service, Repository, and main.dart files
  in this project. **Confidence: HIGH** (source of truth).
- Drift 2.x documentation — stream-based DAO queries remain unchanged. **Confidence: HIGH**.

# Migration Pitfalls: Stacked/GetIt → Riverpod

**Domain:** Offline-first Flutter app — architecture migration only
**Researched:** 2026-03-26
**Confidence:** HIGH (based on direct codebase analysis + Riverpod architecture knowledge)
**Scope:** Specific to this codebase — not generic Riverpod advice

---

## How to Read This File

Each pitfall has:
- **Phase** — which migration phase the risk is highest
- **Warning signs** — observable symptoms before the problem becomes critical
- **Prevention** — the concrete action to take

Phases assumed:
1. Foundation — providers for services/repositories (DI layer)
2. ViewModel migration — one view at a time, leaf-to-root
3. Routing — replace StackedRouter + StackedService.navigatorKey
4. Stacked removal — delete all stacked/get_it packages
5. Cleanup — remove generated files, test coverage

---

## Critical Pitfalls

Mistakes that cause regressions, crashes, or rewrites.

---

### Pitfall 1: SyncService Loses Its `isSyncing` Signal

**Phase:** 1 (Foundation)

**What goes wrong:**
`SyncService` currently uses `ReactiveValue<bool>` and `ListenableServiceMixin` from Stacked to broadcast `isSyncing`. Multiple ViewModels depend on this signal: `ProductsViewModel` shows a spinner, `MainViewModel` shows a sync badge, and `SyncQueueViewModel` drives its UI state.

When `SyncService` is migrated to a plain Dart class (losing `ListenableServiceMixin`), there is no equivalent reactive signal unless one is intentionally added. The `isSyncing` getter becomes a static snapshot that widgets never re-read on change.

**Root cause:** Migrating the service class to remove Stacked mixins without simultaneously replacing the reactive broadcast mechanism. `ReactiveValue<bool>` and `notifyListeners()` disappear; a Riverpod `StateProvider<bool>` or a `StreamController<bool>` backed by a `StreamProvider` must replace them.

**Warning signs:**
- Sync spinner in `ProductsView` header never animates
- `SyncQueueView` "Syncing..." indicator never appears
- `MainViewModel`/`MainNotifier` shows stale pending count badge

**Prevention:**
Convert `SyncService.isSyncing` to a `StreamController<bool>.broadcast()` or expose it as a `ValueNotifier<bool>`. Then create a Riverpod `syncingProvider` backed by that stream. All consuming providers watch `syncingProvider` rather than reading a getter. Do this conversion as part of the service foundation phase — before any ViewModel migrations.

---

### Pitfall 2: Workmanager Callback Dispatcher Cannot Use `ProviderContainer`

**Phase:** 1 (Foundation), 5 (Cleanup)

**What goes wrong:**
`callbackDispatcher()` runs in a fully independent Dart isolate. It currently creates all dependencies manually (`AppDatabase`, `ApiClient`, `ConnectivityService`, `SyncService`) without any DI framework — this is intentional and correct.

The pitfall is trying to make the background isolate use a shared `ProviderContainer` from the foreground app, or registering `callbackDispatcher` dependencies as regular Riverpod providers that are created at app startup. Background isolates have no access to the foreground widget tree, no `ProviderScope`, and no Flutter binding.

**Root cause:** Assuming that because the foreground app uses `ProviderScope`, the background isolate can too. It cannot. The `@pragma('vm:entry-point')` function starts with a blank Dart runtime.

**Warning signs:**
- Any attempt to call `ProviderContainer()` or `ref.read()` inside `callbackDispatcher`
- Importing `flutter_riverpod` providers into the background callback file
- Crash log: "No WidgetsBinding" or "MissingPluginException" in background task

**Prevention:**
Keep `callbackDispatcher` exactly as it is: manual instantiation only. It must never be wired into Riverpod. Document this explicitly in a comment at the top of `main.dart`. The migration does not touch this function — only the foreground service instances registered via `setupLocator()` change. The two code paths (foreground Riverpod, background manual) are permanently separate.

---

### Pitfall 3: Drift Streams Re-subscribed on Every Rebuild

**Phase:** 2 (ViewModel migration)

**What goes wrong:**
`ProductsViewModel` manages up to three distinct Drift stream subscriptions (`watchAllProducts`, `searchProducts`, `watchByCategory`) that swap based on filter state. The `_subscribeToProducts()` method cancels the old subscription and creates a new one. This imperative pattern is difficult to replicate correctly in Riverpod.

The failure mode is using a `StreamProvider` directly on a Drift DAO method. `StreamProvider` creates a new stream subscription every time the provider is rebuilt or its dependencies change. If `selectedCategoryProvider` and `searchQueryProvider` change rapidly (e.g., text input), each change triggers a new database subscription before the previous one is torn down. With Drift, this is safe (queries are lazy) but wastes work and can cause UI flicker.

The more severe failure: recreating the `StreamProvider` family key in a way that doesn't invalidate cleanly, leaving orphaned subscriptions listening to stale queries.

**Warning signs:**
- Product list flickers or briefly empties when typing in search
- Category chip selection causes a momentary empty list
- `flutter_riverpod` debug output shows providers rebuilt unexpectedly often

**Prevention:**
Use `ref.watch` on the filter providers (`searchQueryProvider`, `selectedCategoryProvider`) inside a single `productsStreamProvider` that selects the correct DAO method based on current values. Use `.autoDispose` on the `StreamProvider` so Drift streams are closed when the view is not active. Pattern:

```dart
final productsStreamProvider = StreamProvider.autoDispose<List<Product>>((ref) {
  final query = ref.watch(searchQueryProvider);
  final category = ref.watch(selectedCategoryProvider);
  if (query.isNotEmpty) return repo.searchProducts(query);
  if (category != null) return repo.watchProductsByCategory(category);
  return repo.watchProducts();
});
```

This replaces the entire `_subscribeToProducts` / `_productsSub` imperative pattern with a single declarative provider that Riverpod manages.

---

### Pitfall 4: ConnectivityService Streams Leak After Migration

**Phase:** 1 (Foundation)

**What goes wrong:**
`ConnectivityService` owns a `StreamController<bool>.broadcast()` and a `StreamSubscription` to `connectivity_plus`. It exposes `isOnline` (sync bool) and `onConnectivityChanged` (stream).

`SyncService.initialize()` calls `connectivityService.onConnectivityChanged.listen(...)` and stores the subscription. When these are migrated to Riverpod, the natural pattern is:

```dart
final connectivityProvider = StreamProvider<bool>((ref) { ... });
```

The pitfall: if `SyncService` is also a provider that `ref.listen`s on `connectivityProvider`, the listen callback fires on every `ConnectivityResult` change. But `ConnectivityService._updateStatus` already debounces by value equality — this deduplication must be preserved. Dropping the deduplication causes `syncAll()` to fire on every connectivity poll event from `connectivity_plus`, which on some devices fires multiple times per second.

**Warning signs:**
- Background sync fires repeatedly within seconds of going online
- Excessive API traffic visible in logs after connectivity change
- `SyncService.syncAll()` called when `_isSyncing` is already `true`

**Prevention:**
Keep the debounce logic in the `ConnectivityService`-equivalent provider. Expose a `Stream<bool>` that only emits on actual transitions (online→offline, offline→online), not on every platform callback. The `SyncService` Riverpod equivalent should `ref.listen` on the deduplicated stream, not the raw `connectivity_plus` stream.

---

### Pitfall 5: `ProductDetailView` Hang Regression After Migration

**Phase:** 2 (ViewModel migration — ProductDetailView)

**What goes wrong:**
`ProductDetailViewModel` watches `productsRepo.watchProduct(productId)` and updates `_product` from the stream. When the product is deleted, `watchProduct` emits `null`. The current ViewModel stores `null` in `_product`, the view sees `_product == null` and shows `LoadingIndicator` forever — this is a **known existing bug**.

During migration, the natural Riverpod approach is:

```dart
final productDetailProvider = StreamProvider.autoDispose.family<Product?, int>((ref, id) {
  return ref.watch(productsRepositoryProvider).watchProduct(id);
});
```

This exposes the same bug even more directly: `AsyncValue.data(null)` is not the same as `AsyncValue.loading()`. If the widget checks `when(data: (p) => p == null ? Loading() : Detail(p))`, the `null` state is silently treated as loading, perpetuating the hang.

**Warning signs:**
- Deleting a product from the detail screen causes infinite loading indicator
- `AsyncValue.data(null)` reaching the widget and being matched as loading

**Prevention:**
When writing the `productDetailProvider`, explicitly handle `null` as a "product not found / deleted" state. Map the stream: `watchProduct(id).map((p) => p ?? throw ProductNotFoundException(id))`, which converts `null` emission to an error state. The widget then shows an error/not-found UI instead of spinning. This migration is the correct moment to fix this known bug — document it in the phase task.

---

### Pitfall 6: Navigation Breaks When `StackedService.navigatorKey` Is Removed

**Phase:** 3 (Routing)

**What goes wrong:**
`MyApp` in `main.dart` passes `navigatorKey: StackedService.navigatorKey` to `MaterialApp`. Every ViewModel uses `_navigationService.navigateTo(Routes.xxx)`, which internally uses that same key. `StackedRouter().onGenerateRoute` generates routes from `app.router.dart` (generated by Stacked code-gen).

When ViewModels are migrated to Riverpod notifiers but the routing layer is still Stacked, navigation calls work. But if `stacked_services` is removed before the routing migration, `StackedService.navigatorKey` disappears and the app loses all navigation.

The ordering trap: migrating all ViewModels first (removing `locator<NavigationService>()` calls) without having a Riverpod-compatible navigator ready means navigation calls compile but crash at runtime.

**Warning signs:**
- `NavigationService` removed from locator but app still tries to navigate
- Compile errors in ViewModels that had `locator<NavigationService>()` calls
- Routes defined in `app.router.dart` (generated) not matched after switching to GoRouter or Navigator 2.0

**Prevention:**
Keep the routing layer entirely untouched until all ViewModels are migrated. Retain `stacked_services` specifically for `NavigationService`, `SnackbarService`, and `DialogService` while ViewModel-by-ViewModel migration happens. Only after all six ViewModels are migrated to Riverpod do you replace the routing layer. Migration order must be: services → repositories → ViewModels (leaf-to-root) → routing → package removal.

---

### Pitfall 7: `IndexedStack` Keeps All Tab Providers Alive — Accidentally or Incorrectly

**Phase:** 2 (ViewModel migration — MainView)

**What goes wrong:**
`MainView` uses `IndexedStack` with `ProductsView` and `SyncQueueView` as children. Under Stacked, both ViewModels are instantiated and held alive simultaneously — this is documented as a known performance concern in CONCERNS.md.

Under Riverpod with `.autoDispose`, providers are torn down when no widget is actively reading them. With `IndexedStack`, the hidden tab's widget tree stays mounted (that is the point of `IndexedStack`), so its providers are _not_ disposed. This is actually the correct behavior for this UI pattern.

The pitfall: using `.autoDispose` on heavy providers like `productsStreamProvider` under the impression that it will save memory, not realizing `IndexedStack` keeps the widget mounted. The Drift stream subscription never closes. More dangerous: using a non-autoDispose provider for a screen intended to reset state on re-entry, which never resets because the provider persists for the app's lifetime.

**Warning signs:**
- Navigating back to a tab doesn't reset scroll position or filters (provider never disposed)
- Memory profiler shows two active Drift stream subscriptions even when only one tab is visible

**Prevention:**
For tab screens behind `IndexedStack`: do NOT use `.autoDispose` on providers that must persist across tab switches (product list, category filters). For route-pushed screens (ProductDetail, AddProduct, EditProduct): DO use `.autoDispose` so state resets when the route is popped. Apply `.autoDispose` intentionally based on the widget lifecycle, not by default.

---

## Moderate Pitfalls

---

### Pitfall 8: `TextEditingController` Lifetime in Form Notifiers

**Phase:** 2 (ViewModel migration — AddProduct, EditProduct)

**What goes wrong:**
`AddProductViewModel` and `EditProductViewModel` each own five `TextEditingController` instances and dispose them in `dispose()`. Stacked ties ViewModel lifecycle to the route — `dispose()` is called when the view is popped.

In Riverpod, a `StateNotifier` or `Notifier` class does not directly own `TextEditingController` instances — controllers are Flutter objects that belong to the widget tree. Putting `TextEditingController` inside a Riverpod notifier requires calling `ref.onDispose` to clean them up, which is supported but unusual. Forgetting `ref.onDispose` causes the controller's `TextEditingValue` listeners to keep an old BuildContext alive, which is a memory leak.

**Warning signs:**
- Flutter debug output: "A TextEditingController was disposed while it had active listeners"
- Form text fields retain values from a previous navigation visit
- Memory profiler shows growing `TextEditingController` allocations

**Prevention:**
Option A (preferred): Keep `TextEditingController` instances in the `State` of a `StatefulWidget` that wraps the form. The notifier holds only form field values as plain `String` state. The widget syncs controllers to notifier state. This is idiomatic Flutter.

Option B: Place controllers in the notifier and register `ref.onDispose(() { controller.dispose(); })` for each. Use `.autoDispose` on the notifier provider. Verify that `ref.onDispose` fires when the route is popped.

---

### Pitfall 9: `SnackbarService` and `DialogService` Have No Riverpod Equivalent

**Phase:** 3 (Routing)

**What goes wrong:**
`stacked_services` provides `SnackbarService` and `DialogService` as GetIt singletons that use `StackedService.navigatorKey` to show overlays imperatively from outside the widget tree. Five ViewModels use these services.

Riverpod has no built-in mechanism for this. The common replacement patterns each have tradeoffs: `ScaffoldMessenger.of(context)` requires a `BuildContext`; a `GlobalKey<ScaffoldMessengerState>` is possible but is global mutable state; third-party packages like `flash` or `overlay_support` add dependencies.

If snackbar/dialog calls are left wired to `stacked_services` during ViewModel migration, the services still work. But once `stacked_services` is removed, all five ViewModels fail to show feedback.

**Warning signs:**
- Compile errors when `stacked_services` is removed: `SnackbarService` not found
- Notifier methods that need to show user feedback have no clean way to do so without a context

**Prevention:**
Decide the replacement strategy before migrating any ViewModel that uses snackbars or dialogs. The lowest-risk option is a `GlobalKey<ScaffoldMessengerState>` placed in the app root and provided via a Riverpod `Provider<GlobalKey<...>>`. This replicates the stacked_services pattern without new packages. Migrate all snackbar/dialog calls to use this pattern as part of Phase 3 (routing), not piecemeal during Phase 2.

---

### Pitfall 10: Dual DI Systems Active Simultaneously

**Phase:** 1–2 (transition period)

**What goes wrong:**
During incremental migration, some ViewModels will still use `locator<T>()` while others use `ref.watch(someProvider)`. Both systems resolve the same service classes. The risk is two separate instances: one instance registered in GetIt, another created by Riverpod.

Concretely: if `SyncService` is migrated to a Riverpod provider first, but `ProductsViewModel` (still on Stacked) reads `locator<SyncService>()`, it gets the GetIt instance. The Riverpod `syncServiceProvider` creates a different instance. Now there are two `SyncService` objects with independent `_isSyncing` state and separate connectivity subscriptions. The Drift database is opened twice from the foreground, which SQLite allows but makes WAL behavior unpredictable.

**Warning signs:**
- Sync spinner fires for one ViewModel but not another
- Connectivity event triggers sync twice
- Database connection pool shows two foreground connections

**Prevention:**
During migration, wrap GetIt singletons in Riverpod providers rather than recreating them. Pattern:

```dart
// Bridge: exposes the existing GetIt instance to Riverpod during migration
final syncServiceProvider = Provider<SyncService>((ref) => locator<SyncService>());
```

This ensures both systems resolve the same object instance until GetIt is removed entirely. Remove the bridge provider only in the final cleanup phase when GetIt is gone.

---

### Pitfall 11: `watchAll()` on SyncQueue Causes Excessive Rebuilds

**Phase:** 2 (ViewModel migration — SyncQueueView)

**What goes wrong:**
`SyncQueueDao.watchAll()` has no pagination limit (noted in CONCERNS.md). Under Stacked, this stream populates `_operations`, and `notifyListeners()` rebuilds the entire view. Under Riverpod with a `StreamProvider`, every Drift emission (including status column updates during sync) triggers a full rebuild of the `SyncQueueView` list.

During an active sync, `SyncService` calls `markInProgress`, `markCompleted`, and `markFailed` in sequence for each operation. Each DAO write emits a new Drift stream event. The `SyncQueueView` may rebuild three times per operation. If the queue has 50 items, this is 150 rebuilds during a single sync cycle.

**Warning signs:**
- Visible list jitter during sync operations
- Flutter performance overlay shows excessive raster/UI thread work during sync
- `SyncQueueView` appears to "flash" as items change status

**Prevention:**
Add a `distinct()` operator on the stream before providing it to Riverpod, or use Drift's built-in query deduplication. At minimum, the `StreamProvider` wrapping `watchAll()` should emit only when the list content meaningfully changes. For the migration scope, the most pragmatic fix is to add `distinct()` to the stream chain in the provider. The underlying `watchAll()` unbounded issue is pre-existing technical debt and out of scope for migration, but the provider layer can mitigate rebuild frequency.

---

### Pitfall 12: Scroll Controller Ownership in Riverpod

**Phase:** 2 (ViewModel migration — ProductsView)

**What goes wrong:**
`ProductsViewModel` owns a `ScrollController`, adds a listener in `initialize()`, and disposes it in `dispose()`. Under Stacked, the controller's lifecycle matches the ViewModel's, which matches the route.

Under Riverpod, if the `ScrollController` is placed inside an `AsyncNotifier` or `Notifier`, it must be disposed via `ref.onDispose`. However, `ScrollController` is a Flutter framework object that only has meaning when attached to a widget. Placing it inside a provider creates a conceptual mismatch: providers should hold data/state, not widget infrastructure.

If the `ScrollController` ends up in a non-autoDispose provider, it is never disposed when the screen is exited. If it ends up in an autoDispose provider that is torn down mid-scroll (e.g., due to navigation), the attached `ListView.builder` crashes with "ScrollController not attached."

**Warning signs:**
- "ScrollController is attached to multiple scroll views" error in debug output
- Infinite scroll pagination stops working after first navigation away and back
- `_loadMore` never fires despite reaching list bottom

**Prevention:**
Move the `ScrollController` out of the provider entirely. Declare it in the `State` of a `StatefulWidget` wrapping `ProductsView`, or use a `useScrollController()` hook if `flutter_hooks` is adopted. The provider holds only the pagination state (`currentSkip`, `hasMore`, `isLoadingMore`) as plain values. The widget calls provider methods when the scroll listener fires.

---

## Minor Pitfalls

---

### Pitfall 13: Generated Code Conflicts During Incremental Migration

**Phase:** 1–4 (any phase)

**What goes wrong:**
`app.locator.dart` and `app.router.dart` are generated by `stacked_generator`. If `app.dart` (the `@StackedApp` config) is modified or deleted before routing is replaced, `build_runner` will regenerate broken or empty files. If `build_runner` is run while Riverpod code-gen (`riverpod_generator`) is also configured, both generators run simultaneously. Annotation conflicts or missing imports in generated files cause the entire build to fail.

**Warning signs:**
- `build_runner` output shows errors from `stacked_generator` during Riverpod provider generation
- `app.locator.dart` is regenerated with missing registered types after `app.dart` changes
- Compile fails with "Type X is not registered" despite type being in GetIt

**Prevention:**
Do not run `build_runner` between the time `app.dart` is modified and the time routing is fully replaced. Keep `app.dart` frozen until Phase 3 (routing migration). Add `riverpod_generator` to `pubspec.yaml` before any ViewModels are migrated, run `build_runner` once to confirm both generators coexist cleanly. Use `build_runner build --delete-conflicting-outputs` on every generation step during migration.

---

### Pitfall 14: `AppViewModel` Base Class Has No Riverpod Equivalent

**Phase:** 2 (ViewModel migration — all views)

**What goes wrong:**
`AppViewModel extends BaseViewModel` adds `isLoading`, `errorMessage`, `hasErrorMessage`, `setLoading`, `setErrorMessage`, and `clearErrorMessage`. Four ViewModels (`ProductDetailViewModel`, `AddProductViewModel`, `EditProductViewModel`, and implicitly others via inheritance) use `setLoading(true/false)` to show loading state during async operations.

Migrating to Riverpod, developers often recreate `isLoading` as a separate `StateProvider<bool>` alongside the data state. This splits what should be a unified `AsyncValue<T>` into two separate signals that can go out of sync: `data` loads, then `isLoading` is set to false separately, with a frame of inconsistency between.

**Warning signs:**
- Loading spinner shows briefly after data has already appeared
- "Failed" state and `isLoading: true` appear simultaneously
- Manual `isLoading` bool getting out of sync with actual async operation state

**Prevention:**
Replace the entire `AppViewModel` loading/error pattern with `AsyncNotifier<T>` (for Riverpod 2.x) or `AsyncValue<T>` state in a `Notifier<T>`. Use `AsyncValue.guard(() => ...)` to wrap async operations. `AsyncValue` natively represents loading/data/error as a single sealed state — no manual loading flag needed. Delete `AppViewModel` when all four dependent ViewModels are migrated.

---

### Pitfall 15: Retry Threshold Inconsistency Survives Migration

**Phase:** 2 (ViewModel migration — SyncQueueView / SyncService)

**What goes wrong:**
`SyncService._processOperation` checks `op.retryCount >= 2` before marking a product as failed (effectively 3 attempts). This differs from a separate threshold elsewhere in the codebase (the CONCERNS.md "< 3 in one, >= 2 in another" inconsistency). When `SyncService` is rewritten as a Riverpod-aware class, developers will write new logic from scratch. The inconsistency will be silently carried forward, or worse, both thresholds will diverge further as different people migrate each location.

**Warning signs:**
- Sync operations marked "failed" after 2 attempts in one code path, 3 in another
- `SyncQueueView` shows inconsistent retry count before "failed" status

**Prevention:**
Before migrating `SyncService`, extract the retry threshold to a single constant (e.g., `SyncConfig.maxRetries = 3`) and use it in every location. Do this as a single, isolated commit before the ViewModel migration for `SyncService` begins. This is a one-line change that eliminates a category of bug.

---

## Incremental Migration Strategy

**Do NOT migrate everything at once.** The correct order respects dependency direction and keeps the app running at every commit.

### Phase 1 — Service and Repository Providers (DI Foundation)

Migrate: `AppDatabase`, `ApiClient`, `ConnectivityService`, `SyncService`, `ProductsRepository`, `CategoriesRepository`.

All six services are created as Riverpod `Provider<T>` or `StreamProvider` wrappers. During this phase, use bridge providers that return the existing GetIt singletons (see Pitfall 10). The app still uses Stacked ViewModels and GetIt — nothing changes visually. This phase establishes the Riverpod container (`ProviderScope` in `main.dart`) and verifies providers resolve correctly.

Key risk in this phase: Pitfall 2 (Workmanager), Pitfall 4 (ConnectivityService streams), Pitfall 10 (dual DI).

### Phase 2 — ViewModel Migration (Leaf-to-Root)

Migrate ViewModels in this order:
1. `SyncQueueViewModel` — simplest, pure Drift stream + service call, no navigation
2. `AddProductViewModel` — form only, uses snackbar/navigation but manageable
3. `EditProductViewModel` — same pattern as Add, initial data from route argument
4. `ProductDetailViewModel` — stream-based, fix the null/deleted hang bug here (Pitfall 5)
5. `ProductsViewModel` — most complex: multi-stream, pagination, scroll, two reactive services
6. `MainViewModel` — root view, Drift stream for pending count, IndexedStack coordination

Start from leaves (no sub-navigation) and move up to `MainViewModel` last. Each ViewModel migration is its own PR/commit. The app must run correctly after each individual step.

Key risk in this phase: Pitfall 3 (Drift streams), Pitfall 5 (ProductDetail hang), Pitfall 7 (IndexedStack), Pitfall 8 (TextEditingController), Pitfall 12 (ScrollController), Pitfall 14 (AppViewModel base class).

### Phase 3 — Routing Migration

Only begin after all six ViewModels are migrated. Replace `StackedRouter` and `StackedService.navigatorKey` with GoRouter (recommended) or Navigator 1.0 imperative calls. Replace `NavigationService` calls in notifiers with a `RouterNotifier` or `ref.read(routerProvider).go(...)` pattern. Replace `SnackbarService` and `DialogService` (see Pitfall 9).

Key risk in this phase: Pitfall 6 (navigation breaks), Pitfall 9 (snackbar/dialog).

### Phase 4 — Package Removal

Remove from `pubspec.yaml`: `stacked`, `stacked_services`, `stacked_generator`, `get_it`, `injectable`, `injectable_generator`. Delete `app.locator.dart`, `app.router.dart`, `app.dart`, `stacked.json`. Run `flutter pub get` and confirm zero compile errors.

Key risk: Any hidden `locator<T>()` call that was not caught during ViewModel migration.

### Phase 5 — Cleanup and Test Coverage

Remove `DatabaseService` wrapper (it only initializes `AppDatabase` — in Riverpod this is a one-liner provider). Delete `AppViewModel` base class. Write the first meaningful tests: provider unit tests for `SyncService` logic and `ProductsRepository` stream behavior using `AppDatabase.forTesting()` (constructor already exists, never used).

---

## Phase-Specific Warning Summary

| Phase | Topic | Most Likely Pitfall | Mitigation |
|-------|-------|---------------------|------------|
| 1 — Foundation | SyncService reactive state | Pitfall 1: isSyncing signal lost | Replace ReactiveValue with StreamController<bool> before migrating consumers |
| 1 — Foundation | Connectivity stream | Pitfall 4: debounce dropped, excessive sync triggers | Preserve value-equality deduplication in connectivity provider |
| 1 — Foundation | Workmanager isolate | Pitfall 2: background isolate can't use ProviderScope | Leave callbackDispatcher as manual instantiation permanently |
| 1–2 — Transition | Dual DI | Pitfall 10: two instances of same service | Use bridge providers returning GetIt singletons |
| 2 — ProductsView | Drift stream selection | Pitfall 3: stream re-subscribed on every rebuild | Single autoDispose StreamProvider watching filter providers |
| 2 — ProductsView | Scroll controller | Pitfall 12: controller in wrong owner | Move ScrollController to StatefulWidget State |
| 2 — ProductDetailView | Null product stream | Pitfall 5: hang on deleted product | Map null emission to error/not-found state |
| 2 — MainView | IndexedStack lifetime | Pitfall 7: autoDispose on always-mounted providers | No autoDispose on tab-level providers |
| 2 — Form views | TextEditingController | Pitfall 8: controller leak or retained state | Keep controllers in StatefulWidget, not notifier |
| 2 — All views | AppViewModel base class | Pitfall 14: manual isLoading bool | Use AsyncValue.guard instead |
| 3 — Routing | Navigation before routing migrated | Pitfall 6: StackedService.navigatorKey removed too early | Keep routing layer until all ViewModels are done |
| 3 — Routing | Snackbar/Dialog services | Pitfall 9: no Riverpod equivalent | Decide GlobalKey strategy before Phase 2 snackbar callers are migrated |
| Any | Build runner conflicts | Pitfall 13: stacked_generator vs riverpod_generator | Freeze app.dart until Phase 3; use --delete-conflicting-outputs |
| Any | Retry threshold | Pitfall 15: inconsistency carried forward | Extract to SyncConfig constant before SyncService rewrite |

---

## Sources

- Direct codebase analysis: all files under `lib/` (2026-03-26)
- `/Users/admin/Documents/offline_first_app/.planning/codebase/CONCERNS.md`
- `/Users/admin/Documents/offline_first_app/.planning/codebase/INTEGRATIONS.md`
- Riverpod 2.x architecture: `AsyncNotifier`, `StreamProvider`, `ref.onDispose`, autoDispose lifecycle (HIGH confidence — architecture patterns are stable since Riverpod 2.0)
- Workmanager Flutter plugin isolate model (HIGH confidence — documented isolate constraint)
- Drift stream emission model: WAL, stream deduplication behavior (HIGH confidence — Drift documentation)

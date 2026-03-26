# Research Summary: Stacked MVVM → Riverpod Migration

**Project:** Offline-First Product Store
**Synthesized:** 2026-03-26
**Sources:** STACK.md, FEATURES.md, ARCHITECTURE.md, PITFALLS.md, PROJECT.md

---

## Executive Summary

This is a presentation-layer architecture swap on a working offline-first Flutter app. The domain and data layers (Drift/SQLite, Dio, repositories, Freezed models) are untouched — every change is confined to `lib/ui/views/`, `lib/app/`, and `lib/core/viewmodels/`. The migration replaces five interlocking Stacked/GetIt constructs — `BaseViewModel`, `ReactiveViewModel`, `StackedView`, `ListenableServiceMixin`, and the GetIt locator — with their direct Riverpod equivalents: `Notifier`/`AsyncNotifier`, `ConsumerWidget`, `StreamProvider`, and a provider graph. There are no new user-facing features; this is a foundation rebuild so future development has a clean base.

The recommended approach is a strict bottom-up, feature-at-a-time migration with a bridge pattern during the transition period. The provider graph (Tier 1–3) must be established first, then ViewModels are converted one at a time from leaf screens to root, then routing is replaced, then Stacked packages are deleted. Each step must leave the app fully functional. The single non-negotiable constraint is that both DI systems must not instantiate the same service class independently during overlap — the bridge provider pattern (wrapping the GetIt singleton in a Riverpod provider) is mandatory to prevent duplicate service instances.

The highest-confidence risk in this migration is the `SyncService.isSyncing` signal. It currently propagates via `ReactiveValue<bool>` + `ListenableServiceMixin`, and three ViewModels depend on it. If `ListenableServiceMixin` is stripped without a replacement broadcast mechanism in place, three screens silently lose their sync status indicators. This must be resolved in Phase 1 before any ViewModel is touched. The routing layer is the second structural constraint: `stacked_services` cannot be removed until all six ViewModels are off `NavigationService`, `SnackbarService`, and `DialogService`. Routing migration is Phase 3 — not something to parallelize with ViewModel migration.

---

## Recommended Stack Delta

### Remove

| Package | Type | Reason |
|---------|------|--------|
| `stacked` ^3.5.0 | dependency | Replaced entirely by `flutter_riverpod` |
| `stacked_services` ^1.6.0 | dependency | Navigation/snackbar/dialog replaced by go_router + Flutter APIs |
| `get_it` ^8.3.0 | transitive | `ProviderScope` replaces the global object graph |
| `stacked_shared` ^1.4.2 | transitive | Disappears with stacked |
| `stacked_generator` ^2.0.0 | dev_dependency | Replaced by `riverpod_generator` |

**Generated files to delete (after migration complete):**
- `lib/app/app.locator.dart`
- `lib/app/app.router.dart`
- `lib/core/viewmodels/app_viewmodel.dart`
- `stacked.json`

### Add

| Package | Constraint | Type | Purpose |
|---------|-----------|------|---------|
| `flutter_riverpod` | `^2.6.1` | dependency | Runtime: ProviderScope, ConsumerWidget, ref.watch/read |
| `riverpod_annotation` | `^2.3.5` | dependency | Runtime: @riverpod annotations (required peer) |
| `go_router` | `^14.3.0` | dependency | Replaces StackedRouter + NavigationService |
| `riverpod_generator` | `^2.4.3` | dev_dependency | Generates provider boilerplate from @riverpod |
| `custom_lint` | `^0.6.7` | dev_dependency | Required peer for riverpod_lint |
| `riverpod_lint` | `^2.3.13` | dev_dependency | Enforces Riverpod best practices in analyzer |

**`analysis_options.yaml` addition required:**
```yaml
analyzer:
  plugins:
    - custom_lint
```

**Version note:** All three Riverpod packages (`flutter_riverpod`, `riverpod_annotation`, `riverpod_generator`) must share the same major version. Verify current versions on pub.dev before running `dart pub get` — training data cutoff August 2025.

**`build_runner` unchanged.** The existing `dart run build_runner build --delete-conflicting-outputs` command covers Drift, Freezed, json_serializable, and Riverpod generation simultaneously.

---

## Table Stakes

Everything below must be migrated or the app does not function. Listed in migration dependency order.

### 1. Provider Graph (DI Foundation)
Replace `setupLocator()` + 9 GetIt registrations with a Riverpod provider graph:

| Tier | Providers | Pattern |
|------|-----------|---------|
| 1 — Infrastructure | `appDatabaseProvider`, `apiClientProvider` | `Provider<T>` (non-autoDispose) |
| 2 — Services | `connectivityServiceProvider`, `syncServiceProvider` | `StreamProvider<bool>`, `Provider<SyncService>` (non-autoDispose) |
| 3 — Repositories | `productsRepositoryProvider`, `categoriesRepositoryProvider` | `Provider<T>` (non-autoDispose) |
| 4 — Query Streams | `productsStreamProvider`, `categoriesStreamProvider`, `pendingSyncCountProvider`, `productByIdProvider` | `StreamProvider.autoDispose` and `.family` |
| 5 — UI Notifiers | One per screen | `NotifierProvider.autoDispose` or `AsyncNotifierProvider.autoDispose` |

`ProviderScope` wraps `MyApp` at the root. No registration step. Dependencies are lazy-initialized on first access.

### 2. `ListenableServiceMixin` → StreamProvider (Critical — do first)
`SyncService` must expose `isSyncing` as a `StreamController<bool>.broadcast()` (or `ValueNotifier<bool>`) before any ViewModel migration begins. Three screens (`ProductsView`, `MainView`, `SyncQueueView`) depend on this signal. Stripping `ListenableServiceMixin` without a replacement causes silent loss of all sync status indicators.

### 3. All 6 ViewModels → Notifiers

| Current ViewModel | Extends | Target Notifier | Pattern |
|---|---|---|---|
| `AppViewModel` | `BaseViewModel` | Delete entirely | Absorbed into `AsyncValue<T>` |
| `ProductsViewModel` | `ReactiveViewModel` | `ProductsNotifier` | `Notifier<ProductsState>` |
| `MainViewModel` | `ReactiveViewModel` | `MainNotifier` | `Notifier<MainState>` |
| `SyncQueueViewModel` | `ReactiveViewModel` | `SyncQueueNotifier` | `Notifier<SyncQueueState>` |
| `AddProductViewModel` | `AppViewModel` | `AddProductNotifier` | `Notifier<AddProductState>` |
| `EditProductViewModel` | `AppViewModel` | `EditProductNotifier` | `Notifier<EditProductState>` |
| `ProductDetailViewModel` | `AppViewModel` | `ProductDetailNotifier` | `AsyncNotifier<Product?>` + `.family` |

`StackedView<VM>` → `ConsumerWidget`. Form views → `ConsumerStatefulWidget` (hold `TextEditingController` instances in widget `State`, not in the notifier).

### 4. Navigation → go_router
`NavigationService` + `StackedService.navigatorKey` + `StackedRouter` + `app.router.dart` → single `GoRouter` instance exposed as a provider. `MaterialApp` → `MaterialApp.router`. Navigation calls belong in the widget layer via `context.go(...)` responding to notifier state changes via `ref.listen`.

### 5. SnackbarService / DialogService → Flutter APIs
`SnackbarService` → `ScaffoldMessenger.of(context).showSnackBar(...)` triggered from `ref.listen` on a `snackbarMessage` state field. `DialogService` → `showDialog(context, ...)` called in the widget's `onPressed` handler; the notifier's `deleteProduct()` assumes confirmation already occurred. `BottomSheetService` is dead code — do not port.

### 6. Stacked Package Removal
Only after all six ViewModels and routing are migrated: remove `stacked`, `stacked_services`, `stacked_generator` from `pubspec.yaml`, delete generated files, run `flutter pub get`. This is a cleanup commit, not a migration step.

---

## Migration Order

Five phases. The app must compile and run correctly after every individual commit within each phase.

### Phase 1 — DI Foundation
**Goal:** Riverpod provider graph exists. Both DI systems coexist safely.

1. Add `ProviderScope` to `MyApp` in `main.dart` alongside the existing locator.
2. Add `appDatabaseProvider` to `database.dart`, `apiClientProvider` to `api_client.dart`.
3. Strip `ListenableServiceMixin` from `ConnectivityService` and `SyncService`. Replace `ReactiveValue<bool>` with `StreamController<bool>.broadcast()`. Add `connectivityServiceProvider` and `syncServiceProvider`.
4. Add `productsRepositoryProvider`, `categoriesRepositoryProvider`. Add Tier 4 stream providers.
5. Use bridge providers for all GetIt singletons: `final syncServiceProvider = Provider<SyncService>((ref) => locator<SyncService>())`. This prevents dual-instance bugs.
6. Extract `SyncConfig.maxRetries` constant before touching `SyncService` (fixes retry threshold inconsistency).

**Verification:** App behavior unchanged. Temporary `Consumer` widget reads `productsStreamProvider` and renders the same list.

**Primary pitfall risks:** Pitfall 1 (isSyncing signal), Pitfall 2 (Workmanager isolate — leave `callbackDispatcher` untouched permanently), Pitfall 4 (connectivity debounce), Pitfall 10 (dual DI instances).

---

### Phase 2 — ViewModel Migration (Leaf to Root)
**Goal:** All six ViewModels replaced with Riverpod Notifiers. No Stacked types remain in view files.

Migrate in this order — each is its own commit:

1. **`SyncQueueViewModel`** → `SyncQueueNotifier` — simplest: one Drift stream, no navigation, two action methods. Add `distinct()` to the `watchAll()` stream to prevent excessive rebuilds during sync.
2. **`MainViewModel`** → `MainNotifier` — tab index state + pending count stream. Do NOT use `.autoDispose` on tab-level providers (IndexedStack keeps widgets mounted).
3. **`AddProductViewModel`** → `AddProductNotifier` — form state. `TextEditingController` instances stay in `ConsumerStatefulWidget.State`. Introduce snackbar-as-state pattern: `String? snackbarMessage` field + `clearSnackbar()` method.
4. **`EditProductViewModel`** → `EditProductNotifier` — same pattern as Add, initialized with incoming `Product` route argument.
5. **`ProductDetailViewModel`** → `ProductDetailNotifier` — `.family` provider parameterized by `productId`. **Fix the known hang bug here:** map `null` emission from `watchProduct` to a not-found error state instead of `AsyncData(null)`.
6. **`ProductsViewModel`** → `ProductsNotifier` — most complex: search debounce, category filter, scroll-driven pagination. Move `ScrollController` to `StatefulWidget.State`. Use a single `StreamProvider.autoDispose` watching filter providers to replace the imperative `_subscribeToProducts` / `_productsSub` pattern.

For each: write Notifier + state class, convert view from `StackedView<VM>` to `ConsumerWidget`/`ConsumerStatefulWidget`, delete the `_viewmodel.dart` file, remove `locator<T>()` calls. Use `AsyncValue.guard()` rather than manual `isLoading` booleans — do not recreate `AppViewModel`.

**Primary pitfall risks:** Pitfall 3 (Drift stream re-subscription), Pitfall 5 (ProductDetail null hang), Pitfall 7 (IndexedStack autoDispose), Pitfall 8 (TextEditingController), Pitfall 12 (ScrollController), Pitfall 14 (AppViewModel base class).

---

### Phase 3 — Routing Migration
**Goal:** `stacked_services` removed from all call sites. `go_router` is the sole navigation system.

Only begin after all six ViewModels are migrated.

1. Implement `go_router` configuration — 5 routes (`Main`, `ProductDetail`, `AddProduct`, `EditProduct`, `SyncQueue`).
2. Replace `StackedService.navigatorKey` in `MyApp` with `MaterialApp.router(routerConfig: goRouter)`.
3. Replace all `_navigationService.navigateTo(...)` calls in notifiers with `context.go(...)` called from widget `ref.listen` responding to a navigation intent in notifier state.
4. Replace all `SnackbarService` calls — already patterned in Phase 2. Verify all views handle snackbar state.
5. Replace `DialogService` in `ProductDetailView` — move `showDialog` to `onPressed` in the widget.
6. Keep `app.dart`/`app.locator.dart`/`app.router.dart` frozen until routing replacement is complete to avoid `build_runner` conflicts (Pitfall 13).

**Primary pitfall risks:** Pitfall 6 (navigation breaks if routing migrated too early), Pitfall 9 (snackbar/dialog have no Riverpod equivalent — must be planned before Phase 2 snackbar-using VMs), Pitfall 13 (build_runner conflicts).

---

### Phase 4 — Package Removal
**Goal:** Zero Stacked/GetIt code or imports remain.

1. Remove from `pubspec.yaml`: `stacked`, `stacked_services`, `stacked_generator`, `get_it` (and transitives).
2. Delete: `lib/app/app.locator.dart`, `lib/app/app.router.dart`, `lib/core/viewmodels/app_viewmodel.dart`, `stacked.json`.
3. Rewrite `lib/app/app.dart` as a plain `MaterialApp.router` wrapper — no `@StackedApp`.
4. Remove bridge providers (now resolved directly, not via GetIt).
5. Remove `setupLocator()` call from `main.dart`. Simplify to `ProviderScope` + Workmanager registration only.
6. Run `flutter pub get` + `dart run build_runner build --delete-conflicting-outputs` + `flutter analyze`. Confirm zero errors.

**Primary pitfall risk:** Any residual `locator<T>()` call missed during ViewModel migration.

---

### Phase 5 — Cleanup and Test Baseline
**Goal:** Technical debt addressed. First meaningful tests written.

1. Verify `riverpod_lint` warnings are clean.
2. Write provider unit tests using `ProviderContainer` with overrides — start with `SyncService` logic and `ProductsRepository` stream behavior. Use the existing `AppDatabase.forTesting()` constructor.
3. Remove the broken scaffold counter widget test and replace with at least one real integration or widget test.
4. Audit and address known pre-existing issues from PROJECT.md: `markFailed` DAO race condition, `hasMore` pagination with active filters.

---

## Top 5 Watch Out For

### 1. SyncService loses its `isSyncing` signal (Phase 1 — CRITICAL)
`ReactiveValue<bool>` + `ListenableServiceMixin` disappears when Stacked is stripped. Three screens go dark silently. Replace with `StreamController<bool>.broadcast()` inside `SyncService` and a `syncingProvider` backed by it before migrating a single ViewModel. Do this first in Phase 1 and verify it before anything else.

### 2. Dual DI instances of the same service (Phase 1–2 — CRITICAL)
If `SyncService` or `AppDatabase` is instantiated by both GetIt and Riverpod simultaneously, there are two database connections in the foreground and two connectivity subscriptions. Use bridge providers that return the existing GetIt singleton: `Provider<SyncService>((ref) => locator<SyncService>())`. Remove bridges only in Phase 4 when GetIt is gone.

### 3. `ProductDetailView` hang on deleted product (Phase 2 — CRITICAL)
This is a known pre-existing bug. `watchProduct(id)` emits `null` when the product is deleted; the current ViewModel treats `null` as permanent loading. In Riverpod, `AsyncData(null)` reaches the widget and is silently mishandled. Fix it during `ProductDetailNotifier` migration: map `null` emissions to a thrown `ProductNotFoundException`, converting the state to `AsyncError` so the widget navigates back or shows a not-found screen.

### 4. Navigation removed before routing is replaced (Phase 3 — CRITICAL)
`stacked_services` must not be removed until `go_router` is fully wired. If `NavigationService` is stripped from notifiers before `go_router` handles those routes, navigation calls compile but crash or silently do nothing. Maintain the routing layer intact through all of Phase 2. Only begin Phase 3 after all six ViewModels are done.

### 5. `TextEditingController` / `ScrollController` in the wrong owner (Phase 2 — HIGH)
Both are Flutter widget-lifecycle objects. Placing them inside a Riverpod `Notifier` works technically (with `ref.onDispose`) but is conceptually wrong and creates subtle lifecycle bugs — retained form values on re-entry, "ScrollController attached to multiple views" crashes, infinite scroll pagination breaking after back navigation. Keep both in `ConsumerStatefulWidget.State`. The notifier holds only plain Dart values.

---

## Anti-Patterns to Reject Outright

These are the Stacked patterns most likely to be "ported" incorrectly. Reject all of them:

| Anti-Pattern | Why It's Wrong | Correct Approach |
|---|---|---|
| Recreate `NavigationService` singleton in Riverpod | Couples navigation (UI concern) to notifiers; breaks testability | `context.go(...)` from `ref.listen` in the widget |
| Recreate `SnackbarService`/`DialogService` singletons | Same reason; dialogs need `BuildContext` | Snackbar: state field + `ref.listen`; Dialog: `showDialog` in `onPressed` |
| `AppNotifier` base class with `setLoading`/`setError` | Fights `AsyncValue<T>` which already encodes all three states | Use `AsyncNotifier` + `AsyncValue.guard()` |
| `RiverpodListenableMixin` mimicking `listenableServices` | Creates a second reactive system on top of Riverpod's | Services are providers; notifiers use `ref.watch` |
| Keep `stacked_generator` alongside `riverpod_generator` | Generated files keep Stacked imports alive; packages can't be removed | Migrate all usages first, delete generated files in one commit |

---

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack decisions (package choices) | HIGH | Riverpod 2.x + go_router are stable; versions need pub.dev verification |
| Feature inventory (what Stacked constructs exist) | HIGH | Based on direct codebase read of all source files |
| Architecture (provider hierarchy, patterns) | HIGH | Riverpod 2.x API is stable since 2023; patterns are canonical |
| Pitfall identification | HIGH | Most pitfalls derived from direct codebase analysis, not speculation |
| Exact package version constraints | MEDIUM | Training data cutoff August 2025; verify on pub.dev before `dart pub get` |
| `go_router` ^14.x | MEDIUM | Was at ~13.x in early 2025; verify current stable minor on pub.dev |
| Workmanager isolate behavior | HIGH | Documented constraint; callbackDispatcher pattern must remain manual |

**Overall confidence: HIGH.** The migration scope is well-bounded, the codebase was read directly, and Riverpod 2.x patterns are stable and well-documented. The only uncertain variables are specific package patch versions — verify against pub.dev before writing `pubspec.yaml`.

---

## Gaps and Pre-Migration Decisions Required

These must be decided before Phase 2 ViewModel migration begins:

1. **Snackbar strategy:** Global `ScaffoldMessengerKey` provider vs. state-field + `ref.listen` pattern. The state-field approach is cleaner; the GlobalKey approach is simpler to retrofit. Decide before `AddProductViewModel` is migrated (first snackbar user).

2. **`go_router` route parameters:** Typed route params (via `go_router_builder`) vs. untyped `extra:` passing. Untyped is simpler for 5 routes. Decide before Phase 3.

3. **Search debounce in `ProductsNotifier`:** Keep as a `Timer` inside the notifier (valid, existing pattern) or move to a debounced `StateProvider` for the search query. Decide before `ProductsViewModel` migration (Phase 2, step 6).

4. **SyncConfig constant extraction:** Extract `maxRetries` before Phase 1. One commit, one line change, eliminates a class of bugs before migration adds complexity.

---

## Sources

Aggregated from research files (all 2026-03-26):

- Direct codebase analysis: all `.dart` files under `lib/` (HIGH confidence — primary source)
- Riverpod 2.x official docs: provider types, autoDispose, family, AsyncNotifier, ref.watch/read (HIGH confidence — stable API)
- go_router Flutter team package: declarative routing, routerConfig API (HIGH confidence)
- Drift 2.x: stream lifecycle, DAO query deduplication (HIGH confidence)
- Workmanager isolate model: `@pragma('vm:entry-point')` constraints (HIGH confidence)
- Package versions: training data cutoff August 2025 — verify all on pub.dev (MEDIUM confidence)

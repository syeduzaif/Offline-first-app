# Technology Stack: Riverpod Migration

**Project:** Offline-First Product Catalog — Stacked MVVM → Riverpod Migration
**Researched:** 2026-03-26
**Scope:** Replaces state management and DI only. Drift, Dio, Freezed, Workmanager, connectivity_plus, and all UI/utility packages are out of scope.

---

## What Gets Removed

These packages must be deleted from `pubspec.yaml` entirely. They have no role after the migration.

| Package | Current Version (locked) | Why Removed |
|---------|--------------------------|-------------|
| `stacked` | 3.5.0 | Provides `BaseViewModel`, `ReactiveViewModel`, `ListenableServiceMixin`, `ReactiveValue<T>`. All replaced by Riverpod `Notifier`/`AsyncNotifier` and provider state. |
| `stacked_services` | 1.6.0 | Provides `NavigationService`, `DialogService`, `SnackbarService`, `BottomSheetService`. Navigation handled by `go_router` (see below); dialogs/snackbars replaced by direct Flutter APIs called from the widget tree. |
| `get_it` | 8.3.0 (transitive via stacked) | The service locator. Riverpod `ProviderScope` replaces the global object graph entirely. |
| `stacked_shared` | 1.4.2 (transitive) | Pulled in by stacked. Disappears with it. |

**Dev dependencies to remove:**

| Package | Why Removed |
|---------|-------------|
| `stacked_generator` | Generates `app.locator.dart` and `app.router.dart`. Both files are deleted. |

**Generated files to delete:**
- `lib/app/app.locator.dart`
- `lib/app/app.router.dart`
- `stacked.json` (code gen config at project root)

---

## What Gets Added

### Core Riverpod Packages

| Package | Constraint | Where | Purpose |
|---------|-----------|-------|---------|
| `flutter_riverpod` | `^2.6.1` | `dependencies` | Flutter bindings: `ProviderScope`, `ConsumerWidget`, `ConsumerStatefulWidget`, `ref.watch`, `ref.read`. This is the only runtime package needed if you write providers by hand. |
| `riverpod_annotation` | `^2.3.5` | `dependencies` | Provides `@riverpod` and `@Riverpod(keepAlive: true)` annotations for code-generated providers. Required at runtime (annotations are read by the generator). |

**Confidence:** MEDIUM. Riverpod 2.x has been the stable series since 2023. The `^2.x` constraint is safe. Exact patch versions are from training data (knowledge cutoff August 2025); verify against pub.dev before `dart pub get`. The `riverpod` package (Dart-only, no Flutter) is NOT added — `flutter_riverpod` re-exports everything needed.

### Code Generation (dev dependencies)

| Package | Constraint | Where | Purpose |
|---------|-----------|-------|---------|
| `riverpod_generator` | `^2.4.3` | `dev_dependencies` | Generates `.g.dart` provider boilerplate from `@riverpod` annotations. Runs under `build_runner`. |
| `custom_lint` | `^0.6.7` | `dev_dependencies` | Required peer for `riverpod_lint`. Integrates lint results into the Dart analyzer. |
| `riverpod_lint` | `^2.3.13` | `dev_dependencies` | Enforces Riverpod best practices: warns on `ref.read` inside `build`, missing `@riverpod` annotations, provider over-reads. Optional but strongly recommended. |

`build_runner` is already present at `^2.4.15` — no version change needed. The existing `dart run build_runner build --delete-conflicting-outputs` command covers Riverpod generation alongside the existing Drift and Freezed generation.

**Confidence:** MEDIUM. `riverpod_generator` 2.x has been the stable series since Riverpod 2.0. `custom_lint` is a hard peer dependency of `riverpod_lint`.

### Router Replacement

| Package | Constraint | Where | Purpose |
|---------|-----------|-------|---------|
| `go_router` | `^14.3.0` | `dependencies` | Declarative routing to replace the Stacked-generated `StackedRouter`. Handles the 5 existing routes (Main, ProductDetail, AddProduct, EditProduct, SyncQueue). Integrates cleanly with Riverpod because route callbacks have access to `ref` via `ConsumerWidget`. |

**Why go_router over auto_route:** `go_router` is the officially recommended Flutter routing package (flutter.dev docs), maintained by the Flutter team. `auto_route` is popular but requires its own code generator and adds a second annotation system on top of Riverpod's; the complexity is not justified for 5 static routes. `stacked`'s router is discarded with the rest of `stacked`.

**Why routing must be decided now:** `stacked_services/NavigationService` is embedded in every ViewModel via `locator<NavigationService>`. It cannot be kept after `stacked_services` is removed. A routing strategy must be chosen at migration start, not deferred.

**Confidence:** HIGH. `go_router` ships as part of the Flutter ecosystem and is the canonical recommendation in the official Flutter docs.

---

## Full pubspec.yaml Delta

### Remove from `dependencies`:
```yaml
stacked: ^3.5.0
stacked_services: ^1.6.0
```

### Add to `dependencies`:
```yaml
flutter_riverpod: ^2.6.1
riverpod_annotation: ^2.3.5
go_router: ^14.3.0
```

### Remove from `dev_dependencies`:
```yaml
stacked_generator: ^2.0.0
```

### Add to `dev_dependencies`:
```yaml
riverpod_generator: ^2.4.3
custom_lint: ^0.6.7
riverpod_lint: ^2.3.13
```

### `analysis_options.yaml` addition:
```yaml
analyzer:
  plugins:
    - custom_lint
```
This activates `riverpod_lint` diagnostics in the IDE and `dart analyze`.

---

## Provider Pattern Map (Stacked → Riverpod)

This section translates every Stacked pattern used in this codebase to its Riverpod equivalent. It is the primary guide for roadmap phases.

### Pattern 1: Singleton Services via GetIt locator → `keepAlive` providers

**Current pattern:**
```dart
// main.dart
locator.registerSingleton<ConnectivityService>(connectivity);
locator.registerSingleton<SyncService>(syncService);

// ViewModel
final _connectivityService = locator<ConnectivityService>();
```

**Riverpod equivalent:**
```dart
@Riverpod(keepAlive: true)
ConnectivityService connectivityService(ConnectivityServiceRef ref) {
  final service = ConnectivityService();
  ref.onDispose(service.dispose);
  return service;
}
```
`keepAlive: true` replicates singleton semantics — the provider is never disposed. Services that require async initialization (e.g., `connectivity.initialize()`) use `AsyncNotifier` or an `asyncProvider` that `awaits` setup.

### Pattern 2: `BaseViewModel` / `AppViewModel` → `AsyncNotifier` or `Notifier`

**Current pattern:**
```dart
class AppViewModel extends BaseViewModel {
  bool get isLoading => isBusy;
  void setLoading(bool value) => setBusy(value);
}
class AddProductViewModel extends AppViewModel { ... }
```

**Riverpod equivalent:**
`AsyncNotifier<T>` replaces `BaseViewModel`. The `AsyncValue<T>` state encodes loading/error/data in a sealed type — no manual `isBusy` booleans needed:
```dart
@riverpod
class AddProductNotifier extends _$AddProductNotifier {
  @override
  FutureOr<void> build() {}   // initial state: AsyncData(null)

  Future<void> saveProduct(...) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _save(...));
  }
}
```

### Pattern 3: `ReactiveViewModel` + `ListenableServiceMixin` → `ref.watch` on providers

**Current pattern:**
```dart
class ProductsViewModel extends ReactiveViewModel {
  @override
  List<ListenableServiceMixin> get listenableServices =>
      [_connectivityService, _syncService];
  bool get isOnline => _connectivityService.isOnline;
}
```

**Riverpod equivalent:**
Services are providers. `ref.watch` wires reactivity automatically:
```dart
@riverpod
class ProductsNotifier extends _$ProductsNotifier {
  @override
  ProductsState build() {
    final isOnline = ref.watch(connectivityServiceProvider).isOnline;
    final isSyncing = ref.watch(syncServiceProvider).isSyncing;
    // ...
  }
}
```
No `ListenableServiceMixin` needed. No `notifyListeners()` calls. The `ReactiveValue<T>` class disappears.

### Pattern 4: Drift `Stream` subscriptions in ViewModels → `StreamProvider`

**Current pattern:**
```dart
StreamSubscription<List<Product>>? _productsSub;
void initialize() {
  _productsSub = _productsRepo.watchProducts().listen((p) {
    _products = p;
    notifyListeners();
  });
}
```

**Riverpod equivalent:**
```dart
@riverpod
Stream<List<Product>> productList(ProductListRef ref) {
  final repo = ref.watch(productsRepositoryProvider);
  return repo.watchProducts();
}
```
Riverpod manages the subscription lifetime automatically. The manual `StreamSubscription`, `cancel()` in `dispose()`, and `notifyListeners()` are eliminated. The widget reads `ref.watch(productListProvider)` and gets an `AsyncValue<List<Product>>`.

### Pattern 5: Navigation via `NavigationService` → `go_router` from the widget tree

**Current pattern:**
```dart
// ViewModel
final _navigationService = locator<NavigationService>();
void navigateToDetail(int id) {
  _navigationService.navigateTo(Routes.productDetailView, ...);
}
```

**Riverpod recommendation:** Navigation is a side effect that belongs in the widget tree, not in providers. The standard Riverpod pattern is:
- Pass `BuildContext` to provider methods (acceptable for one-off navigation)
- Or pass a callback from the widget (cleaner separation)
- Or expose a `GoRouter` instance as a `keepAlive` provider for use in `AsyncNotifier` where context is unavailable

The cleanest approach for this codebase (where navigation calls are all post-action, e.g., after save/delete) is `context.go(...)` called in the widget's `ref.listen` callback responding to state changes.

### Pattern 6: `SnackbarService` / `DialogService` → Flutter APIs

After removing `stacked_services`, these are replaced by:
- `ScaffoldMessenger.of(context).showSnackBar(...)` called from the widget's `ref.listen`
- `showDialog(context: context, ...)` called directly from the widget
- Both triggered by observing a state change in the notifier (e.g., an `error` field or an `event` sealed class)

No third-party package is needed for dialogs or snackbars.

---

## Code Generation Setup

After migration, `build_runner` generates output for four systems in one command:

| System | Input annotations | Output files |
|--------|------------------|--------------|
| `drift_dev` | `@DriftDatabase`, `@DriftAccessor` | `*.g.dart` for DAOs and database |
| `freezed` | `@freezed` | `*.freezed.dart` for models and DTOs |
| `json_serializable` | `@JsonSerializable` | `*.g.dart` for JSON converters |
| `riverpod_generator` | `@riverpod` | `*.g.dart` for provider boilerplate |

Command (unchanged):
```bash
dart run build_runner build --delete-conflicting-outputs
```

All four generators coexist under `build_runner`. There are no known conflicts between `riverpod_generator` and `drift_dev`/`freezed` as of August 2025. The `--delete-conflicting-outputs` flag handles stale `.g.dart` files during incremental migration.

**`build.yaml` note:** No custom `build.yaml` configuration is required for `riverpod_generator`. It auto-discovers annotated files under `lib/`.

---

## Packages NOT Recommended (and Why)

| Package | Why Not |
|---------|---------|
| `hooks_riverpod` | Adds `flutter_hooks` dependency and a different widget base class (`HookConsumerWidget`). Powerful but requires learning hooks in addition to Riverpod. The existing codebase has no hooks; introducing them mid-migration adds surface area without benefit. Use plain `flutter_riverpod`. |
| `injectable` + `get_it` | This is what is being replaced. Do not re-introduce as a "helper" alongside Riverpod. Two DI systems is the current problem. |
| `riverpod_generator` without `riverpod_annotation` | `riverpod_annotation` is a required runtime peer for `riverpod_generator`. Both must be present. |
| `provider` | The legacy package that Riverpod supersedes. Not compatible as a complement. |
| `auto_route` | Adds a second code generator and annotation system. `go_router` covers all 5 routes without generation. |
| `get` (GetX) | Entirely separate ecosystem; incompatible goals. |

---

## Alternatives Considered

| Category | Recommended | Alternative | Why Not Chosen |
|----------|-------------|-------------|----------------|
| State management | `flutter_riverpod` 2.x | BLoC (`flutter_bloc`) | BLoC has more boilerplate (Events, States, Blocs); Riverpod's composable providers are a better fit for the data-layer pattern already in use (Drift streams + repository pattern). Decision is locked in PROJECT.md. |
| Routing | `go_router` | `auto_route` | `auto_route` requires its own `@AutoRoute` generator; adding a second code generation system alongside `riverpod_generator` increases build complexity. `go_router` is sufficient and officially maintained. |
| Routing | `go_router` | Keep Stacked router | Impossible: Stacked router depends on `stacked_services` which is being removed. |
| Code-gen providers | `@riverpod` annotation | Hand-written providers | Hand-written providers are valid but verbose. The annotation approach is the current Riverpod team recommendation for all new code and is better supported by `riverpod_lint`. |

---

## Confidence Assessment

| Area | Confidence | Basis |
|------|-----------|-------|
| Riverpod 2.x is the correct series | HIGH | Stable since 2023, no 3.x GA release as of August 2025 knowledge cutoff |
| `flutter_riverpod` + `riverpod_annotation` + `riverpod_generator` is the canonical triad | HIGH | Official Riverpod documentation pattern; consistent across pub.dev READMEs and flutter.dev examples |
| Exact package versions (`^2.6.1`, `^2.4.3`, etc.) | MEDIUM | From training data; knowledge cutoff August 2025. Verify against pub.dev before running `dart pub get` |
| `go_router ^14.x` | MEDIUM | go_router 13.x was stable in early 2025; 14.x is a plausible current minor; verify on pub.dev |
| `custom_lint` required for `riverpod_lint` | HIGH | Documented peer dependency in both packages' READMEs |
| `keepAlive: true` for singletons | HIGH | Core Riverpod API; documented and stable |
| No `hooks_riverpod` needed | HIGH | This codebase has no hooks; `flutter_riverpod` is sufficient |

---

## Version Verification Checklist

Before writing `pubspec.yaml` in Phase 1, verify the following on pub.dev:

- [ ] `flutter_riverpod` — latest stable version
- [ ] `riverpod_annotation` — must match `flutter_riverpod` major version
- [ ] `riverpod_generator` — must match `flutter_riverpod` major version (all three are released together)
- [ ] `riverpod_lint` — check peer constraint against installed `flutter_riverpod` version
- [ ] `custom_lint` — check peer constraint against installed `riverpod_lint` version
- [ ] `go_router` — latest stable; check for any breaking changes to `GoRoute` or `ShellRoute` API

All three Riverpod packages (`flutter_riverpod`, `riverpod_annotation`, `riverpod_generator`) are versioned together and must use the same major version. Mismatching them causes build errors.

---

## Sources

- Riverpod official docs pattern (training data, HIGH confidence): https://riverpod.dev/docs/introduction/getting_started
- `riverpod_generator` README pattern (training data, HIGH confidence): https://pub.dev/packages/riverpod_generator
- `go_router` Flutter team package (training data, HIGH confidence): https://pub.dev/packages/go_router
- Existing codebase: `pubspec.lock` (get_it 8.3.0 confirmed as transitive stacked dependency)
- Existing codebase: `lib/main.dart`, `lib/app/app.dart`, all `*_viewmodel.dart` files (patterns inventoried directly)

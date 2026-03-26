# Feature Landscape: Stacked → Riverpod Migration

**Domain:** Architecture migration — Stacked MVVM + GetIt/Injectable → Riverpod
**Researched:** 2026-03-26
**Confidence note:** Web search and WebFetch were unavailable during this research session.
All Riverpod equivalents are drawn from direct codebase analysis plus training-data
knowledge of Riverpod 2.x (stable as of August 2025 training cutoff). Confidence levels
are assigned conservatively. Verify package versions against pub.dev before implementation.

---

## What This Migration Covers

Every Stacked/GetIt construct currently used in this codebase maps to a Riverpod
equivalent. The migration has no new features — it is a 1:1 replacement of the
presentation and DI layer while the domain/data/repository layers stay unchanged.

The inventory of Stacked constructs actually in use (from reading all source files):

| Stacked Construct | Files Using It | Complexity to Replace |
|---|---|---|
| `ReactiveViewModel` (via `listenableServices`) | `ProductsViewModel`, `MainViewModel`, `SyncQueueViewModel` | Medium |
| `BaseViewModel` (via `AppViewModel`) | `AddProductViewModel`, `EditProductViewModel`, `ProductDetailViewModel` | Low |
| `StackedView<VM>` + `viewModelBuilder` | All 5 view files | Low |
| `onViewModelReady` lifecycle hook | All 5 view files | Low |
| `locator<T>()` (GetIt resolution) | All 5 viewmodels + `main.dart` | Medium |
| `NavigationService` (from `stacked_services`) | `ProductsViewModel`, `AddProductViewModel`, `EditProductViewModel`, `ProductDetailViewModel` | Medium |
| `SnackbarService` (from `stacked_services`) | `AddProductViewModel`, `EditProductViewModel`, `ProductDetailViewModel` | Medium |
| `DialogService` (from `stacked_services`) | `ProductDetailViewModel` only | Low |
| `ListenableServiceMixin` on services | `ConnectivityService`, `SyncService` | Medium |
| `ReactiveValue<T>` inside services | `ConnectivityService._isOnline`, `SyncService._isSyncing` | Low |
| `@StackedApp` code-gen (routes + locator) | `app/app.dart` | Medium |
| `StackedService.navigatorKey` | `main.dart` | Low |
| `StackedRouter().onGenerateRoute` | `main.dart` | Low |
| `isBusy` / `setBusy` / `modelError` / `setError` | `AppViewModel` wrapper, used in all form VMs | Low |

**Note:** `BottomSheetService` is registered in `app.dart` but is never called anywhere in
the codebase. It is dead code and should be dropped entirely.

---

## Table Stakes

Features that must be migrated or the app does not function.

### 1. ViewModel State → `AsyncNotifier` / `Notifier`

**What it replaces:** `BaseViewModel` + `AppViewModel` (`isBusy`, `modelError`,
`notifyListeners()`)

**Riverpod equivalent:**
- `Notifier<State>` — synchronous state with `state = newState` replacing `notifyListeners()`
- `AsyncNotifier<State>` — async state that gives `AsyncValue<T>` (loading/data/error)
  built in, replacing manual `isBusy`/`modelError` tracking

**Mapping for each ViewModel:**

| Current VM | Extends | Riverpod replacement |
|---|---|---|
| `AppViewModel` | `BaseViewModel` | Delete — absorbed into each Notifier's `AsyncValue` |
| `ProductsViewModel` | `ReactiveViewModel` | `Notifier<ProductsState>` (streams watched inside) |
| `MainViewModel` | `ReactiveViewModel` | `Notifier<MainState>` |
| `SyncQueueViewModel` | `ReactiveViewModel` | `Notifier<SyncQueueState>` |
| `AddProductViewModel` | `AppViewModel` | `AsyncNotifier<void>` or `Notifier<AddProductState>` |
| `EditProductViewModel` | `AppViewModel` | `AsyncNotifier<void>` or `Notifier<EditProductState>` |
| `ProductDetailViewModel` | `AppViewModel` | `AsyncNotifier<Product?>` |

**Complexity:** Low per ViewModel. The main work is defining a `State` value class (can
use `@freezed`) and replacing `notifyListeners()` with `state = state.copyWith(...)`.

**Confidence:** HIGH — core Riverpod 2.x concept, stable since 2.0.

---

### 2. Reactive Service Listening → Provider `ref.watch` / `ref.listen`

**What it replaces:** `ReactiveViewModel.listenableServices` + `ListenableServiceMixin`
on `ConnectivityService` and `SyncService`

Three ViewModels currently declare:
```dart
List<ListenableServiceMixin> get listenableServices => [_connectivityService, _syncService];
```

This causes the ViewModel to rebuild whenever either service calls `notifyListeners()`.

**Riverpod equivalent:**
- `ConnectivityService` and `SyncService` become providers (see Section 5 below)
- Inside the Notifier, use `ref.watch(connectivityServiceProvider.select((s) => s.isOnline))`
  and `ref.watch(syncServiceProvider.select((s) => s.isSyncing))` to get reactive reads
- The `ListenableServiceMixin` and `ReactiveValue<T>` wrapper are removed entirely

**Why better:** Riverpod's `select` avoids rebuilding the entire ViewModel when unrelated
state in the service changes. `listenableServices` rebuilds on any `notifyListeners()` call.

**Complexity:** Low-Medium. Removing `ListenableServiceMixin` from the two services
requires stripping Stacked imports from `ConnectivityService` and `SyncService`.

**Confidence:** HIGH — standard Riverpod pattern.

---

### 3. Drift Stream Subscriptions → `StreamProvider` or `ref.listen` inside Notifier

**What it replaces:** Manual `StreamSubscription` fields + `_productsSub?.cancel()` in
`dispose()` across every ViewModel

Every ViewModel manually manages subscriptions:
```dart
StreamSubscription<List<Product>>? _productsSub;
// ... in initialize():
_productsSub = _productsRepo.watchProducts().listen(_onProductsChanged);
// ... in dispose():
_productsSub?.cancel();
```

**Riverpod equivalents (two patterns, pick based on need):**

Option A — `StreamProvider` (read-only streams, no side effects):
```dart
final productsStreamProvider = StreamProvider<List<Product>>((ref) {
  return ref.watch(productsRepositoryProvider).watchProducts();
});
```
The provider handles subscription lifecycle automatically. View calls `ref.watch(productsStreamProvider)` and gets `AsyncValue<List<Product>>`.

Option B — `ref.listen` inside a `Notifier` (streams that trigger side effects):
```dart
@override
ProductsState build() {
  ref.listen(categoriesStreamProvider, (_, cats) {
    state = state.copyWith(categories: cats.value ?? []);
  });
  return ProductsState.initial();
}
```

**Recommendation:** Use `StreamProvider` for pure data streams (products list, categories
list, sync queue list, pending count) and `ref.listen` only when a stream emission triggers
a side effect (e.g., sync on connectivity change).

**Complexity:** Low for simple streams. Medium for `ProductsViewModel`'s dynamic stream
subscription (search/category switching currently re-subscribes to a different stream).
The filtered stream requires either (a) a family provider
`productsStreamProvider(filter)` or (b) keeping filter state in the Notifier and computing
which stream to expose.

**Confidence:** HIGH — `StreamProvider` is core Riverpod API.

---

### 4. DI / Service Location → `Provider` singletons in Riverpod

**What it replaces:** `locator<T>()` (GetIt), `setupLocator()`, `app.locator.dart`,
`stacked_generator`, `injectable`

Every ViewModel resolves dependencies at field initialization:
```dart
final _productsRepo = locator<ProductsRepository>();
```

And `main.dart` manually registers 9 singletons into GetIt after `setupLocator()`.

**Riverpod equivalent:**

Each dependency becomes a top-level `Provider`:
```dart
final appDatabaseProvider = Provider<AppDatabase>((ref) => AppDatabase());
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());
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
```

Notifiers receive these via `ref.watch` / `ref.read`:
```dart
class ProductsNotifier extends Notifier<ProductsState> {
  late final IProductsRepository _repo;

  @override
  ProductsState build() {
    _repo = ref.watch(productsRepositoryProvider);
    return ProductsState.initial();
  }
}
```

**Complexity:** Medium. The main effort is creating the provider graph in the right
dependency order (same order as current `main.dart` registration). The async initialization
of `ConnectivityService` requires a `FutureProvider` or an `AsyncNotifier`-based service
provider. `AppDatabase` construction is synchronous but needs `WidgetsFlutterBinding`
initialized first — wrap in `ProviderScope(overrides: [...])` at app startup.

**Confidence:** HIGH — this is the canonical Riverpod DI pattern.

---

### 5. ConnectivityService + SyncService → `Notifier`-based service providers

**What they replace:** `ConnectivityService with ListenableServiceMixin`,
`SyncService with ListenableServiceMixin`, `ReactiveValue<bool>`

Both services are currently infrastructure singletons that hold reactive state and notify
ViewModels via `ListenableServiceMixin`.

**Riverpod equivalent:**

`ConnectivityService` becomes a `StreamProvider<bool>` backed by `connectivity_plus`:
```dart
final connectivityProvider = StreamProvider<bool>((ref) {
  return Connectivity()
      .onConnectivityChanged
      .map((results) => results.any((r) => r != ConnectivityResult.none));
});
```

`SyncService` becomes an `AsyncNotifier` that exposes `isSyncing` state:
```dart
@riverpod
class SyncService extends _$SyncService {
  @override
  bool build() {
    // Start listening for connectivity changes
    ref.listen(connectivityProvider, (_, next) {
      if (next.value == true) syncAll();
    });
    return false; // isSyncing
  }
  Future<void> syncAll() async { ... }
}
```

**Complexity:** Medium. The services themselves need minimal logic changes — they lose the
Stacked mixin and gain Riverpod's `state`/`ref` instead. The Workmanager isolate
(`callbackDispatcher`) constructs these services manually and independently (no Riverpod
container in that isolate) — this pattern stays unchanged.

**Confidence:** HIGH for the pattern. MEDIUM for exact `StreamProvider` wrapping of
`connectivity_plus` — verify `onConnectivityChanged` stream API hasn't changed.

---

### 6. Navigation → Flutter Navigator 2.0 or `go_router`

**What it replaces:** `NavigationService`, `StackedService.navigatorKey`,
`StackedRouter().onGenerateRoute`, `Routes.productDetailView`, `app.router.dart`

Current usage in ViewModels:
```dart
_navigationService.navigateTo(Routes.productDetailView, arguments: ProductDetailViewArguments(productId: id));
_navigationService.navigateTo(Routes.addProductView);
_navigationService.navigateTo(Routes.editProductView, arguments: EditProductViewArguments(product: _product!));
_navigationService.back();
```

**Riverpod equivalent options:**

**Option A: `go_router` (recommended)**
- Define routes in a top-level `GoRouter` instance exposed as a `Provider`
- Views become `GoRoute` entries with typed params (can use `go_router_builder` for type safety)
- Navigation calls from Notifiers: pass `BuildContext` down from the view, or expose a
  `NavigationNotifier` that the view listens to with `ref.listen`
- `MaterialApp.router` replaces `MaterialApp` + `navigatorKey`

**Option B: Named routes with `Navigator.of(context).pushNamed`**
- Lower migration effort — just pass `context` to the Notifier call or trigger navigation
  from the View directly
- Works with `MaterialApp(onGenerateRoute: ...)` — no new dependency required

**Recommendation:** `go_router` for this app. It is the Flutter-team endorsed solution,
handles typed parameters cleanly (replacing `ProductDetailViewArguments`), and eliminates
the need for a `navigatorKey` singleton. If minimizing migration scope matters, start with
named routes and migrate to `go_router` post-migration.

**Complexity:** Medium. The most delicate part is navigation from inside a Notifier
without a `BuildContext`. The standard pattern: Notifier exposes a navigation intent
as state, View calls `ref.listen` and executes the navigation when the intent fires.
Alternatively, pass `context` as a parameter to the Notifier method — acceptable for
imperative navigation.

**Confidence:** MEDIUM — `go_router` is the dominant community choice as of training
cutoff; verify current version (was at ~14.x) and API stability before committing.

---

### 7. SnackbarService → ScaffoldMessenger + `ref.listen`

**What it replaces:** `_snackbarService.showSnackbar(message: ...)` in three ViewModels

Used in `AddProductViewModel`, `EditProductViewModel`, `ProductDetailViewModel` for:
- Validation error feedback
- Save success confirmation
- Delete success confirmation

**Riverpod equivalent:**

Pattern: Notifier exposes a `String? snackbarMessage` field in its state. View uses
`ref.listen` to react when the message changes and calls `ScaffoldMessenger`:
```dart
// In View:
ref.listen(addProductProvider.select((s) => s.snackbarMessage), (_, message) {
  if (message != null) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    ref.read(addProductProvider.notifier).clearSnackbar();
  }
});
```

Alternatively, expose a `Stream<String>` from the Notifier that the View listens to.

**Complexity:** Low. This is a straightforward pattern. The state class needs a nullable
`snackbarMessage` field and a `clearSnackbar()` method on the Notifier.

**Confidence:** HIGH — this is the canonical Riverpod way to trigger one-shot UI effects.

---

### 8. DialogService → `showDialog` with `await` from View

**What it replaces:** `_dialogService.showConfirmationDialog(...)` in `ProductDetailViewModel`

Currently:
```dart
final result = await _dialogService.showConfirmationDialog(
  title: ProductStrings.deleteProduct,
  description: ProductStrings.confirmDelete,
  confirmationTitle: CommonStrings.actionDelete,
  cancelTitle: CommonStrings.actionCancel,
);
if (result?.confirmed != true) return;
await _productsRepo.deleteProduct(_product!.id);
```

The ViewModel owns the dialog flow including the `await` on the user's confirmation.

**Riverpod equivalent:**

Dialogs require a `BuildContext` and should be triggered from the View layer. The standard
Riverpod pattern:
1. View exposes a "delete" button with `onPressed`
2. `onPressed` calls `showDialog(context, ...)` and `await`s the result
3. If confirmed, view calls `ref.read(productDetailProvider.notifier).deleteProduct()`

This is architecturally cleaner — dialogs are UI concerns and belong in the View, not the
Notifier. The ViewModel should not hold a `DialogService` reference.

**Complexity:** Low. One dialog call → moves from ViewModel to View. The Notifier's
`deleteProduct()` becomes a simple async method that assumes confirmation has already occurred.

**Confidence:** HIGH — universally recommended pattern in Riverpod community.

---

### 9. `onViewModelReady` lifecycle → Notifier `build()` method

**What it replaces:** `onViewModelReady(VM viewModel) { viewModel.initialize(); }` pattern
in all 5 views

Stacked's `onViewModelReady` fires once after the ViewModel is created and mounted.
It is used as the init hook for subscriptions and initial data fetches.

**Riverpod equivalent:**

Everything that `initialize()` does belongs in the Notifier's `build()` method:
```dart
@override
ProductsState build() {
  // Subscribe to Drift stream
  final sub = ref.watch(productsStreamProvider);
  // Run initial fetch (fire-and-forget)
  Future.microtask(() => _initialFetch());
  return ProductsState.initial();
}
```

Riverpod automatically calls `build()` when the provider is first read and cancels/restarts
it on dependency changes. There is no manual `initialize()` call needed.

**Complexity:** Low. Requires collapsing `initialize()` into `build()` for each Notifier.
The `Future.microtask` idiom avoids calling async work directly from `build()`.

**Confidence:** HIGH — standard Riverpod lifecycle.

---

### 10. Code-Generated Files Removal

**What to delete:**
- `lib/app/app.dart` (`@StackedApp` annotation source)
- `lib/app/app.locator.dart` (generated GetIt locator)
- `lib/app/app.router.dart` (generated Stacked router)
- `stacked.json` (Stacked CLI config, if present)

**What to remove from `pubspec.yaml`:**
```yaml
# Remove from dependencies:
stacked: ^3.5.0
stacked_services: ^1.6.0

# Remove from dev_dependencies:
stacked_generator: ^2.0.0
```

**Complexity:** Low once all usages are replaced. Do this last as a cleanup step.

**Confidence:** HIGH.

---

## Simplifications

Things Riverpod handles better than the current Stacked approach — net reduction in
code or complexity.

### S1. No `AppViewModel` base class needed

`AppViewModel extends BaseViewModel` is a thin wrapper around Stacked's `isBusy`,
`modelError`, `setBusy`, `setError`, `clearErrors`. In Riverpod, `AsyncNotifier` gives
`AsyncValue<T>` with `loading`, `data`, and `error` states built in — no wrapper needed.

**Net reduction:** Delete `lib/core/viewmodels/app_viewmodel.dart` entirely. Each
`AsyncNotifier`'s `build()` returns `Future<State>`, and Riverpod's code generator
(or manual pattern) provides the `AsyncValue` wrapper automatically.

**Confidence:** HIGH.

---

### S2. No `dispose()` boilerplate for stream subscriptions

Every ViewModel currently has a `dispose()` that cancels multiple `StreamSubscription`
fields. Riverpod providers automatically cancel their subscriptions when the provider
is disposed (when the widget tree no longer reads it).

`ref.onDispose` is available if explicit teardown is needed, but manual `cancel()` calls
for streams created via `StreamProvider` or `ref.listen` are unnecessary.

**Net reduction:** Remove ~30 lines of `StreamSubscription?` field declarations and
`dispose()` override bodies across all ViewModels.

**Confidence:** HIGH.

---

### S3. No `setupLocator()` / `main.dart` registration block

The current `main.dart` has a 50-line manual DI setup block registering 9 singletons.
Riverpod replaces this with lazy provider evaluation — dependencies are constructed on
first access, in dependency order, without any registration step.

The `ProviderScope` wrapper at the app root replaces `setupLocator()`. Overrides can be
passed for testing without a test-only DI container.

**Net reduction:** Remove `setupLocator()` call and all 9 `locator.registerSingleton`
blocks. `ProviderScope` requires 3 lines of code.

**Confidence:** HIGH.

---

### S4. `ReactiveValue<T>` eliminated

`ConnectivityService` and `SyncService` each wrap a boolean in `ReactiveValue<bool>`
because Stacked requires a specific wrapper to trigger `notifyListeners()` on assignment.

In Riverpod, state is plain Dart — `bool isSyncing` exposed via `state` on a `Notifier`.
`ReactiveValue` is a Stacked-specific type with no Riverpod equivalent needed.

**Net reduction:** Remove `ReactiveValue<bool> _isOnline` and `ReactiveValue<bool> _isSyncing`.
Replace with plain `bool` on the Notifier state.

**Confidence:** HIGH.

---

### S5. `StackedView` boilerplate eliminated

Each view currently has three overrides:
```dart
Widget builder(context, viewModel, child)     // required
ProductsViewModel viewModelBuilder(context)    // required
void onViewModelReady(viewModel)               // optional but present in all 5
```

In Riverpod, views are plain `ConsumerWidget` (or `ConsumerStatefulWidget`) — they read
state via `ref.watch(...)`. No base class required.

**Net reduction:** Each view drops its `StackedView<VM>` supertype, `viewModelBuilder`,
and `onViewModelReady` boilerplate. The `builder` method becomes `build(context, ref)`.

**Confidence:** HIGH.

---

### S6. `BottomSheetService` can be deleted

`BottomSheetService` is registered in `app.dart` as a `LazySingleton` but is never called
anywhere in the codebase. It is dead code. Do not port it.

**Net reduction:** Zero code to write; one dependency to not create.

**Confidence:** HIGH (verified by grepping all view and viewmodel files — no `showSheet`
or `BottomSheetService` references outside the locator registration).

---

## Anti-Features

Stacked patterns that should NOT be ported 1:1 to Riverpod.

### A1. Do NOT recreate a `NavigatorService` singleton

**The anti-pattern:** Creating a `NavigationProvider` that wraps a `GlobalKey<NavigatorState>`
and is injected into Notifiers, replicating Stacked's `NavigationService` design.

**Why it's wrong:** A `GlobalKey<NavigatorState>` held in a provider is a global mutable
object that leaks across provider lifecycle. It also makes Notifiers dependent on a UI
concern (navigation state), breaking testability.

**What to do instead:** Navigation calls belong in the View. The Notifier exposes a
navigation intent (e.g., `navigateTo: Routes?` field on state). The View uses `ref.listen`
to observe that field and calls `Navigator.of(context).pushNamed(...)` or
`context.go(...)` when it fires. The Notifier then clears the intent.

**Confidence:** HIGH — this anti-pattern is explicitly called out in Riverpod documentation
and community guides.

---

### A2. Do NOT recreate a `SnackbarService` singleton

**The anti-pattern:** Creating a `SnackbarProvider` that captures `ScaffoldMessengerState`
via a `GlobalKey` and is injected into Notifiers.

**Why it's wrong:** Same reasons as `NavigationService`. The `ScaffoldMessenger` is tied
to a specific widget tree position and should be accessed from the View layer.

**What to do instead:** Notifier state carries a `String? snackbarMessage`. View reacts
via `ref.listen` and calls `ScaffoldMessenger.of(context).showSnackBar(...)`.

**Confidence:** HIGH.

---

### A3. Do NOT recreate a `DialogService` singleton

**The anti-pattern:** `DialogService` in Stacked uses a `GlobalKey<NavigatorState>` to
show dialogs from the ViewModel layer. Porting this means creating a provider that holds
the same key.

**Why it's wrong:** Dialogs are fundamentally a View concern. Showing them from a Notifier
couples business logic to UI mechanics.

**What to do instead:** Move the `showDialog` call to the View's `onPressed` handler.
The Notifier's `deleteProduct()` method should not `await` a dialog — it should accept
a boolean parameter `confirmed: true` passed by the View after the dialog resolves.

**Confidence:** HIGH.

---

### A4. Do NOT port `ListenableServiceMixin` + `listenableServices` as-is

**The anti-pattern:** Creating a `RiverpodListenableMixin` that mimics `notifyListeners()`
and having Notifiers declare a list of "listenable services."

**Why it's wrong:** Riverpod's provider graph already handles reactive propagation. Adding
a separate notification layer creates two competing reactive systems and obscures
dependency flow.

**What to do instead:** Services become providers. Notifiers watch service providers
directly via `ref.watch`. When service state changes (connectivity, sync status), the
provider graph propagates the change automatically.

**Confidence:** HIGH.

---

### A5. Do NOT port `AppViewModel` as a Riverpod base class

**The anti-pattern:** Creating `AppNotifier extends Notifier<AppState>` that all feature
Notifiers extend, with `setLoading`, `setErrorMessage`, `clearErrorMessage` helpers.

**Why it's wrong:** `AsyncNotifier` already provides this abstraction via `AsyncValue`.
Creating a parallel loading/error system adds boilerplate and fights the framework.

**What to do instead:** Use `AsyncNotifier<State>` for operations that can fail or be
in-progress. The `state` is `AsyncValue<State>` which has `loading`, `data`, and `error`
constructors. No base class needed.

**Confidence:** HIGH.

---

### A6. Do NOT keep `stacked_generator` as a dev dependency "just in case"

**The anti-pattern:** Keeping Stacked code-gen running alongside Riverpod during migration,
running both generators simultaneously.

**Why it's wrong:** The generated files (`app.locator.dart`, `app.router.dart`) import
from `stacked`/`stacked_services`. As long as those imports exist, the packages cannot
be removed. A partial migration state creates confusion about which DI system is active.

**What to do instead:** Migrate all ViewModels and remove all `locator<T>()` calls before
removing any packages. Delete the generated files in a single committed step. The migration
must be atomic per file: a View+ViewModel pair migrates together.

**Confidence:** HIGH.

---

## Feature Dependencies

Migration sequence constraints:

```
Provider graph (infrastructure) → must exist before any Notifier can be written
  AppDatabase provider
  ApiClient provider
  ProductsRepository provider
  CategoriesRepository provider
  ConnectivityService provider
  SyncService provider (depends on ConnectivityService provider)

ConnectivityService provider → SyncService provider (SyncService watches connectivity)
SyncService provider → MainNotifier, ProductsNotifier, SyncQueueNotifier (all watch isSyncing)

SnackbarService → must be replaced BEFORE removing stacked_services dependency
NavigationService → must be replaced BEFORE removing stacked_services dependency
DialogService → must be replaced BEFORE removing stacked_services dependency

All locator<T>() calls removed → then app.locator.dart can be deleted
All Routes.* references removed → then app.router.dart can be deleted
Both deleted → then stacked + stacked_services can be removed from pubspec
```

---

## MVP Recommendation

For the migration milestone, the required surface area is exactly the 14 constructs
listed in the inventory table — no more, no less.

**Recommended migration order per phase:**

1. **Provider graph first** — Create all `Provider<T>` declarations for repositories and
   services. No views change yet. Verify DI compiles. (Replaces: `setupLocator()` +
   `locator.registerSingleton()` blocks in `main.dart`.)

2. **Services next** — Strip `ListenableServiceMixin` from `ConnectivityService` and
   `SyncService`. Replace `ReactiveValue<T>` with Riverpod state. (Replaces: items 2, 4
   from the inventory.)

3. **Simple ViewModels** — `MainViewModel` and `SyncQueueViewModel` are the simplest:
   one or two streams, no navigation except tab switching, no dialogs. Migrate these first
   to validate the pattern.

4. **Form ViewModels** — `AddProductViewModel` and `EditProductViewModel` are near-
   identical. Migrate both together. Introduce the snackbar-as-state pattern here.

5. **Complex ViewModels** — `ProductsViewModel` (dynamic stream switching, pagination,
   scroll controller) and `ProductDetailViewModel` (dialog ownership move). Migrate last.

6. **Routing** — Replace `StackedRouter` + `Routes.*` with `go_router` or named routes.

7. **Cleanup** — Delete generated files. Remove packages from pubspec.

**Defer:** `go_router` typed routes and route-level code generation are valuable but not
required for the migration. Named routes work and can be upgraded separately.

---

## Sources

- Direct codebase analysis of all `.dart` files in `lib/` (2026-03-26)
- Riverpod 2.x documentation (training data, cutoff August 2025; web access unavailable)
- `pubspec.yaml` dependency versions verified from source file
- Stacked 3.5.x / stacked_services 1.6.x behaviour verified from source file patterns
- Note: verify `flutter_riverpod` current version on pub.dev before implementation
  (was at 2.5.x as of training cutoff; riverpod_generator was at 2.4.x)

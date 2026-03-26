# Roadmap: Stacked MVVM → Riverpod Migration

**Milestone:** Riverpod Migration
**Initialized:** 2026-03-26
**Granularity:** standard
**Coverage:** 30/30 v1 requirements mapped

---

## Phases

- [ ] **Phase 1: DI Foundation** — Riverpod provider graph established; both DI systems coexist safely via bridge providers
- [ ] **Phase 2: ViewModel Migration** — All six ViewModels replaced with Riverpod Notifiers; no Stacked types remain in view files
- [ ] **Phase 3: Routing Migration** — `go_router` is the sole navigation system; all `stacked_services` call sites removed
- [ ] **Phase 4: Package Removal** — Zero Stacked/GetIt code or imports remain; build output is clean
- [ ] **Phase 5: Cleanup and Test Baseline** — Known bugs fixed; first meaningful provider unit tests written; lint is clean

---

## Phase Details

### Phase 1: DI Foundation
**Goal**: The Riverpod provider graph exists and covers all infrastructure, services, and repositories. Both DI systems coexist safely via bridge providers — no service is instantiated twice.
**Depends on**: Nothing (first phase)
**Requirements**: DI-01, DI-02, DI-03, DI-04, DI-05, DI-06, DI-07
**Complexity**: Medium — requires stripping `ListenableServiceMixin` and `ReactiveValue<bool>` from services before any ViewModel is touched; bridge provider pattern must be applied precisely to prevent dual-instance bugs.
**Success Criteria** (what must be TRUE):
  1. The app runs with `ProviderScope` wrapping `MyApp`; `setupLocator()` still executes alongside it (both systems coexist, no crash)
  2. A temporary `Consumer` widget can read `productsStreamProvider` and render the same product list that the existing ViewModel renders — proving the Riverpod data path is live
  3. `ConnectivityService` and `SyncService` no longer use `ListenableServiceMixin`; the `isSyncing` and connectivity signals are observable via Riverpod providers, and all three screens that depend on them (`ProductsView`, `MainView`, `SyncQueueView`) still display correct sync status
  4. All repository providers (`productsRepositoryProvider`, `categoriesRepositoryProvider`) and infrastructure providers (`appDatabaseProvider`, `apiClientProvider`) are resolvable from `ProviderScope` without error
  5. `build_runner` produces a clean output (zero errors) with Drift + Freezed + Riverpod generators coexisting
**Plans**: 3 plans
Plans:
- [ ] 01-01-PLAN.md — Packages + ProviderScope bootstrap + maxRetries constant (DI-01)
- [ ] 01-02-PLAN.md — Strip ListenableServiceMixin from services; add Tier 1+2 bridge providers (DI-02, DI-03, DI-04, DI-05, DI-07)
- [ ] 01-03-PLAN.md — Repository + Tier 4 stream providers; Consumer smoke test (DI-06)
**Canonical refs**:
  - `lib/main.dart` — bootstrap order, `setupLocator()` call
  - `lib/app/app.locator.dart` — GetIt registrations being bridged
  - `lib/services/connectivity_service.dart` — `ListenableServiceMixin` removal target
  - `lib/services/sync_service.dart` — `ReactiveValue<bool>` removal target; `isSyncing` signal
  - `lib/data/local/database.dart` — `AppDatabase`; `appDatabaseProvider` lives here
  - `lib/data/remote/api_client.dart` — Dio client; `apiClientProvider` lives here
  - `lib/data/repositories/products_repository.dart` — `productsRepositoryProvider`
  - `lib/data/repositories/categories_repository.dart` — `categoriesRepositoryProvider`
  - `.planning/research/SUMMARY.md` — provider tier diagram (Tier 1–5), bridge provider pattern, Phase 1 pitfall list

---

### Phase 2: ViewModel Migration
**Goal**: All six ViewModels are replaced with Riverpod `Notifier`/`AsyncNotifier` classes. Every view is a `ConsumerWidget` or `ConsumerStatefulWidget`. No `StackedView`, `ReactiveViewModel`, `BaseViewModel`, or `locator<T>()` call exists in any view file.
**Depends on**: Phase 1
**Requirements**: VM-01, VM-02, VM-03, VM-04, VM-05, VM-06, VM-07, VM-08
**Complexity**: High — six ViewModels across six screens; `ProductsViewModel` carries search debounce, pagination, and category filtering; `ProductDetailViewModel` has a known hang bug to fix; form views require `TextEditingController` moved to `ConsumerStatefulWidget.State`.
**Success Criteria** (what must be TRUE):
  1. All six screens (`MainView`, `SyncQueueView`, `AddProductView`, `EditProductView`, `ProductDetailView`, `ProductsView`) render correctly and respond to user interaction identically to the pre-migration behavior
  2. Navigating to a product detail screen for a product that has since been deleted shows an error or not-found state rather than hanging indefinitely on a loading spinner
  3. The add-product and edit-product forms display a snackbar message on success or failure without using `SnackbarService` — message appears via `ref.listen` on a state field
  4. `AppViewModel` base class file no longer exists; no view file contains `isBusy` or `modelError` patterns — all loading and error states are expressed as `AsyncValue<T>`
  5. All six `_viewmodel.dart` files under `lib/ui/views/` are deleted; no `StreamSubscription` manual `dispose()` calls remain in view files
**Plans**: TBD
**Canonical refs**:
  - `lib/ui/views/main/` — `MainViewModel` → `MainNotifier`; IndexedStack autoDispose concern
  - `lib/ui/views/sync_queue/` — `SyncQueueViewModel` → `SyncQueueNotifier`; simplest migration first
  - `lib/ui/views/add_product/` — `AddProductViewModel` → `AddProductNotifier`; first snackbar-as-state user
  - `lib/ui/views/edit_product/` — `EditProductViewModel` → `EditProductNotifier`
  - `lib/ui/views/product_detail/` — `ProductDetailViewModel` → `ProductDetailNotifier`; null-hang bug fix (VM-04, TEST-03)
  - `lib/ui/views/products/` — `ProductsViewModel` → `ProductsNotifier`; most complex: debounce, pagination, filter
  - `lib/core/viewmodels/app_viewmodel.dart` — deletion target (VM-07)
  - `.planning/research/SUMMARY.md` — migration order (leaf to root), pitfall list (Pitfalls 3, 5, 7, 8, 12, 14)

---

### Phase 3: Routing Migration
**Goal**: `go_router` is the sole navigation system. All five named routes are declared in a `GoRouter` provider. `MaterialApp.router` replaces `MaterialApp`. No `NavigationService`, `SnackbarService`, or `DialogService` call sites remain anywhere in the codebase.
**Depends on**: Phase 2
**Requirements**: ROUTE-01, ROUTE-02, ROUTE-03, ROUTE-04, ROUTE-05, ROUTE-06
**Complexity**: Medium — five routes plus a `ShellRoute` for bottom navigation; the main risk is ensuring all notifier navigation intents are wired to `context.go(...)` via `ref.listen` before `stacked_services` is removed.
**Success Criteria** (what must be TRUE):
  1. All five named routes (`/`, `/products`, `/product/:id`, `/add-product`, `/edit-product`) navigate correctly from every entry point in the app
  2. The bottom navigation shell (`MainView`) switches tabs without losing scroll position or triggering provider disposal, using `go_router` `ShellRoute`
  3. Pressing the back button or tapping a navigation link from `ProductDetailView` navigates correctly without crashing — route parameters are resolved
  4. Deleting a product from `ProductDetailView` triggers a dialog via `showDialog` in the widget layer (not via `DialogService`) and navigates back on confirmation
  5. No file in `lib/` imports `stacked_services` or references `NavigationService`, `SnackbarService`, or `DialogService`
**Plans**: TBD
**Canonical refs**:
  - `lib/app/app.dart` — `@StackedApp` annotation; replacement target with plain `MaterialApp.router`
  - `lib/app/app.router.dart` — generated Stacked router; deletion target after Phase 3
  - `lib/ui/views/main/` — `ShellRoute` implementation; bottom nav shell
  - `lib/ui/views/product_detail/` — `DialogService` replacement; back navigation
  - `.planning/research/SUMMARY.md` — go_router route table (5 routes), navigation intent pattern, Pitfall 6 and 13

---

### Phase 4: Package Removal
**Goal**: `stacked`, `stacked_services`, `stacked_generator`, `get_it`, and `injectable` are removed from `pubspec.yaml`. All generated Stacked files are deleted. `main.dart` contains only `ProviderScope` + Workmanager registration. `build_runner` and `flutter analyze` both produce zero errors.
**Depends on**: Phase 3
**Requirements**: CLEAN-01, CLEAN-02, CLEAN-03, CLEAN-04, CLEAN-05
**Complexity**: Low-Medium — mostly deletion and validation; the risk is any `locator<T>()` call missed during Phases 1–3 that now causes a compile error.
**Success Criteria** (what must be TRUE):
  1. `pubspec.yaml` contains no reference to `stacked`, `stacked_services`, `stacked_generator`, `get_it`, or `injectable`; `flutter_riverpod`, `riverpod_annotation`, and `go_router` are present with correct version constraints
  2. `lib/app/app.locator.dart`, `lib/app/app.router.dart`, `lib/core/viewmodels/app_viewmodel.dart`, and `stacked.json` no longer exist in the repository
  3. `dart run build_runner build --delete-conflicting-outputs` completes with zero errors; Drift, Freezed, and Riverpod generators all produce output in the same run
  4. `flutter analyze` reports zero errors and zero warnings related to missing imports, undefined symbols, or removed packages
  5. The app runs on device/simulator and all five screens load correctly with no runtime exceptions in the first 60 seconds of use
**Plans**: TBD
**Canonical refs**:
  - `pubspec.yaml` — packages to remove and add; version constraints
  - `lib/main.dart` — `setupLocator()` removal; final simplified bootstrap
  - `lib/app/app.dart` — rewrite as plain `MaterialApp.router` wrapper
  - `lib/app/app.locator.dart` — deletion target
  - `lib/app/app.router.dart` — deletion target
  - `stacked.json` — deletion target
  - `.planning/research/SUMMARY.md` — Phase 4 checklist, Pitfall 10 (residual locator calls)

---

### Phase 5: Cleanup and Test Baseline
**Goal**: Known pre-existing bugs are fixed. At least one provider unit test exists per migrated ViewModel. The broken scaffold counter test is replaced with a real smoke test. `riverpod_lint` reports no warnings.
**Depends on**: Phase 4
**Requirements**: TEST-01, TEST-02, TEST-03, TEST-04
**Complexity**: Medium — `markFailed` DAO race condition requires an atomic SQL update; `ProductDetailNotifier` null-hang fix may partially overlap with VM-04 work already done in Phase 2; writing provider unit tests requires `ProviderContainer` + `AppDatabase.forTesting()` pattern for each ViewModel.
**Success Criteria** (what must be TRUE):
  1. `test/widget_test.dart` contains a real smoke test (e.g., app launches and `ProductsView` renders at least one widget); the broken scaffold counter assertion is gone
  2. At least one `ProviderContainer`-based unit test exists for each of the six migrated notifiers — each test uses `AppDatabase.forTesting()` and verifies at least one state transition
  3. Navigating to a product detail screen for a product that was just deleted surfaces an error state or navigates back within 2 seconds — the infinite loading hang is confirmed fixed and covered by a test
  4. `riverpod_lint` (via `custom_lint`) reports zero warnings across all provider and notifier files
**Plans**: TBD
**Canonical refs**:
  - `test/widget_test.dart` — broken scaffold test; replacement target
  - `lib/data/local/database.dart` — `AppDatabase.forTesting()` constructor used in unit tests
  - `lib/data/local/daos/sync_queue_dao.dart` — `markFailed` DAO; atomic update fix (TEST-04)
  - `lib/ui/views/product_detail/` — null-hang confirmation and test coverage (TEST-03)
  - `analysis_options.yaml` — `custom_lint` plugin declaration required for `riverpod_lint`
  - `.planning/research/SUMMARY.md` — Phase 5 checklist, `ProviderContainer` test pattern

---

## Progress Table

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. DI Foundation | 0/3 | Not started | - |
| 2. ViewModel Migration | 0/? | Not started | - |
| 3. Routing Migration | 0/? | Not started | - |
| 4. Package Removal | 0/? | Not started | - |
| 5. Cleanup and Test Baseline | 0/? | Not started | - |

---

*Roadmap created: 2026-03-26*
*Last updated: 2026-03-26 — Phase 1 plans created (3 plans, 3 waves)*

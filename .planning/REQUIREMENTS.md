# Requirements: Offline-First Product Store

**Defined:** 2026-03-26
**Core Value:** Customers can browse and interact with the product catalog reliably, whether online or offline.

## v1 Requirements

### DI & Provider Infrastructure

- [ ] **DI-01**: App bootstraps with `ProviderScope` at root; `setupLocator()` and `app.locator.dart` removed
- [ ] **DI-02**: `AppDatabase` exposed as a Riverpod provider (replaces GetIt singleton)
- [ ] **DI-03**: `Dio` HTTP client exposed as a Riverpod provider
- [ ] **DI-04**: `ConnectivityService` migrated from `ListenableServiceMixin` to a `StreamProvider<bool>`
- [ ] **DI-05**: `SyncService` `isSyncing` state migrated from `ReactiveValue<bool>` to a stream-based Riverpod provider
- [ ] **DI-06**: Repository providers (`IProductsRepository`, `ICategoriesRepository`) replace `locator<T>()` calls
- [ ] **DI-07**: `DatabaseService` and `SyncService` exposed as keepAlive Riverpod providers

### ViewModel Migration

- [ ] **VM-01**: `MainViewModel` migrated to a Riverpod `Notifier`; `ConsumerWidget` replaces `ViewModelWidget`
- [ ] **VM-02**: `SyncQueueViewModel` migrated to a Riverpod `AsyncNotifier` watching the sync queue stream
- [ ] **VM-03**: `ProductsViewModel` migrated — search debounce, pagination, and category filter collapsed into a single `autoDispose StreamProvider` watching filter providers
- [ ] **VM-04**: `ProductDetailViewModel` migrated to `StreamProvider`; null product emission mapped to error state (fixes hang bug)
- [ ] **VM-05**: `AddProductViewModel` migrated; `TextEditingController` and `ScrollController` moved to `ConsumerStatefulWidget.State`
- [ ] **VM-06**: `EditProductViewModel` migrated; `TextEditingController` and `ScrollController` moved to `ConsumerStatefulWidget.State`
- [ ] **VM-07**: `AppViewModel` base class deleted; `AsyncValue<T>` from `AsyncNotifier` replaces `isBusy`/`modelError` pattern
- [ ] **VM-08**: All `StreamSubscription` manual `dispose()` boilerplate removed (replaced by Riverpod provider lifecycle)

### Routing

- [ ] **ROUTE-01**: `go_router` added; `StackedRouter` and generated `app.router.dart` removed
- [ ] **ROUTE-02**: All 5 named routes migrated (`/`, `/products`, `/product/:id`, `/add-product`, `/edit-product`)
- [ ] **ROUTE-03**: Bottom navigation shell (`MainView`) implemented with `go_router` `ShellRoute`
- [ ] **ROUTE-04**: `NavigationService` replaced with `context.go()` / `context.push()` calls
- [ ] **ROUTE-05**: `SnackbarService` replaced with `ScaffoldMessenger` / intent-as-state pattern
- [ ] **ROUTE-06**: `DialogService` replaced with `showDialog` / `showModalBottomSheet`

### Package Removal & Cleanup

- [ ] **CLEAN-01**: `stacked`, `stacked_services`, `stacked_generator` removed from `pubspec.yaml`
- [ ] **CLEAN-02**: `get_it`, `injectable`, `injectable_generator` removed from `pubspec.yaml`
- [ ] **CLEAN-03**: `app.locator.dart`, `stacked.json` deleted; `main.dart` simplified (no `setupLocator()`)
- [ ] **CLEAN-04**: `flutter_riverpod`, `riverpod_annotation`, `go_router` added; `riverpod_generator` added as dev dependency
- [ ] **CLEAN-05**: `build_runner` still produces clean output with Drift + Freezed + Riverpod generators coexisting

### Bug Fixes & Test Baseline

- [ ] **TEST-01**: Broken `test/widget_test.dart` scaffold test replaced with a real smoke test
- [ ] **TEST-02**: At least one provider unit test written per migrated ViewModel (uses `ProviderContainer` + `AppDatabase.forTesting()`)
- [ ] **TEST-03**: `ProductDetailViewModel` null-hang bug fixed (product deleted → error state, not infinite loading)
- [ ] **TEST-04**: `markFailed` DAO race condition fixed (atomic update replaces read-then-write)

## v2 Requirements

### Post-Migration Features

- **FEAT-01**: Image upload on product create/edit (currently placeholder)
- **FEAT-02**: API authentication (bearer token / OAuth)
- **FEAT-03**: Conflict resolution for concurrent edits
- **FEAT-04**: DB migration strategy (beyond schema version 1)
- **FEAT-05**: `hasMore` pagination fix with active category/search filters
- **FEAT-06**: Retry threshold extracted to `SyncConfig` constant (currently inconsistent across two files)

## Out of Scope

| Feature | Reason |
|---------|--------|
| New UI features | Migration only — visual behavior stays identical |
| New screens / flows | Scope is 1:1 feature parity after migration |
| BLoC / Provider state management | Decision: Riverpod only |
| Use case / interactor layer | Current domain/data layers kept as-is |
| Backend / API implementation | Frontend migration only |
| Workmanager isolate changes | Isolate must stay Riverpod-free — platform constraint |
| `iconsax` / `google_nav_bar` replacement | Risky dep but out of migration scope |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| DI-01 | — | Pending |
| DI-02 | — | Pending |
| DI-03 | — | Pending |
| DI-04 | — | Pending |
| DI-05 | — | Pending |
| DI-06 | — | Pending |
| DI-07 | — | Pending |
| VM-01 | — | Pending |
| VM-02 | — | Pending |
| VM-03 | — | Pending |
| VM-04 | — | Pending |
| VM-05 | — | Pending |
| VM-06 | — | Pending |
| VM-07 | — | Pending |
| VM-08 | — | Pending |
| ROUTE-01 | — | Pending |
| ROUTE-02 | — | Pending |
| ROUTE-03 | — | Pending |
| ROUTE-04 | — | Pending |
| ROUTE-05 | — | Pending |
| ROUTE-06 | — | Pending |
| CLEAN-01 | — | Pending |
| CLEAN-02 | — | Pending |
| CLEAN-03 | — | Pending |
| CLEAN-04 | — | Pending |
| CLEAN-05 | — | Pending |
| TEST-01 | — | Pending |
| TEST-02 | — | Pending |
| TEST-03 | — | Pending |
| TEST-04 | — | Pending |

**Coverage:**
- v1 requirements: 30 total
- Mapped to phases: 0 (pending roadmap)
- Unmapped: 30 ⚠️

---
*Requirements defined: 2026-03-26*
*Last updated: 2026-03-26 after initial definition*

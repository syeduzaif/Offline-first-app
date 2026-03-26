# Phase 1: DI Foundation - Context

**Gathered:** 2026-03-26
**Status:** Ready for planning

<domain>
## Phase Boundary

Establish the Riverpod provider graph (Tiers 1–5) covering all infrastructure, services, and repositories. Both DI systems (GetIt + Riverpod) coexist safely during this phase via bridge providers — no service is instantiated twice. `ListenableServiceMixin` and `ReactiveValue<bool>` are stripped from `ConnectivityService` and `SyncService` before any ViewModel is touched. Phase ends when all providers are resolvable from `ProviderScope` and a temporary `Consumer` widget can read `productsStreamProvider` successfully.

</domain>

<decisions>
## Implementation Decisions

### Provider Declaration Style
- **D-01:** Use `@riverpod` annotations for ALL providers throughout the entire migration — including bridge providers in Phase 1. Consistent code-gen style from day one, no exceptions. `riverpod_generator` is a dev dependency from Phase 1 forward.
- **D-02:** `build_runner` covers Drift + Freezed + Riverpod generators simultaneously in one command (`dart run build_runner build --delete-conflicting-outputs`). No separate generation steps.

### Bridge Provider Strategy (Pre-decided — locked)
- **D-03:** Bridge providers wrap existing GetIt singletons to prevent dual-instance bugs: `@riverpod SyncService syncService(SyncServiceRef ref) => locator<SyncService>()`. Bridges are removed in Phase 4 when GetIt is gone.
- **D-04:** `SyncConfig.maxRetries` constant extracted as the very first commit of Phase 1 (before touching any service), resolving the retry threshold inconsistency across `sync_service.dart` and one other file.

### isSyncing Signal (Claude's Discretion)
- **D-05:** `SyncService.isSyncing` exposed via `StreamController<bool>.broadcast()` — consistent with `ConnectivityService.onConnectivityChanged` which already uses this pattern. `_isSyncing` `ReactiveValue<bool>` replaced with `StreamController<bool>` + `bool get isSyncing`. `syncingProvider` is a `StreamProvider<bool>` backed by this stream.

### Provider File Organization (Claude's Discretion)
- **D-06:** Providers co-located in their owner files (`appDatabaseProvider` at the bottom of `database.dart`, `connectivityServiceProvider` in `connectivity_service.dart`, etc.). Keeps provider and the class it wraps in the same file — easier to navigate during migration.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Bootstrap & DI
- `lib/main.dart` — bootstrap order; `setupLocator()` call; `ProviderScope` wraps `MyApp` here
- `lib/app/app.locator.dart` — GetIt registrations being bridged; shows all singleton types

### Services (ListenableServiceMixin removal targets)
- `lib/services/connectivity_service.dart` — `ListenableServiceMixin` + `ReactiveValue<bool>` removal; `onConnectivityChanged` stream already exists (StreamController pattern already in place)
- `lib/services/sync_service.dart` — `ListenableServiceMixin` + `ReactiveValue<bool>` removal; `isSyncing` signal must be replaced before any ViewModel migration

### Infrastructure Providers
- `lib/data/local/database.dart` — `AppDatabase`; `appDatabaseProvider` lives here
- `lib/data/remote/api_client.dart` — Dio client; `apiClientProvider` lives here

### Repository Providers
- `lib/data/repositories/products_repository.dart` — `productsRepositoryProvider`
- `lib/data/repositories/categories_repository.dart` — `categoriesRepositoryProvider`

### Research
- `.planning/research/SUMMARY.md` — provider tier diagram (Tier 1–5), bridge provider pattern, Phase 1 pitfall list (Pitfalls 1, 2, 4, 10)

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `ConnectivityService.onConnectivityChanged`: already a `StreamController<bool>.broadcast()` stream — the `StreamProvider<bool>` for connectivity can watch this directly
- `ConnectivityService._isOnline`: getter available synchronously — useful as initial value when constructing the stream provider
- `SyncService`: constructor takes `SyncQueueDao`, `ProductsDao`, `ApiClient`, `ConnectivityService` — all will be injected via Riverpod refs in bridge provider

### Established Patterns
- `@freezed` on all domain models and DTOs — stay untouched
- File naming: `_wdiget.dart` suffix (intentional typo) — maintain throughout
- Interface abstraction: `IProductsRepository` / `ICategoriesRepository` in `lib/domain/repositories/`

### Integration Points
- `lib/main.dart` `main()`: add `ProviderScope` wrapping `MyApp`; `setupLocator()` remains alongside it during Phase 1
- `lib/main.dart` `callbackDispatcher()`: **do not touch** — Workmanager isolate must remain Riverpod-free permanently (platform constraint)
- `build_runner`: already configured; add `riverpod_generator` to dev deps; existing `dart run build_runner build --delete-conflicting-outputs` command covers everything

### Architecture Constraints
- Both DI systems must coexist from Phase 1 through Phase 3 without dual-instantiation — bridge providers are the enforcement mechanism
- Domain and data layers (Drift, Dio, repositories, Freezed models) are completely untouched throughout all phases
- Migration scope confined to `lib/ui/views/`, `lib/app/`, `lib/core/viewmodels/`, `lib/services/`

</code_context>

<specifics>
## Specific Ideas

No additional specific requirements — open to standard Riverpod approaches for provider wiring.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within Phase 1 scope.

</deferred>

---

*Phase: 01-di-foundation*
*Context gathered: 2026-03-26*

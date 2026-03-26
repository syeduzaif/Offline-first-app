# Project State

**Project:** Offline-First Product Store
**Milestone:** Riverpod Migration
**Initialized:** 2026-03-26
**Last updated:** 2026-03-26

---

## Current Position

**Phase:** 1 — DI Foundation
**Plan:** None started
**Status:** Not started

```
Progress: [----------] 0% (0/5 phases complete)
```

---

## Milestone Overview

Replacing Stacked MVVM + GetIt/Injectable with Riverpod across the presentation layer, while keeping the domain and data layers (Drift, Dio, repositories, Freezed models) entirely untouched.

**Phases:**
1. DI Foundation — provider graph + bridge providers (current)
2. ViewModel Migration — six ViewModels → Notifiers
3. Routing Migration — go_router replaces StackedRouter + stacked_services
4. Package Removal — stacked/get_it deleted, build clean
5. Cleanup and Test Baseline — bugs fixed, first real tests written

---

## Performance Metrics

| Metric | Value |
|--------|-------|
| Total v1 requirements | 30 |
| Requirements completed | 0 |
| Phases complete | 0/5 |
| Plans written | 0 |
| Plans complete | 0 |

---

## Accumulated Context

### Key Decisions Made

| Decision | Rationale |
|----------|-----------|
| Bottom-up migration order (leaf → root) | Prevents broken intermediate states; each commit leaves app fully functional |
| Bridge providers in Phase 1 | Prevents dual DI instance bugs while both systems coexist during Phase 1–2 |
| Routing deferred to Phase 3 | `stacked_services` cannot be removed until all VMs are off NavigationService |
| `ListenableServiceMixin` stripped in Phase 1 | Three screens depend on `isSyncing`; must be replaced before any VM migration |
| `TextEditingController`/`ScrollController` in widget State | Riverpod Notifier must hold only plain Dart values; widget lifecycle objects belong in StatefulWidget |

### Known Pre-Existing Bugs (to fix in Phase 5 unless noted)

| Bug | Where | Phase |
|-----|-------|-------|
| `ProductDetailViewModel` hangs if product deleted | `lib/ui/views/product_detail/` | Fix in Phase 2 (VM-04), test in Phase 5 (TEST-03) |
| `markFailed` DAO race condition (read-then-write, not atomic) | `lib/data/local/daos/sync_queue_dao.dart` | Phase 5 (TEST-04) |
| `hasMore` pagination unreliable with active filters | `lib/ui/views/products/` | Deferred to v2 (FEAT-05) |
| Retry threshold inconsistency across two files | `lib/services/sync_service.dart` + one other | Extract constant before Phase 1 begins |
| Broken scaffold counter widget test | `test/widget_test.dart` | Phase 5 (TEST-01) |

### Architecture Constraints to Preserve

- `callbackDispatcher` Workmanager isolate must remain Riverpod-free permanently (platform isolate constraint)
- `_wdiget.dart` file suffix typo is intentional — maintain throughout migration
- Drift schema and DAOs untouched — migration confined to `lib/ui/views/`, `lib/app/`, `lib/core/viewmodels/`
- `@freezed` annotations stay on all domain models and DTOs

### Active Todos

- [ ] Decide snackbar strategy (state-field + `ref.listen` vs. global `ScaffoldMessengerKey`) before `AddProductViewModel` migration
- [ ] Decide `go_router` route parameter typing (typed via `go_router_builder` vs. untyped `extra:`) before Phase 3
- [ ] Decide search debounce approach in `ProductsNotifier` (`Timer` in notifier vs. debounced `StateProvider`) before `ProductsViewModel` migration
- [ ] Extract `SyncConfig.maxRetries` constant as first commit of Phase 1

### Blockers

None.

---

## Session Continuity

### How to Resume

1. Read `ROADMAP.md` — identifies current phase and its requirements
2. Read the plan file for the current phase (when created): `.planning/plans/phase-1.md`
3. Check this file's "Active Todos" and "Blockers" sections
4. Read canonical refs for Phase 1 listed in ROADMAP.md before writing any code

### Next Action

Start Phase 1: DI Foundation.
Run `/gsd:plan-phase 1` to decompose Phase 1 into an executable plan.

---

*State initialized: 2026-03-26*

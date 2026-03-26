# Offline-First Product Store

## What This Is

An offline-first Flutter product catalog app for customers to browse a store. The app stores data locally with Drift (SQLite) and syncs changes to a REST API when connectivity is restored. The current goal is a full architecture migration — replacing Stacked MVVM + GetIt/Injectable with Riverpod — while keeping all existing features intact.

## Core Value

Customers can browse and interact with the product catalog reliably, whether online or offline.

## Requirements

### Validated

- ✓ Product listing with search and category filtering — existing
- ✓ Product detail view with image gallery section — existing
- ✓ Add product form — existing
- ✓ Edit product form — existing
- ✓ Offline-first local storage via Drift/SQLite — existing
- ✓ Sync queue for pending offline operations — existing
- ✓ Connectivity banner and status monitoring — existing
- ✓ Bottom navigation shell with tab routing — existing
- ✓ Sync queue viewer screen — existing

### Active

- [ ] Migrate all ViewModels from Stacked to Riverpod providers/notifiers
- [ ] Replace GetIt + Injectable DI with Riverpod providers
- [ ] Remove `stacked`, `stacked_services`, `get_it`, `injectable` dependencies
- [ ] Keep domain/data layer separation (repositories, DAOs, services unchanged)
- [ ] Keep `@freezed` for all domain models and DTOs
- [ ] All existing features work identically after migration

### Out of Scope

- New features — this milestone is architecture migration only; new capabilities come after
- Use cases / interactor layer — current domain/data layers are kept as-is
- UI/UX redesign — visual behavior stays the same
- Image upload implementation — known gap, deferred to post-migration
- Backend / authentication — no API auth exists; not in scope for migration

## Context

**Current stack (before migration):**
- Flutter + Dart, Stacked MVVM, GetIt + Injectable for DI
- Drift (SQLite ORM) for local storage with 3 tables: products, categories, sync_queue
- Dio for HTTP, Freezed for immutable models, Workmanager for background sync
- File naming convention: `_wdiget.dart` (intentional typo — maintain this)

**Known issues (from codebase audit):**
- Broken widget test (scaffold counter test, not real app test)
- `markFailed` DAO race condition (read-then-write, not atomic)
- `hasMore` pagination unreliable with active filters
- `ProductDetailViewModel` hangs forever if product deleted
- Retry threshold inconsistency across two files
- 0% meaningful test coverage

**Post-migration targets:**
- Riverpod providers replace ViewModels throughout `lib/ui/views/`
- `app.locator.dart` (generated GetIt locator) removed
- `stacked.json` config removed
- Services injected as Riverpod providers instead of registered in locator

## Constraints

- **Tech stack**: Flutter + Dart — non-negotiable
- **State management**: Riverpod only — no BLoC, no Stacked, no Provider
- **Data layer**: Drift ORM stays — schema and DAOs preserved
- **Models**: Freezed stays — @freezed annotations kept on all models and DTOs
- **Features**: Zero feature regression — migration must not break existing behavior
- **Naming**: Maintain `_wdiget.dart` file suffix convention (existing project pattern)

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Riverpod over BLoC | Simpler DI story, less boilerplate, composable providers | — Pending |
| Replace GetIt entirely | Riverpod handles DI natively; two DI systems is complexity without benefit | — Pending |
| Keep domain/data layers unchanged | Migration risk is lower; Riverpod only touches presentation layer | — Pending |
| Keep @freezed | Works well with Riverpod's immutability model; no reason to change | — Pending |
| Same features, no additions | Clean scope boundary; new features after stable Riverpod foundation | — Pending |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd:transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `/gsd:complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-03-26 after initialization*

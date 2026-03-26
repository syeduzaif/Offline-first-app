# Phase 1: DI Foundation - Discussion Log

**Session date:** 2026-03-26
**Phase:** 1 — DI Foundation

---

## Gray Areas Presented

Three gray areas were identified and presented to the user:

1. **Provider declaration style** — `@riverpod` annotations vs. manual `Provider()` syntax
2. **isSyncing signal mechanism** — `StreamController<bool>.broadcast()` vs. `ValueNotifier<bool>`
3. **Provider file organization** — co-located in owner files vs. centralized `providers.dart`

User selected: **Provider declaration style** only. Areas 2 and 3 left to Claude's discretion.

---

## Discussion

### Area: Provider Declaration Style

**Q1:** How should providers be declared throughout the migration?
- Options: Manual `Provider()` everywhere (recommended) / `@riverpod` annotations everywhere / Mixed (manual infra, @riverpod notifiers)
- **User selected:** `@riverpod` annotations everywhere

**Q2:** `@riverpod` for everything, including temporary bridge providers in Phase 1?
- Options: Yes — consistent style from day one / Bridge providers manual, everything else `@riverpod`
- **User selected:** Yes — consistent style from day one

**Decision captured:** All providers use `@riverpod` annotation style throughout the migration, including bridge providers in Phase 1. Consistent from day one.

---

## Decisions Not Discussed (Claude's Discretion)

- **isSyncing signal mechanism:** `StreamController<bool>.broadcast()` chosen — consistent with `ConnectivityService.onConnectivityChanged` pattern already in the codebase.
- **Provider file organization:** Co-located in owner files — keeps provider and the class it wraps together, easier to navigate during migration.

---

*Discussion log: 2026-03-26*

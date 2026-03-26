# Codebase Concerns & Risks

## Technical Debt

- **Stringly-typed sync status** — sync status stored as raw strings, not an enum or type-safe value; `SyncService` switch has no default branch
- **Silent image decode failure** — `images` JSON field is silently swallowed on decode failure; errors are invisible
- **Duplicated validation logic** — Add and Edit ViewModels repeat the same form validation; should be extracted
- **`markFailed` race condition** — DAO uses read-then-write instead of an atomic update; concurrent operations can corrupt state
- **Order-sensitive DI registration** — `main.dart` manual service registration is order-dependent; adding services in wrong order causes runtime errors

## Known Bugs

- **Broken widget test** — `test/widget_test.dart` is the Flutter counter template; it references a non-existent `MyApp()` counter and will fail on `flutter test`
- **`watchProduct` doesn't filter soft-deletes** — deleted products remain visible if watched directly
- **`hasMore` pagination unreliable** — when a category filter or search is active, `hasMore` flag gives wrong results
- **`ProductDetailViewModel` hangs** — shows `LoadingIndicator` forever if the product has been deleted

## Security Concerns

- **No API authentication** — `ApiClient` sends requests with no auth headers; any API key or token handling is absent
- **No input sanitization** — only null checks exist; no validation against XSS, injection, or length limits
- **Workmanager background isolate** — no error boundary; unhandled exceptions in background sync can crash silently

## Performance Concerns

- **`IndexedStack` keeps all tabs alive** — all tab ViewModels are instantiated and held in memory simultaneously
- **Non-atomic scroll guard** — `_loadMore` scroll trigger is not atomic; rapid scrolling can fire duplicate load requests
- **`CategoriesDao.replaceAll` flicker** — deletes and reinserts all categories on every refresh, causing momentary empty dropdowns in the UI

## Fragile / Risky Areas

- **Retry threshold inconsistency** — max retry cap is enforced in two places with different values (`< 3` in one, `>= 2` in another)
- **`SyncQueueDao.watchAll()` unbounded** — no pagination limit; large sync queues will load entirely into memory
- **DB schema at version 1, no migration** — no migration strategy defined; schema changes will require a manual wipe or will crash on upgrade

## Missing Features (Incomplete Implementation)

- **No conflict resolution** — concurrent edits from multiple devices have no merge or conflict detection strategy
- **No image upload** — `images` field exists on the product model but create/edit forms do not implement image upload
- **No offline-to-online transition tests** — the core value proposition of the app is untested end-to-end

## Dependencies at Risk

- `iconsax ^0.0.8` — pre-release version, low maintenance activity
- `google_nav_bar` — low community activity, may become abandoned
- `workmanager ^0.9` — iOS background execution is unreliable by platform design; background sync may silently not run on iOS

## Test Coverage

- **Effectively 0%** — entire business logic, sync engine, repositories, and ViewModels are untested
- No offline/online integration tests despite sync being the core feature
- `AppDatabase.forTesting()` constructor exists but is never used

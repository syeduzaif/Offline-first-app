# Architecture & Agent Guidelines — Offline-First Teacher App

## Why Offline-First?

An offline-first philosophy treats network connectivity as an enhancement rather than a prerequisite. In this model the local device database is the primary source of truth, so the app remains fully functional and responsive regardless of connectivity. Network access is used opportunistically for synchronization, not for core app functionality. This design eliminates latency from the user's critical path and avoids data loss when connectivity is intermittent or flaky.

---

## Package & Framework Decisions

| Layer / Concern       | Package                                           | Purpose |
|-----------------------|---------------------------------------------------|---------|
| Local database        | `drift` (SQLite) + `sqlcipher_flutter_libs`       | Reactive, type-safe SQLite API. Converts queries into live Streams. SQLCipher adds AES-256 encryption at rest. |
| Sync agent            | Custom outbox (adapted from offline_first_sync_drift pattern) | Implements the outbox pattern. Queues local changes, syncs them in the background, resolves conflicts. REST-compatible with Express/Mongo backend. |
| State management      | `flutter_riverpod` + `riverpod_annotation`        | Manages UI state and communicates with repositories. Subscribes to data streams and triggers UI updates reactively. |
| HTTP & caching        | `dio` + `dio_cache_interceptor`                   | HTTP requests to Express API. Caches GET responses offline. `hitCacheOnNetworkFailure` serves stale data when offline. |
| Connectivity          | `connectivity_plus` + `flutter_offline`           | Detects network status to trigger sync and show offline banners. |
| Secure storage        | `flutter_secure_storage`                          | Stores the SQLCipher encryption key and auth tokens. |
| Code generation       | `freezed`, `json_serializable`, `build_runner`    | Generates immutable data classes, JSON serialization, and Drift table definitions. |
| Navigation            | `go_router`                                       | Declarative routing with path parameters and ShellRoute for bottom nav. |
| Testing               | `flutter_test`, `mocktail`                        | Unit and widget testing. Mirror `lib/` structure in `test/`. |

---

## Layer Architecture

A robust offline-first architecture separates concerns and manages data flow through clearly defined layers:

```
┌─────────────────────────────────────────────────────────┐
│  Presentation Layer (UI)                                 │
│  ConsumerWidget / ConsumerStatefulWidget                 │
│  No business logic — only displays state, fires events   │
├─────────────────────────────────────────────────────────┤
│  State Management Layer (Riverpod)                       │
│  StreamProvider / @riverpod Notifiers                    │
│  Translates events → domain calls; exposes AsyncValue<T> │
├─────────────────────────────────────────────────────────┤
│  Repository Layer                                        │
│  Abstract interface + implementation                     │
│  Reads local DB first; writes locally then queues sync   │
│  Exposes Stream<T> for reactive UIs                      │
├─────────────────────────────────────────────────────────┤
│  Local Database Layer (Drift + SQLCipher)                │
│  AppDatabase + DAOs + Tables                             │
│  Device-local SQLite with AES-256 encryption at rest     │
├─────────────────────────────────────────────────────────┤
│  Sync Agent                                              │
│  SyncEngine (ChangeNotifier)                             │
│  Outbox pattern: polls sync_queue, batches to server     │
│  Runs in background via Workmanager                      │
├─────────────────────────────────────────────────────────┤
│  Remote API (Future — Express/Mongo)                     │
│  /sync/pull?since=<timestamp>  /sync/push               │
│  Accepts batched changes; returns only deltas            │
└─────────────────────────────────────────────────────────┘
```

---

## Data Flow

### Read Path
```
UI (ConsumerWidget)
  → ref.watch(someStreamProvider)
  → Repository.watchEntities()
  → DAO.watchAll()          ← Drift Stream, auto-updates on write
  → (if online) Repo calls API, upserts results to local DB → stream auto-emits
```

### Write Path
```
UI callback
  → ref.read(repositoryProvider).createEntity(data)
  → [Drift transaction] write entity + insert sync_queue record
  → DAO stream emits → UI updates immediately (offline-first!)
  → SyncEngine.syncAll() called fire-and-forget
  → (if online) SyncEngine reads sync_queue, POSTs to API, marks completed
```

---

## Project Structure (Feature-First)

```
lib/
├── main.dart                      # Entry point and bootstrap sequence
├── app.dart                       # Root widget (MyApp) + GoRouter definition
├── core/
│   ├── constants/
│   │   ├── app_colors.dart        # All Color constants
│   │   ├── app_text_styles.dart   # TextStyle constants + extensions
│   │   ├── app_font_sizes.dart    # Font size constants (ScreenUtil)
│   │   ├── app_layout.dart        # Radii, heights, widths, shadows
│   │   ├── app_paddings.dart      # Padding constants
│   │   ├── app_margins.dart       # Margin constants
│   │   └── strings/
│   │       ├── app_strings.dart   # Barrel export
│   │       └── common_strings.dart
│   ├── providers/
│   │   ├── providers.dart         # All @riverpod infrastructure providers
│   │   └── providers.g.dart       # Generated — never edit
│   ├── services/
│   │   ├── database.dart          # AppDatabase (Drift + SQLCipher)
│   │   ├── connectivity_service.dart
│   │   └── secure_storage.dart    # DB key + auth token storage
│   └── theme/
│       └── app_theme.dart         # Material 3 ThemeData
├── features/
│   ├── home/
│   │   ├── presentation/
│   │   │   ├── pages/             # *_page.dart screens
│   │   │   └── widgets/           # Feature-specific widgets
│   │   ├── domain/
│   │   │   ├── entities/          # @freezed domain models
│   │   │   └── repositories/      # Abstract interfaces (I*Repository)
│   │   └── data/
│   │       ├── models/            # @freezed DTOs (API response shapes)
│   │       ├── local/             # Drift tables + DAOs
│   │       ├── remote/            # API service methods
│   │       └── repositories/      # Concrete repository implementations
│   ├── students/   (same structure)
│   ├── attendance/ (same structure)
│   ├── timetable/  (same structure)
│   └── lms/        (same structure)
├── sync/
│   ├── sync_engine.dart           # ChangeNotifier — outbox processor
│   └── background_sync.dart       # Workmanager callback dispatcher
└── shared/
    └── widgets/
        ├── main_shell.dart        # Bottom nav + IndexedStack shell
        ├── loading_indicator_widget.dart
        ├── empty_state_widget.dart
        ├── error_retry_widget.dart
        └── offline_banner_widget.dart  # flutter_offline banner
```

Feature folders isolate each module (home, students, attendance, timetable, lms). Each owns its full presentation → domain → data stack. Only cross-feature code lives in `core/` or `shared/`.

---

## Sync Agent Rules

### Outbox Pattern (Critical)
When saving data, wrap the domain entity write AND the `sync_queue` insert in a **single Drift transaction**. This guarantees that a pending change is never lost if the app crashes between the local write and the network call.

```dart
// CORRECT — atomic write + queue enqueue
await database.transaction(() async {
  final id = await entitiesDao.upsertEntity(companion);
  await syncQueueDao.enqueue(SyncQueueCompanion(
    entityType: Value('entity_name'),
    entityId: Value(id),
    operation: Value('create'),
    payload: Value(jsonEncode(data)),
  ));
});
```

### Atomic Operations
Use Drift's `batch` and `transaction` for all multi-step DB writes. Never assume two sequential `await` calls are atomic.

### Background Execution
Run the sync agent via `Workmanager` on Android/iOS:
- Poll `sync_queue` every 15 minutes when online
- Group pending events by entity type and send in batches
- Apply remote deltas to local DB via Drift DAOs
- Never block UI interactions during sync

### Network & Connectivity
- Check connectivity before syncing via `ConnectivityService.isOnline`
- Subscribe to `onConnectivityChanged` stream to trigger sync when coming online
- If offline, postpone sync — do not throw errors to the user

### Conflict Resolution
- Default strategy: **last-write-wins** using `updated_at` timestamps
- Server timestamp takes precedence on pull (server-wins for remote changes)
- Client timestamp takes precedence on push if `updated_at > server.updated_at`
- Configure per-entity in `SyncEngine._processOperation`

### Retries & Back-off
- Exponential back-off delays: 1s → 2s → 4s → 8s
- Max 5 retry attempts per operation
- After max retries: mark entity `syncStatus = 'failed'`, stop retrying
- Persist `retryCount` and `lastAttemptAt` in `sync_queue` table

### Encryption & Security
- All local data encrypted with SQLCipher (AES-256)
- Encryption key generated once on first launch, stored in `flutter_secure_storage`
- Key never stored in plaintext, never in app bundle, never logged
- All network requests use HTTPS only
- Auth tokens stored in `flutter_secure_storage`, never in SharedPreferences

### Batch Endpoints (Future Backend Contract)
Design Express/Mongo API with:
- `POST /sync/push` — accepts `{ changes: [{ entityType, operation, payload, clientTimestamp }] }`
- `GET /sync/pull?since=<ISO8601>` — returns changed records since timestamp
- Reduces round trips; maintains consistency across entities

### Versioning & Timestamps
- Every synced entity has `updated_at` (DateTime) and `remote_id` (nullable int)
- `remote_id` is null until first successful sync
- `sync_queue` records carry `created_at` for ordering and `last_attempt_at` for back-off

### Logging & Telemetry
- Log sync start/end with operation count
- Log each operation result (success/failure) with entity type and ID
- Track: queued count, last successful sync timestamp, error count
- Do not log sensitive payload data in production

### Graceful Error Handling
- Catch network errors silently — retry later
- Catch serialization errors — mark operation failed, log for investigation
- Never drop user data — failed operations stay in queue with `syncStatus = 'failed'`
- Show user-visible error only after max retries exhausted

---

## Development Best Practices

### Strong Typing & Code Generation
- `@freezed` for all domain entities and DTOs — immutable, auto `copyWith`, `==`, `hashCode`
- `@riverpod` for all providers — codegen ensures consistency
- `@DriftDatabase` / `@DriftAccessor` for DB and DAOs
- Run after any change: `dart run build_runner build --delete-conflicting-outputs`

### Repository Pattern
- Repository is the ONLY place that knows about both local DB and remote API
- Never call the API from a Riverpod provider directly
- Never call the local DB from a Riverpod provider directly
- Repository exposes `Stream<T>` for reactive reads and `Future<T>` for writes

### Dependency Injection
- Use `ProviderScope.overrides` in `main()` — no GetIt, no service locator
- Infrastructure providers (`@Riverpod(keepAlive: true)`) throw `UnimplementedError` by default
- Override them with real instances in `runApp`
- This makes testing trivial: override with mocks in `ProviderContainer`

### ref Rules (Non-Negotiable)
| Location | Method | Rule |
|----------|--------|------|
| `build()` | `ref.watch()` | Only here |
| Callbacks, `initState`, `onTap` | `ref.read()` | Only here |
| `initState` reactive side effects | `ref.listenManual()` | Dispose the subscription |
| `build()` reactive side effects | `ref.listen()` | OK in build |

### Testing
- Unit tests: DAOs, repositories, use cases
- Widget tests: key UI components
- Mirror `lib/` structure in `test/`
- Use `AppDatabase.forTesting(QueryExecutor)` for in-memory Drift tests
- Use `mocktail` to mock repositories in widget tests

---

## Anti-Patterns — Never Do These

```dart
// ❌ ViewModel / Controller classes
class StudentsViewModel extends ChangeNotifier { ... }

// ❌ ref.watch in initState or callbacks
void initState() {
  final students = ref.watch(studentsStreamProvider); // CRASH
}

// ❌ Force-casting API responses
final data = response.data as Map<String, dynamic>;  // throws on null
final id = data['id'] as int;                         // throws on double

// ❌ Hardcoded strings
Text('Add Student')   // use CommonStrings.addStudent

// ❌ Hardcoded dimensions
SizedBox(height: 12)  // use SizedBox(height: AppLayout.height12)

// ❌ Hardcoded colors
color: Color(0xFF3C26BF)  // use AppColors.primary

// ❌ Writing to API without sync queue
await apiClient.createStudent(data);  // bypasses offline-first

// ❌ Non-atomic write + enqueue
await dao.insert(entity);              // if crash here...
await syncQueueDao.enqueue(op);        // ...this never runs

// ❌ Storing encryption key in SharedPreferences
prefs.setString('db_key', key);       // not secure

// ❌ Navigator for screen-level navigation
Navigator.of(context).pushNamed('/students');  // use context.push('/students')

// ❌ Passing objects via GoRouter extra for deep-linkable screens
context.push('/student/edit', extra: student);  // use path ID + fetch by ID
```

---

## SQLCipher Setup with Drift

```dart
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';
import 'package:sqlite3/open.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

LazyDatabase openEncryptedConnection(String key) {
  return LazyDatabase(() async {
    // Override sqlite3 open to use SQLCipher
    open.overrideFor(OperatingSystem.android, openCipherOnAndroid);
    open.overrideFor(OperatingSystem.iOS, openCipherOnIOS);

    final dbDir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbDir.path, 'teacher_app.sqlite'));
    final db = sqlite3.open(file.path);
    db.execute("PRAGMA key = '$key'");       // unlock with encryption key
    db.execute("PRAGMA journal_mode = WAL"); // better concurrent performance
    return NativeDatabase.opened(db);
  });
}
```

Key rules:
- Call `open.overrideFor` BEFORE opening the database
- Set `PRAGMA key` IMMEDIATELY after opening — before any other PRAGMA
- The key is a 32-byte hex string generated by `flutter_secure_storage` on first launch
- Never hardcode the key — always read from secure storage

# CLAUDE.md — Offline-First Teacher App

This file is the single source of truth for any AI agent building or modifying this codebase.
Read it completely before writing a single line of code.

---

## 1. What This App Is

A Flutter offline-first **teacher app**. Features: home dashboard, student profiles, attendance management, timetable, and LMS (classes, assignments, grading). All writes go to a local SQLite database (encrypted with SQLCipher) first. A sync queue pushes those changes to a remote REST API when connectivity is available. The app is fully functional with no internet connection.

Architecture document: see `docs/ARCHITECTURE.md`.

---

## 2. Tech Stack

| Concern | Package | Version |
|---|---|---|
| State management | `flutter_riverpod` + `riverpod_annotation` | ^2.6.1 |
| Navigation | `go_router` | ^14.6.3 |
| Local database | `drift` + `sqlcipher_flutter_libs` | ^2.24.0 |
| HTTP client | `dio` + `dio_cache_interceptor` | ^5.4.0 |
| Domain models | `freezed` + `json_serializable` | ^3.0.0 |
| Connectivity | `connectivity_plus` + `flutter_offline` | ^6.1.4 |
| Secure storage | `flutter_secure_storage` | ^9.2.2 |
| Background sync | `workmanager` | ^0.9.0 |
| Responsive UI | `flutter_screenutil` | ^5.9.3 |
| Icons | `iconsax` | ^0.0.8 |
| Image caching | `cached_network_image` | ^3.4.1 |
| Bottom nav | `google_nav_bar` | ^5.0.7 |

**Code generation dev deps**: `build_runner`, `drift_dev`, `freezed`, `json_serializable`,
`riverpod_generator`, `custom_lint`, `riverpod_lint`.

Run code generation with:
```
dart run build_runner build --delete-conflicting-outputs
```

---

## 3. Directory Structure (Feature-First)

```
lib/
├── main.dart                       # Bootstrap sequence — see Section 12
├── app.dart                        # GoRouter + MyApp root widget
├── core/
│   ├── constants/
│   │   ├── app_colors.dart         # All Color constants
│   │   ├── app_layout.dart         # Radii, heights, widths, shadows (ScreenUtil)
│   │   ├── app_paddings.dart       # Padding constants (ScreenUtil)
│   │   ├── app_margins.dart        # Margin constants (ScreenUtil)
│   │   ├── app_text_styles.dart    # TextStyle constants + .bold / .semiBold / .withColor extensions
│   │   ├── app_font_sizes.dart     # Font size constants (ScreenUtil)
│   │   └── strings/
│   │       ├── app_strings.dart    # Barrel export
│   │       └── common_strings.dart
│   ├── providers/
│   │   ├── providers.dart          # All @riverpod infrastructure provider declarations
│   │   └── providers.g.dart        # Generated — never edit manually
│   ├── services/
│   │   ├── database.dart           # AppDatabase (@DriftDatabase) + openEncryptedConnection
│   │   ├── connectivity_service.dart  # ChangeNotifier — wraps connectivity_plus
│   │   └── secure_storage.dart     # DB key + auth token management
│   └── theme/
│       └── app_theme.dart          # ThemeData
├── features/
│   ├── home/
│   │   ├── presentation/
│   │   │   ├── pages/              # *_page.dart (ConsumerWidget / ConsumerStatefulWidget)
│   │   │   └── widgets/            # Feature-scoped widgets
│   │   ├── domain/
│   │   │   ├── entities/           # @freezed domain models
│   │   │   └── repositories/       # Abstract interfaces (I*Repository)
│   │   └── data/
│   │       ├── models/             # @freezed DTOs (API shapes)
│   │       ├── local/              # Drift tables + DAOs
│   │       ├── remote/             # API service methods
│   │       └── repositories/       # Concrete implementations
│   ├── students/    (same structure as home/)
│   ├── attendance/  (same structure as home/)
│   ├── timetable/   (same structure as home/)
│   └── lms/         (same structure as home/)
├── sync/
│   ├── sync_engine.dart            # ChangeNotifier — outbox processor (background sync)
│   └── background_sync.dart        # Workmanager callbackDispatcher
└── shared/
    └── widgets/
        ├── main_shell.dart         # Bottom nav + IndexedStack shell
        ├── loading_indicator_widget.dart
        ├── empty_state_widget.dart
        ├── error_retry_widget.dart
        └── offline_banner_widget.dart
```

---

## 4. Architecture Rules — Non-Negotiable

### 4.1 No ViewModels
There are **no ViewModel classes** in this codebase. State lives in Riverpod providers only.
Do not create classes named `*ViewModel`, `*Controller`, `*Cubit`, or `*Bloc`.

### 4.2 Data Flow
```
Remote API → Repository → Local DB (Drift+SQLCipher) → StreamProvider → ConsumerWidget
```
- Read: `ref.watch(someStreamProvider)` in `build()` — reactive, auto-rebuilds
- Write: `ref.read(repositoryProvider).createEntity(...)` in callbacks
- Services: `ref.watch(syncEngineProvider).isSyncing` — ChangeNotifier, rebuilds on change

### 4.3 ref Rules
| Location | Method | Rule |
|---|---|---|
| `build()` | `ref.watch()` | Only here |
| Callbacks, `initState`, `onTap` | `ref.read()` | Only here |
| `initState` reactive side effects | `ref.listenManual()` | Dispose the subscription |
| `build()` reactive side effects | `ref.listen()` | OK in build |

**Never** call `ref.watch()` inside `initState`, `didChangeDependencies`, or any callback.

### 4.4 Write Flow (Offline-First, Atomic)
Every mutation follows this exact order:
1. Open a Drift **transaction** wrapping steps 2 and 3
2. Write entity to local Drift DB
3. Insert record in `sync_queue` table (same transaction — atomic!)
4. Call `ref.read(syncEngineProvider).syncAll().ignore()` fire-and-forget
5. Stream from DB auto-updates all watching providers — UI reflects change instantly

**Never** write entity and sync_queue record outside a transaction.
**Never** write directly to the remote API without going through the sync queue.

### 4.5 Widget Selection
| When | Widget |
|---|---|
| Needs local state (scroll controller, form controllers, debounce timer) | `ConsumerStatefulWidget` |
| Only reads providers, no local state | `ConsumerWidget` |
| Pure UI, receives all data as constructor params | `StatelessWidget` |
| Needs local state but no providers | `StatefulWidget` |

Do not use `ConsumerStatefulWidget` when `ConsumerWidget` is sufficient.

---

## 5. Providers — @riverpod Codegen

All infrastructure providers live in `lib/core/providers/providers.dart`.
Feature-level providers live in `features/<feature>/presentation/` (co-located).
After any change to provider files, run `build_runner build`.

### Infrastructure providers (overridden in main.dart)
```dart
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) => throw UnimplementedError();

@Riverpod(keepAlive: true)
ApiClient apiClient(Ref ref) => throw UnimplementedError();

@Riverpod(keepAlive: true)
SecureStorageService secureStorage(Ref ref) => throw UnimplementedError();

// Services use manual ChangeNotifierProvider so they survive hot reload
final connectivityServiceProvider = ChangeNotifierProvider<ConnectivityService>(
  (ref) => throw UnimplementedError(),
);

final syncEngineProvider = ChangeNotifierProvider<SyncEngine>(
  (ref) => throw UnimplementedError(),
);
```

### Derived boolean providers
```dart
@riverpod
bool isOnline(Ref ref) => ref.watch(connectivityServiceProvider).isOnline;

@riverpod
bool isSyncing(Ref ref) => ref.watch(syncEngineProvider).isSyncing;
```

**Provider naming convention**: `@riverpod` on `studentsStream(Ref ref)` generates
`studentsStreamProvider`. The generated name is always `camelCase + Provider`.

---

## 6. Navigation — GoRouter with ShellRoute

Router lives in `lib/app.dart`. Export a single `final appRouter = GoRouter(...)`.

### Route structure
```dart
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(path: '/', builder: (_, __) => const HomePage()),
        GoRoute(path: '/students', builder: (_, __) => const StudentsPage()),
        GoRoute(
          path: '/students/:id',
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '');
            if (id == null) return const _ErrorPage();
            return StudentProfilePage(studentId: id);
          },
        ),
        GoRoute(path: '/attendance', builder: (_, __) => const AttendancePage()),
        GoRoute(path: '/timetable', builder: (_, __) => const TimetablePage()),
        GoRoute(path: '/lms', builder: (_, __) => const LmsPage()),
      ],
    ),
  ],
);
```

### Navigation calls (in views, never in providers/services)
```dart
context.push('/students/${student.id}');
context.pop();
```

### Rules
- **Always use `int.tryParse`** on path parameters — never force-cast
- **Never pass complex objects via `extra`** — pass IDs in path, fetch from DB in destination
- Route builders must always return a valid widget — return `_ErrorPage()` on bad params

---

## 7. Local Database — Drift + SQLCipher

### Database declaration
```dart
@DriftDatabase(tables: [SyncQueue], daos: [SyncQueueDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase(String encryptionKey) : super(openEncryptedConnection(encryptionKey));
  AppDatabase.forTesting(super.e);

  @override int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async => await m.createAll(),
  );
}
```

### SQLCipher connection (always use this pattern)
```dart
LazyDatabase openEncryptedConnection(String key) {
  return LazyDatabase(() async {
    open.overrideFor(OperatingSystem.android, openCipherOnAndroid);
    open.overrideFor(OperatingSystem.iOS, openCipherOnIOS);
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'teacher_app.sqlite'));
    final db = sqlite3.open(file.path);
    db.execute("PRAGMA key = '$key'");
    db.execute("PRAGMA journal_mode = WAL");
    return NativeDatabase.opened(db);
  });
}
```

### Table pattern — every synced entity has
```dart
TextColumn get syncStatus => text().withDefault(const Constant('synced'))();
DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
IntColumn get remoteId => integer().nullable()();
BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
```

- Always filter `isDeleted.equals(false)` in watch queries
- Use soft delete on user action; hard delete only after confirmed remote delete
- DAO methods are thin — no business logic

---

## 8. Sync Queue Schema

| Column | Type | Notes |
|---|---|---|
| `id` | int autoIncrement | |
| `operation` | text | `'create'` / `'update'` / `'delete'` |
| `entityType` | text | e.g. `'student'`, `'attendance'` |
| `entityId` | int | local DB id |
| `payload` | text | JSON string |
| `status` | text | `'pending'` / `'inProgress'` / `'completed'` / `'failed'` |
| `retryCount` | int default 0 | max 5 attempts |
| `createdAt` | datetime | |
| `lastAttemptAt` | datetime nullable | |
| `errorMessage` | text nullable | |

### SyncEngine rules
- Extends `ChangeNotifier`
- `syncAll()` is idempotent — `_isSyncing` guard at entry
- Call `resetInProgressToPending()` at START of every `syncAll()`
- Exponential back-off: `Duration(seconds: pow(2, retryCount).toInt())`
- Max 5 retries → mark entity `syncStatus = 'failed'`
- All API casts must be null-safe (see anti-patterns below)
- `dispose()` cancels `_connectivitySub`

---

## 9. Repository Pattern

### Interface (inside each feature's `domain/repositories/`)
```dart
abstract interface class IStudentsRepository {
  Stream<List<Student>> watchStudents();
  Stream<Student?> watchStudent(int id);
  Future<Student> createStudent(Student student);
  Future<Student> updateStudent(Student student);
  Future<void> deleteStudent(int id);
}
```

### Implementation
- Constructor takes `dao`, `syncQueueDao`, `apiClient`
- `_toDomain(Row row)` mapper — Drift row → domain entity
- All writes use a **single Drift transaction** for entity + sync_queue
- All stream methods delegate to DAO

---

## 10. Domain Models — Freezed

```dart
@freezed
abstract class Student with _$Student {
  const factory Student({
    required int id,
    required String name,
    @Default(SyncStatus.synced) SyncStatus syncStatus,
    DateTime? updatedAt,
    int? remoteId,
  }) = _Student;

  factory Student.fromJson(Map<String, dynamic> json) => _$StudentFromJson(json);
}
```

- All domain models use `@freezed`
- DTOs (`data/models/`) are separate `@freezed` classes for API shapes
- Do not add methods to domain models — pure data only

---

## 11. Bootstrap Sequence (main.dart)

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final secureStorage = SecureStorageService();
  final dbKey = await secureStorage.getDatabaseKey();
  final db = AppDatabase(dbKey);
  final apiClient = ApiClient();

  final connectivity = ConnectivityService();
  await connectivity.initialize();

  final syncEngine = SyncEngine(
    database: db,
    apiClient: apiClient,
    connectivityService: connectivity,
  );
  syncEngine.initialize();

  await Workmanager().initialize(callbackDispatcher);
  await Workmanager().registerPeriodicTask(
    'teacher-app-sync', 'backgroundSync',
    frequency: const Duration(minutes: 15),
    constraints: Constraints(networkType: NetworkType.connected),
  );

  runApp(ProviderScope(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
      apiClientProvider.overrideWithValue(apiClient),
      secureStorageProvider.overrideWithValue(secureStorage),
      connectivityServiceProvider.overrideWith((ref) => connectivity),
      syncEngineProvider.overrideWith((ref) => syncEngine),
    ],
    child: const MyApp(),
  ));
}
```

---

## 12. Naming Conventions

| Thing | Convention | Example |
|---|---|---|
| Files | `snake_case` | `students_page.dart` |
| Screen files | `*_page.dart` | `student_profile_page.dart` |
| Widget files | `*_widget.dart` | `student_card_widget.dart` |
| Classes | `PascalCase` | `StudentsPage`, `SyncEngine` |
| Providers (generated) | `camelCaseProvider` | `studentsStreamProvider` |
| Private fields | `_camelCase` | `_isSaving` |
| Constants classes | Private constructor | `AppColors._()` |
| String classes | `*Strings` | `CommonStrings` |
| DAO classes | `*Dao` | `StudentsDao` |
| Repository interfaces | `I*Repository` | `IStudentsRepository` |
| Repository implementations | `*Repository` | `StudentsRepository` |
| DTOs | `*Dto` | `StudentDto` |
| Domain entities | plain name | `Student` |

---

## 13. Anti-Patterns — Never Do These

```dart
// ❌ ViewModel / Controller classes
class StudentsViewModel extends ChangeNotifier { ... }

// ❌ ref.watch in initState or callbacks — CRASH
void initState() { final s = ref.watch(studentsStreamProvider); }

// ❌ Non-atomic write + enqueue
await dao.insert(entity);       // app crash here = lost data
await syncQueueDao.enqueue(op); // use transaction wrapping both

// ❌ Force-casting API responses
final data = response.data as Map<String, dynamic>;
final id = data['id'] as int;

// ❌ Hardcoded strings / dimensions / colors
Text('Add Student')           // use CommonStrings
SizedBox(height: 12)          // use AppLayout.height12
Color(0xFF3C26BF)             // use AppColors.primary

// ❌ Encryption key in SharedPreferences
prefs.setString('key', dbKey) // use flutter_secure_storage

// ❌ Writing to API without sync queue
await apiClient.createStudent(data);

// ❌ Navigator for screen navigation
Navigator.of(context).pushNamed('/students'); // use context.push

// ❌ GetIt / service locator
GetIt.instance.get<StudentsRepository>()  // use ProviderScope.overrides
```

---

## 14. flutter analyze

Zero errors, zero warnings before every commit. Run:
```
flutter analyze
```

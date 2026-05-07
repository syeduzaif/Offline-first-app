# Roadmap: Offline-First Teacher App

**Milestone:** Teacher App — Full Offline-First Rebuild
**Initialized:** 2026-05-07
**Granularity:** standard

---

## Overview

Complete project revamp. The existing product-catalog demo has been replaced with a teacher app following a feature-first architecture, Riverpod state management, Drift+SQLCipher local database, and a custom outbox-pattern sync agent.

Architecture reference: `docs/ARCHITECTURE.md`
Agent reference: `CLAUDE.md`

---

## Phase 1: Foundation ✅ (Current)

**Goal:** Feature-first scaffold, packages, core infrastructure, architecture documentation.

**Delivers:**
- `docs/ARCHITECTURE.md` — architecture & agent guidelines document
- Updated `CLAUDE.md` — new rules for teacher app
- Updated `pubspec.yaml` — Riverpod, SQLCipher, flutter_secure_storage, dio_cache_interceptor, flutter_offline
- Feature-first directory structure (`features/home`, `students`, `attendance`, `timetable`, `lms`)
- Core services: `AppDatabase` (Drift + SQLCipher), `ConnectivityService`, `SecureStorageService`
- `SyncEngine` (outbox pattern, ChangeNotifier)
- Riverpod infrastructure providers (`core/providers/providers.dart`)
- `app.dart` (GoRouter with ShellRoute), `main.dart` (bootstrap), `MainShell` (bottom nav)
- Placeholder pages for all 5 features
- `flutter analyze` clean, app boots on simulator

**Success criteria:**
- App launches without crash
- All 5 nav tabs navigate correctly
- `flutter analyze` zero errors, zero warnings
- `dart run build_runner build` completes clean

---

## Phase 2: Domain Models + Sync Infrastructure

**Goal:** Freezed domain models for all teacher-app entities; SyncEngine fully wired to AppDatabase; sync agent processes real operations against a mock/stub API.

**Requires:** Phase 1 complete

**Delivers:**
- Domain entities: `Student`, `AttendanceRecord`, `TimetableEntry`, `LmsClass`, `Assignment`
- Drift tables for all entities (each with `syncStatus`, `updatedAt`, `remoteId`, `isDeleted`)
- SyncQueueDao fully implemented with exponential back-off
- `ApiClient` updated with teacher-app endpoints (or stub implementations)
- End-to-end write flow verified: create entity → sync_queue → sync attempt
- `SyncEngine` tested with mock connectivity toggle

**Success criteria:**
- Creating an entity writes to local DB and inserts sync_queue record in one transaction
- Toggling offline mode queues operations; going online triggers `syncAll()`
- `retryCount` increments correctly; `syncStatus = 'failed'` after max retries

---

## Phase 3: Home + Students Feature

**Goal:** Home dashboard and Students feature implemented offline-first with real UI from teacher-app.

**Requires:** Phase 2 complete

**Delivers:**
- `HomePage` — dashboard cards (tasks, schedule, recent classes), pulled from teacher-app UI
- `StudentsPage` — student list with search, Riverpod StreamProvider
- `StudentProfilePage` — 7-tab profile (overview, timetable, attendance, behavior, etc.)
- Student domain: `IStudentsRepository`, `StudentsRepository`, `StudentsDao`, `StudentDto`
- Offline-first create/edit/delete student with sync queue
- Mock data fallback while backend is unavailable

**Success criteria:**
- Student list shows reactively from local DB
- Create/edit/delete student works offline
- Sync queue shows pending operations for created/edited/deleted students
- `flutter analyze` clean

---

## Phase 4: Attendance + Timetable Feature

**Goal:** Attendance marking/viewing and Timetable display implemented offline-first.

**Requires:** Phase 3 complete

**Delivers:**
- `AttendancePage` — mark attendance by class/student, view history
- `TimetablePage` — weekly/daily schedule view (campus, periods)
- Attendance domain: `IAttendanceRepository`, `AttendanceRepository`, `AttendanceDao`
- Timetable domain: `ITimetableRepository`, `TimetableRepository`, `TimetableDao`
- Offline-first attendance marking (queued until online)
- Pulled from teacher-app UI (AttendanceView, TimetableView)

**Success criteria:**
- Attendance marking works offline and syncs when online
- Timetable loads from local DB, refreshes from API when online
- `flutter analyze` clean

---

## Phase 5: LMS Feature

**Goal:** Classes, assignments, classwork, and grading screens with offline-first data.

**Requires:** Phase 4 complete

**Delivers:**
- `LmsPage` — class list with filters
- `ClassPage` — shell with 4 tabs (stream, classwork, curriculum, people)
- Assignment creation, grading, material management
- LMS domain models, repositories, DAOs
- Offline-first assignment creation and grading
- Pulled from teacher-app LMS UI (600+ lines of complex grading UI)

**Success criteria:**
- Class list loads offline
- Assignment creation queues for sync
- Grading submissions work offline

---

## Phase 6: Cleanup, Tests & Security Audit

**Goal:** SQLCipher encryption verified, test coverage baseline, zero linting warnings.

**Requires:** Phase 5 complete

**Delivers:**
- Unit tests: all DAOs, all repositories (using `AppDatabase.forTesting()`)
- Widget tests: key screens (StudentsPage, AttendancePage)
- SQLCipher verification: database file is not readable as plain text
- `riverpod_lint` warnings zero
- `flutter analyze` zero errors/warnings
- Performance profiling: sync operation timing, stream rebuild counts
- Workmanager background sync verified on real device

**Success criteria:**
- `flutter test` passes with meaningful coverage
- Database file binary shows encrypted content (not plaintext)
- `flutter analyze` clean
- Background sync fires correctly on real Android/iOS device

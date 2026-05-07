import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/open.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';

part 'database.g.dart';

// ─── SyncStatus enum ─────────────────────────────────────────────────────────

enum SyncStatus { synced, pending, inProgress, failed }

// ─── Tables ──────────────────────────────────────────────────────────────────

@DataClassName('SyncQueueEntry')
class SyncQueue extends Table {
  IntColumn get id          => integer().autoIncrement()();
  TextColumn get operation  => text()(); // 'create' | 'update' | 'delete'
  TextColumn get entityType => text()(); // e.g. 'student', 'attendance'
  IntColumn get entityId    => integer()();
  TextColumn get payload    => text()(); // JSON string
  TextColumn get status     => text().withDefault(const Constant('pending'))();
  IntColumn get retryCount  => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt     => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastAttemptAt => dateTime().nullable()();
  TextColumn get errorMessage      => text().nullable()();
}

@DataClassName('StudentRow')
class Students extends Table {
  IntColumn get id         => integer().autoIncrement()();
  TextColumn get name      => text()();
  TextColumn get email     => text().withDefault(const Constant(''))();
  TextColumn get phone     => text().withDefault(const Constant(''))();
  TextColumn get grade     => text().withDefault(const Constant(''))();
  TextColumn get section   => text().withDefault(const Constant(''))();
  TextColumn get branch    => text().withDefault(const Constant(''))();
  TextColumn get avatarUrl => text().withDefault(const Constant(''))();
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get remoteId   => integer().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}

@DataClassName('AttendanceRow')
class AttendanceRecords extends Table {
  IntColumn get id        => integer().autoIncrement()();
  IntColumn get studentId => integer()();
  IntColumn get classId   => integer()(); // local id of LmsClass
  TextColumn get date     => text()();    // ISO8601 date string
  TextColumn get status   => text()();    // 'present' | 'absent' | 'late'
  TextColumn get notes    => text().withDefault(const Constant(''))();
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get remoteId  => integer().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}

@DataClassName('TimetableRow')
class TimetableEntries extends Table {
  IntColumn get id           => integer().autoIncrement()();
  TextColumn get className   => text()();
  TextColumn get subject     => text()();
  TextColumn get teacherName => text()();
  TextColumn get day         => text()(); // 'Mon' | 'Tue' | 'Wed' | 'Thu' | 'Fri'
  TextColumn get type        => text()(); // 'lesson' | 'break' | 'free'
  TextColumn get startTime   => text().withDefault(const Constant(''))();
  TextColumn get endTime     => text().withDefault(const Constant(''))();
  TextColumn get room        => text().withDefault(const Constant(''))();
  TextColumn get campus      => text().withDefault(const Constant(''))();
  TextColumn get syncStatus  => text().withDefault(const Constant('synced'))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get remoteId     => integer().nullable()();
  BoolColumn get isDeleted   => boolean().withDefault(const Constant(false))();
}

@DataClassName('LmsClassRow')
class LmsClasses extends Table {
  IntColumn get id           => integer().autoIncrement()();
  TextColumn get name        => text()();
  TextColumn get campus      => text().withDefault(const Constant(''))();
  TextColumn get grade       => text().withDefault(const Constant(''))();
  TextColumn get section     => text().withDefault(const Constant(''))();
  TextColumn get subject     => text().withDefault(const Constant(''))();
  TextColumn get teacherName => text().withDefault(const Constant(''))();
  IntColumn get studentCount => integer().withDefault(const Constant(0))();
  TextColumn get syncStatus  => text().withDefault(const Constant('synced'))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get remoteId     => integer().nullable()();
  BoolColumn get isDeleted   => boolean().withDefault(const Constant(false))();
}

@DataClassName('ClassworkRow')
class LmsClassworkItems extends Table {
  IntColumn get id             => integer().autoIncrement()();
  IntColumn get classId        => integer()();
  TextColumn get title         => text()();
  TextColumn get type          => text()(); // 'assignment' | 'material'
  TextColumn get topic         => text().withDefault(const Constant(''))();
  TextColumn get status        => text().withDefault(const Constant(''))();
  IntColumn get totalPoints    => integer().withDefault(const Constant(0))();
  IntColumn get submittedCount => integer().withDefault(const Constant(0))();
  IntColumn get gradedCount    => integer().withDefault(const Constant(0))();
  IntColumn get totalCount     => integer().withDefault(const Constant(0))();
  TextColumn get dueDate       => text().nullable()(); // ISO8601
  TextColumn get syncStatus    => text().withDefault(const Constant('synced'))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get remoteId       => integer().nullable()();
  BoolColumn get isDeleted     => boolean().withDefault(const Constant(false))();
}

// ─── DAOs ────────────────────────────────────────────────────────────────────

@DriftAccessor(tables: [SyncQueue])
class SyncQueueDao extends DatabaseAccessor<AppDatabase>
    with _$SyncQueueDaoMixin {
  SyncQueueDao(super.db);

  Future<void> enqueue(SyncQueueCompanion entry) =>
      into(syncQueue).insert(entry);

  Future<List<SyncQueueEntry>> getPendingOperations() =>
      (select(syncQueue)
        ..where((t) => t.status.isIn(['pending', 'failed']))
        ..where((t) => t.retryCount.isSmallerThanValue(5))
        ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
      .get();

  Future<void> markInProgress(int id) =>
      (update(syncQueue)..where((t) => t.id.equals(id)))
          .write(SyncQueueCompanion(
        status: const Value('inProgress'),
        lastAttemptAt: Value(DateTime.now()),
      ));

  Future<void> markCompleted(int id) =>
      (update(syncQueue)..where((t) => t.id.equals(id)))
          .write(const SyncQueueCompanion(status: Value('completed')));

  Future<void> markFailed(int id, String error) async {
    final existing = await (select(syncQueue)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    final newCount = (existing?.retryCount ?? 0) + 1;
    await (update(syncQueue)..where((t) => t.id.equals(id)))
        .write(SyncQueueCompanion(
      status: const Value('failed'),
      errorMessage: Value(error),
      lastAttemptAt: Value(DateTime.now()),
      retryCount: Value(newCount),
    ));
  }

  Future<void> resetInProgressToPending() =>
      (update(syncQueue)..where((t) => t.status.equals('inProgress')))
          .write(const SyncQueueCompanion(status: Value('pending')));

  Future<void> clearCompleted() =>
      (delete(syncQueue)..where((t) => t.status.equals('completed'))).go();

  Stream<int> watchPendingCount() =>
      (selectOnly(syncQueue)
        ..addColumns([syncQueue.id.count()])
        ..where(syncQueue.status.isIn(['pending', 'failed'])))
      .map((r) => r.read(syncQueue.id.count()) ?? 0)
      .watchSingle();
}

@DriftAccessor(tables: [Students])
class StudentsDao extends DatabaseAccessor<AppDatabase>
    with _$StudentsDaoMixin {
  StudentsDao(super.db);

  Stream<List<StudentRow>> watchAll() =>
      (select(students)
        ..where((t) => t.isDeleted.equals(false))
        ..orderBy([(t) => OrderingTerm.asc(t.name)]))
      .watch();

  Stream<StudentRow?> watchById(int id) =>
      (select(students)..where((t) => t.id.equals(id))).watchSingleOrNull();

  Future<int> upsert(StudentsCompanion c) =>
      into(students).insertOnConflictUpdate(c);

  Future<void> softDelete(int id) =>
      (update(students)..where((t) => t.id.equals(id)))
          .write(StudentsCompanion(
        isDeleted: const Value(true),
        syncStatus: const Value('pending'),
        updatedAt: Value(DateTime.now()),
      ));
}

@DriftAccessor(tables: [AttendanceRecords])
class AttendanceRecordsDao extends DatabaseAccessor<AppDatabase>
    with _$AttendanceRecordsDaoMixin {
  AttendanceRecordsDao(super.db);

  Stream<List<AttendanceRow>> watchAll() =>
      (select(attendanceRecords)
        ..where((t) => t.isDeleted.equals(false)))
      .watch();

  Stream<AttendanceRow?> watchById(int id) =>
      (select(attendanceRecords)..where((t) => t.id.equals(id)))
          .watchSingleOrNull();

  Stream<List<AttendanceRow>> watchByClass(int classId, String date) =>
      (select(attendanceRecords)
        ..where((t) => t.classId.equals(classId))
        ..where((t) => t.date.equals(date))
        ..where((t) => t.isDeleted.equals(false)))
      .watch();

  Stream<List<AttendanceRow>> watchByStudent(int studentId) =>
      (select(attendanceRecords)
        ..where((t) => t.studentId.equals(studentId))
        ..where((t) => t.isDeleted.equals(false))
        ..orderBy([(t) => OrderingTerm.desc(t.date)]))
      .watch();

  Future<int> upsert(AttendanceRecordsCompanion c) =>
      into(attendanceRecords).insertOnConflictUpdate(c);

  Future<void> softDelete(int id) =>
      (update(attendanceRecords)..where((t) => t.id.equals(id)))
          .write(AttendanceRecordsCompanion(
        isDeleted: const Value(true),
        syncStatus: const Value('pending'),
        updatedAt: Value(DateTime.now()),
      ));
}

@DriftAccessor(tables: [TimetableEntries])
class TimetableEntriesDao extends DatabaseAccessor<AppDatabase>
    with _$TimetableEntriesDaoMixin {
  TimetableEntriesDao(super.db);

  Stream<List<TimetableRow>> watchAll() =>
      (select(timetableEntries)
        ..where((t) => t.isDeleted.equals(false))
        ..orderBy([(t) => OrderingTerm.asc(t.startTime)]))
      .watch();

  Stream<List<TimetableRow>> watchByDay(String day) =>
      (select(timetableEntries)
        ..where((t) => t.day.equals(day))
        ..where((t) => t.isDeleted.equals(false))
        ..orderBy([(t) => OrderingTerm.asc(t.startTime)]))
      .watch();

  Future<int> upsert(TimetableEntriesCompanion c) =>
      into(timetableEntries).insertOnConflictUpdate(c);

  Future<void> softDelete(int id) =>
      (update(timetableEntries)..where((t) => t.id.equals(id)))
          .write(TimetableEntriesCompanion(
        isDeleted: const Value(true),
        syncStatus: const Value('pending'),
        updatedAt: Value(DateTime.now()),
      ));
}

@DriftAccessor(tables: [LmsClasses])
class LmsClassesDao extends DatabaseAccessor<AppDatabase>
    with _$LmsClassesDaoMixin {
  LmsClassesDao(super.db);

  Stream<List<LmsClassRow>> watchAll() =>
      (select(lmsClasses)
        ..where((t) => t.isDeleted.equals(false))
        ..orderBy([(t) => OrderingTerm.asc(t.name)]))
      .watch();

  Stream<LmsClassRow?> watchById(int id) =>
      (select(lmsClasses)..where((t) => t.id.equals(id))).watchSingleOrNull();

  Future<int> upsert(LmsClassesCompanion c) =>
      into(lmsClasses).insertOnConflictUpdate(c);

  Future<void> softDelete(int id) =>
      (update(lmsClasses)..where((t) => t.id.equals(id)))
          .write(LmsClassesCompanion(
        isDeleted: const Value(true),
        syncStatus: const Value('pending'),
        updatedAt: Value(DateTime.now()),
      ));
}

@DriftAccessor(tables: [LmsClassworkItems])
class LmsClassworkItemsDao extends DatabaseAccessor<AppDatabase>
    with _$LmsClassworkItemsDaoMixin {
  LmsClassworkItemsDao(super.db);

  Stream<List<ClassworkRow>> watchAll() =>
      (select(lmsClassworkItems)
        ..where((t) => t.isDeleted.equals(false)))
      .watch();

  Stream<List<ClassworkRow>> watchByClass(int classId) =>
      (select(lmsClassworkItems)
        ..where((t) => t.classId.equals(classId))
        ..where((t) => t.isDeleted.equals(false))
        ..orderBy([(t) => OrderingTerm.asc(t.title)]))
      .watch();

  Stream<ClassworkRow?> watchById(int id) =>
      (select(lmsClassworkItems)..where((t) => t.id.equals(id)))
          .watchSingleOrNull();

  Future<int> upsert(LmsClassworkItemsCompanion c) =>
      into(lmsClassworkItems).insertOnConflictUpdate(c);

  Future<void> softDelete(int id) =>
      (update(lmsClassworkItems)..where((t) => t.id.equals(id)))
          .write(LmsClassworkItemsCompanion(
        isDeleted: const Value(true),
        syncStatus: const Value('pending'),
        updatedAt: Value(DateTime.now()),
      ));
}

// ─── Database ─────────────────────────────────────────────────────────────────

@DriftDatabase(
  tables: [
    SyncQueue,
    Students,
    AttendanceRecords,
    TimetableEntries,
    LmsClasses,
    LmsClassworkItems,
  ],
  daos: [
    SyncQueueDao,
    StudentsDao,
    AttendanceRecordsDao,
    TimetableEntriesDao,
    LmsClassesDao,
    LmsClassworkItemsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(String encryptionKey)
      : super(_openEncryptedConnection(encryptionKey));
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async => await m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(students);
            await m.createTable(attendanceRecords);
            await m.createTable(timetableEntries);
            await m.createTable(lmsClasses);
            await m.createTable(lmsClassworkItems);
          }
        },
      );
}

// ─── Connection ───────────────────────────────────────────────────────────────

LazyDatabase _openEncryptedConnection(String key) {
  return LazyDatabase(() async {
    // Override sqlite3 to use SQLCipher native libraries (Android only; iOS uses CocoaPods)
    open.overrideFor(OperatingSystem.android, openCipherOnAndroid);

    final dbDir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbDir.path, 'teacher_app.sqlite'));

    final db = sqlite3.open(file.path);
    // Set encryption key IMMEDIATELY after opening — before any other PRAGMA
    db.execute("PRAGMA key = '$key'");
    db.execute('PRAGMA journal_mode = WAL');

    return NativeDatabase.opened(db);
  });
}

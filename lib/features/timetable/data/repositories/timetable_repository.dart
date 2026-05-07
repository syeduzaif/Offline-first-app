import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:offline_first_app/core/services/database.dart';
import 'package:offline_first_app/features/timetable/domain/entities/timetable_entry.dart';
import 'package:offline_first_app/features/timetable/domain/repositories/i_timetable_repository.dart';

class TimetableRepository implements ITimetableRepository {
  TimetableRepository({
    required this.timetableEntriesDao,
    required this.syncQueueDao,
  });

  final TimetableEntriesDao timetableEntriesDao;
  final SyncQueueDao syncQueueDao;

  @override
  Stream<List<TimetableEntry>> watchAll() =>
      timetableEntriesDao.watchAll().map((rows) => rows.map(_toDomain).toList());

  @override
  Stream<List<TimetableEntry>> watchEntriesForDay(String day) =>
      timetableEntriesDao
          .watchByDay(day)
          .map((rows) => rows.map(_toDomain).toList());

  @override
  Future<TimetableEntry> createEntry(TimetableEntry entry) async {
    late int newId;
    await timetableEntriesDao.attachedDatabase.transaction(() async {
      newId = await timetableEntriesDao.upsert(TimetableEntriesCompanion.insert(
        className: entry.className,
        subject: entry.subject,
        teacherName: entry.teacherName,
        day: entry.day,
        type: entry.type,
        startTime: Value(entry.startTime),
        endTime: Value(entry.endTime),
        room: Value(entry.room),
        campus: Value(entry.campus),
        syncStatus: const Value('pending'),
        updatedAt: Value(DateTime.now()),
      ));
      await syncQueueDao.enqueue(SyncQueueCompanion.insert(
        entityType: 'timetable',
        entityId: newId,
        operation: 'create',
        payload: jsonEncode(entry.toJson()),
      ));
    });
    return entry.copyWith(id: newId, syncStatus: SyncStatus.pending);
  }

  @override
  Future<void> deleteEntry(int id) async {
    await timetableEntriesDao.attachedDatabase.transaction(() async {
      await timetableEntriesDao.softDelete(id);
      await syncQueueDao.enqueue(SyncQueueCompanion.insert(
        entityType: 'timetable',
        entityId: id,
        operation: 'delete',
        payload: jsonEncode({'id': id}),
      ));
    });
  }

  TimetableEntry _toDomain(TimetableRow row) => TimetableEntry(
        id: row.id,
        className: row.className,
        subject: row.subject,
        teacherName: row.teacherName,
        day: row.day,
        type: row.type,
        startTime: row.startTime,
        endTime: row.endTime,
        room: row.room,
        campus: row.campus,
        syncStatus: SyncStatus.values.firstWhere(
          (s) => s.name == row.syncStatus,
          orElse: () => SyncStatus.synced,
        ),
        updatedAt: row.updatedAt,
        remoteId: row.remoteId,
      );
}

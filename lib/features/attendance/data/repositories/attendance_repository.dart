import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:offline_first_app/core/services/database.dart';
import 'package:offline_first_app/features/attendance/domain/entities/attendance_record.dart';
import 'package:offline_first_app/features/attendance/domain/repositories/i_attendance_repository.dart';

class AttendanceRepository implements IAttendanceRepository {
  AttendanceRepository({
    required this.attendanceRecordsDao,
    required this.syncQueueDao,
  });

  final AttendanceRecordsDao attendanceRecordsDao;
  final SyncQueueDao syncQueueDao;

  @override
  Stream<List<AttendanceRecord>> watchAll() =>
      attendanceRecordsDao.watchAll().map((rows) => rows.map(_toDomain).toList());

  @override
  Stream<List<AttendanceRecord>> watchByClass(int classId, String date) =>
      attendanceRecordsDao
          .watchByClass(classId, date)
          .map((rows) => rows.map(_toDomain).toList());

  @override
  Stream<List<AttendanceRecord>> watchByStudent(int studentId) =>
      attendanceRecordsDao
          .watchByStudent(studentId)
          .map((rows) => rows.map(_toDomain).toList());

  @override
  Future<AttendanceRecord> upsertRecord(AttendanceRecord record) async {
    late int savedId;
    await attendanceRecordsDao.attachedDatabase.transaction(() async {
      final dateStr = record.date.toIso8601String().split('T').first;
      savedId = await attendanceRecordsDao.upsert(AttendanceRecordsCompanion(
        id: record.id != 0 ? Value(record.id) : const Value.absent(),
        studentId: Value(record.studentId),
        classId: Value(record.classId),
        date: Value(dateStr),
        status: Value(record.status),
        notes: Value(record.notes),
        syncStatus: const Value('pending'),
        updatedAt: Value(DateTime.now()),
      ));
      await syncQueueDao.enqueue(SyncQueueCompanion.insert(
        entityType: 'attendance',
        entityId: savedId,
        operation: record.id != 0 ? 'update' : 'create',
        payload: jsonEncode({
          'studentId': record.studentId,
          'classId': record.classId,
          'date': dateStr,
          'status': record.status,
          'notes': record.notes,
        }),
      ));
    });
    return record.copyWith(id: savedId, syncStatus: SyncStatus.pending);
  }

  @override
  Future<void> deleteRecord(int id) async {
    await attendanceRecordsDao.attachedDatabase.transaction(() async {
      await attendanceRecordsDao.softDelete(id);
      await syncQueueDao.enqueue(SyncQueueCompanion.insert(
        entityType: 'attendance',
        entityId: id,
        operation: 'delete',
        payload: jsonEncode({'id': id}),
      ));
    });
  }

  AttendanceRecord _toDomain(AttendanceRow row) => AttendanceRecord(
        id: row.id,
        studentId: row.studentId,
        classId: row.classId,
        date: DateTime.tryParse(row.date) ?? DateTime.now(),
        status: row.status,
        notes: row.notes,
        syncStatus: SyncStatus.values.firstWhere(
          (s) => s.name == row.syncStatus,
          orElse: () => SyncStatus.synced,
        ),
        updatedAt: row.updatedAt,
        remoteId: row.remoteId,
      );
}

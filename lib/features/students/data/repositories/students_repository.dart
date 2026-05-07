import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:offline_first_app/core/services/database.dart';
import 'package:offline_first_app/features/students/domain/entities/student.dart';
import 'package:offline_first_app/features/students/domain/repositories/i_students_repository.dart';

class StudentsRepository implements IStudentsRepository {
  StudentsRepository({
    required this.studentsDao,
    required this.syncQueueDao,
  });

  final StudentsDao studentsDao;
  final SyncQueueDao syncQueueDao;

  @override
  Stream<List<Student>> watchStudents() =>
      studentsDao.watchAll().map((rows) => rows.map(_toDomain).toList());

  @override
  Stream<Student?> watchStudent(int id) =>
      studentsDao.watchById(id).map((row) => row != null ? _toDomain(row) : null);

  @override
  Future<Student> createStudent(Student student) async {
    late int newId;
    await studentsDao.attachedDatabase.transaction(() async {
      newId = await studentsDao.upsert(StudentsCompanion.insert(
        name: student.name,
        email: Value(student.email),
        phone: Value(student.phone),
        grade: Value(student.grade),
        section: Value(student.section),
        branch: Value(student.branch),
        avatarUrl: Value(student.avatarUrl),
        syncStatus: const Value('pending'),
        updatedAt: Value(DateTime.now()),
      ));
      await syncQueueDao.enqueue(SyncQueueCompanion.insert(
        entityType: 'student',
        entityId: newId,
        operation: 'create',
        payload: jsonEncode({
          'name': student.name,
          'email': student.email,
          'phone': student.phone,
          'grade': student.grade,
          'section': student.section,
          'branch': student.branch,
        }),
      ));
    });
    return student.copyWith(id: newId, syncStatus: SyncStatus.pending);
  }

  @override
  Future<Student> updateStudent(Student student) async {
    await studentsDao.attachedDatabase.transaction(() async {
      await studentsDao.upsert(StudentsCompanion(
        id: Value(student.id),
        name: Value(student.name),
        email: Value(student.email),
        phone: Value(student.phone),
        grade: Value(student.grade),
        section: Value(student.section),
        branch: Value(student.branch),
        avatarUrl: Value(student.avatarUrl),
        syncStatus: const Value('pending'),
        updatedAt: Value(DateTime.now()),
      ));
      await syncQueueDao.enqueue(SyncQueueCompanion.insert(
        entityType: 'student',
        entityId: student.id,
        operation: 'update',
        payload: jsonEncode(student.toJson()),
      ));
    });
    return student.copyWith(syncStatus: SyncStatus.pending);
  }

  @override
  Future<void> deleteStudent(int id) async {
    await studentsDao.attachedDatabase.transaction(() async {
      await studentsDao.softDelete(id);
      await syncQueueDao.enqueue(SyncQueueCompanion.insert(
        entityType: 'student',
        entityId: id,
        operation: 'delete',
        payload: jsonEncode({'id': id}),
      ));
    });
  }

  Student _toDomain(StudentRow row) => Student(
        id: row.id,
        name: row.name,
        email: row.email,
        phone: row.phone,
        grade: row.grade,
        section: row.section,
        branch: row.branch,
        avatarUrl: row.avatarUrl,
        syncStatus: SyncStatus.values.firstWhere(
          (s) => s.name == row.syncStatus,
          orElse: () => SyncStatus.synced,
        ),
        updatedAt: row.updatedAt,
        remoteId: row.remoteId,
      );
}

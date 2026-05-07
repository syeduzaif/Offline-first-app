import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:offline_first_app/core/services/database.dart';
import 'package:offline_first_app/features/lms/domain/entities/lms_class.dart';
import 'package:offline_first_app/features/lms/domain/entities/lms_classwork_item.dart';
import 'package:offline_first_app/features/lms/domain/repositories/i_lms_repository.dart';

class LmsRepository implements ILmsRepository {
  LmsRepository({
    required this.lmsClassesDao,
    required this.lmsClassworkItemsDao,
    required this.syncQueueDao,
  });

  final LmsClassesDao lmsClassesDao;
  final LmsClassworkItemsDao lmsClassworkItemsDao;
  final SyncQueueDao syncQueueDao;

  @override
  Stream<List<LmsClass>> watchClasses() =>
      lmsClassesDao.watchAll().map((rows) => rows.map(_toClassDomain).toList());

  @override
  Stream<LmsClass?> watchClass(int id) =>
      lmsClassesDao.watchById(id).map((row) => row != null ? _toClassDomain(row) : null);

  @override
  Stream<List<LmsClassworkItem>> watchClassworkForClass(int classId) =>
      lmsClassworkItemsDao
          .watchByClass(classId)
          .map((rows) => rows.map(_toClassworkDomain).toList());

  @override
  Stream<LmsClassworkItem?> watchClassworkItem(int id) =>
      lmsClassworkItemsDao
          .watchById(id)
          .map((row) => row != null ? _toClassworkDomain(row) : null);

  @override
  Future<LmsClass> createClass(LmsClass lmsClass) async {
    late int newId;
    await lmsClassesDao.attachedDatabase.transaction(() async {
      newId = await lmsClassesDao.upsert(LmsClassesCompanion.insert(
        name: lmsClass.name,
        campus: Value(lmsClass.campus),
        grade: Value(lmsClass.grade),
        section: Value(lmsClass.section),
        subject: Value(lmsClass.subject),
        teacherName: Value(lmsClass.teacherName),
        studentCount: Value(lmsClass.studentCount),
        syncStatus: const Value('pending'),
        updatedAt: Value(DateTime.now()),
      ));
      await syncQueueDao.enqueue(SyncQueueCompanion.insert(
        entityType: 'lmsClass',
        entityId: newId,
        operation: 'create',
        payload: jsonEncode(lmsClass.toJson()),
      ));
    });
    return lmsClass.copyWith(id: newId, syncStatus: SyncStatus.pending);
  }

  @override
  Future<LmsClassworkItem> updateClassworkItem(LmsClassworkItem item) async {
    await lmsClassworkItemsDao.attachedDatabase.transaction(() async {
      await lmsClassworkItemsDao.upsert(LmsClassworkItemsCompanion(
        id: Value(item.id),
        classId: Value(item.classId),
        title: Value(item.title),
        type: Value(item.type),
        topic: Value(item.topic),
        status: Value(item.status),
        totalPoints: Value(item.totalPoints),
        submittedCount: Value(item.submittedCount),
        gradedCount: Value(item.gradedCount),
        totalCount: Value(item.totalCount),
        dueDate: Value(item.dueDate?.toIso8601String()),
        syncStatus: const Value('pending'),
        updatedAt: Value(DateTime.now()),
      ));
      await syncQueueDao.enqueue(SyncQueueCompanion.insert(
        entityType: 'classwork',
        entityId: item.id,
        operation: 'update',
        payload: jsonEncode(item.toJson()),
      ));
    });
    return item.copyWith(syncStatus: SyncStatus.pending);
  }

  LmsClass _toClassDomain(LmsClassRow row) => LmsClass(
        id: row.id,
        name: row.name,
        campus: row.campus,
        grade: row.grade,
        section: row.section,
        subject: row.subject,
        teacherName: row.teacherName,
        studentCount: row.studentCount,
        syncStatus: SyncStatus.values.firstWhere(
          (s) => s.name == row.syncStatus,
          orElse: () => SyncStatus.synced,
        ),
        updatedAt: row.updatedAt,
        remoteId: row.remoteId,
      );

  LmsClassworkItem _toClassworkDomain(ClassworkRow row) => LmsClassworkItem(
        id: row.id,
        classId: row.classId,
        title: row.title,
        type: row.type,
        topic: row.topic,
        status: row.status,
        totalPoints: row.totalPoints,
        submittedCount: row.submittedCount,
        gradedCount: row.gradedCount,
        totalCount: row.totalCount,
        dueDate: row.dueDate != null ? DateTime.tryParse(row.dueDate!) : null,
        syncStatus: SyncStatus.values.firstWhere(
          (s) => s.name == row.syncStatus,
          orElse: () => SyncStatus.synced,
        ),
        updatedAt: row.updatedAt,
        remoteId: row.remoteId,
      );
}

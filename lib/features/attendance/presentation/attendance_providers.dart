import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_first_app/core/providers/providers.dart';
import 'package:offline_first_app/core/services/database.dart';
import 'package:offline_first_app/features/attendance/data/repositories/attendance_repository.dart';
import 'package:offline_first_app/features/attendance/domain/entities/attendance_record.dart';
import 'package:offline_first_app/features/lms/domain/entities/lms_class.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'attendance_providers.g.dart';

@Riverpod(keepAlive: true)
AttendanceRecordsDao attendanceRecordsDao(Ref ref) =>
    ref.watch(appDatabaseProvider).attendanceRecordsDao;

@Riverpod(keepAlive: true)
AttendanceRepository attendanceRepository(Ref ref) => AttendanceRepository(
      attendanceRecordsDao: ref.watch(attendanceRecordsDaoProvider),
      syncQueueDao: ref.watch(appDatabaseProvider).syncQueueDao,
    );

@riverpod
Stream<List<AttendanceRecord>> attendanceForClass(
  Ref ref,
  int classId,
  String date,
) =>
    ref.watch(attendanceRepositoryProvider).watchByClass(classId, date);

@riverpod
Stream<List<AttendanceRecord>> attendanceForStudent(Ref ref, int studentId) =>
    ref.watch(attendanceRepositoryProvider).watchByStudent(studentId);

// Selected class for attendance marking
final attendanceSelectedClassProvider = StateProvider<LmsClass?>((ref) => null);

// Selected date
final attendanceDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

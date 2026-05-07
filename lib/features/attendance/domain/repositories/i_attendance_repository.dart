import 'package:offline_first_app/features/attendance/domain/entities/attendance_record.dart';

abstract interface class IAttendanceRepository {
  Stream<List<AttendanceRecord>> watchAll();
  Stream<List<AttendanceRecord>> watchByClass(int classId, String date);
  Stream<List<AttendanceRecord>> watchByStudent(int studentId);
  Future<AttendanceRecord> upsertRecord(AttendanceRecord record);
  Future<void> deleteRecord(int id);
}

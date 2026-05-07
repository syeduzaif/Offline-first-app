import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:offline_first_app/core/services/database.dart';

part 'attendance_record.freezed.dart';
part 'attendance_record.g.dart';

@freezed
abstract class AttendanceRecord with _$AttendanceRecord {
  const factory AttendanceRecord({
    required int id,
    required int studentId,
    required int classId,
    required DateTime date,
    required String status, // 'present' | 'absent' | 'late'
    @Default('') String notes,
    @Default(SyncStatus.synced) SyncStatus syncStatus,
    DateTime? updatedAt,
    int? remoteId,
  }) = _AttendanceRecord;

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) =>
      _$AttendanceRecordFromJson(json);
}

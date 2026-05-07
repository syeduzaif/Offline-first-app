import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:offline_first_app/core/services/database.dart';

part 'timetable_entry.freezed.dart';
part 'timetable_entry.g.dart';

@freezed
abstract class TimetableEntry with _$TimetableEntry {
  const factory TimetableEntry({
    required int id,
    required String className,
    required String subject,
    required String teacherName,
    required String day, // 'Mon' | 'Tue' | 'Wed' | 'Thu' | 'Fri'
    required String type, // 'lesson' | 'break' | 'free'
    @Default('') String startTime,
    @Default('') String endTime,
    @Default('') String room,
    @Default('') String campus,
    @Default(SyncStatus.synced) SyncStatus syncStatus,
    DateTime? updatedAt,
    int? remoteId,
  }) = _TimetableEntry;

  factory TimetableEntry.fromJson(Map<String, dynamic> json) =>
      _$TimetableEntryFromJson(json);
}

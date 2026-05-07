import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:offline_first_app/core/services/database.dart';

part 'lms_class.freezed.dart';
part 'lms_class.g.dart';

@freezed
abstract class LmsClass with _$LmsClass {
  const factory LmsClass({
    required int id,
    required String name,
    @Default('') String campus,
    @Default('') String grade,
    @Default('') String section,
    @Default('') String subject,
    @Default('') String teacherName,
    @Default(0) int studentCount,
    @Default(SyncStatus.synced) SyncStatus syncStatus,
    DateTime? updatedAt,
    int? remoteId,
  }) = _LmsClass;

  factory LmsClass.fromJson(Map<String, dynamic> json) =>
      _$LmsClassFromJson(json);
}

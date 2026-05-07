import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:offline_first_app/core/services/database.dart';

part 'student.freezed.dart';
part 'student.g.dart';

@freezed
abstract class Student with _$Student {
  const factory Student({
    required int id,
    required String name,
    @Default('') String email,
    @Default('') String phone,
    @Default('') String grade,
    @Default('') String section,
    @Default('') String branch,
    @Default('') String avatarUrl,
    @Default(SyncStatus.synced) SyncStatus syncStatus,
    DateTime? updatedAt,
    int? remoteId,
  }) = _Student;

  factory Student.fromJson(Map<String, dynamic> json) => _$StudentFromJson(json);
}

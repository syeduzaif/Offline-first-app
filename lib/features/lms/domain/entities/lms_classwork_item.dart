import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:offline_first_app/core/services/database.dart';

part 'lms_classwork_item.freezed.dart';
part 'lms_classwork_item.g.dart';

@freezed
abstract class LmsClassworkItem with _$LmsClassworkItem {
  const factory LmsClassworkItem({
    required int id,
    required int classId,
    required String title,
    required String type, // 'assignment' | 'material'
    @Default('') String topic,
    @Default('') String status,
    @Default(0) int totalPoints,
    @Default(0) int submittedCount,
    @Default(0) int gradedCount,
    @Default(0) int totalCount,
    DateTime? dueDate,
    @Default(SyncStatus.synced) SyncStatus syncStatus,
    DateTime? updatedAt,
    int? remoteId,
  }) = _LmsClassworkItem;

  factory LmsClassworkItem.fromJson(Map<String, dynamic> json) =>
      _$LmsClassworkItemFromJson(json);
}

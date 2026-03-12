import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_operation.freezed.dart';
part 'sync_operation.g.dart';

enum SyncOperationType { create, update, delete }

enum SyncOperationStatus { pending, inProgress, failed, completed }

@freezed
abstract class SyncOperation with _$SyncOperation {
  const factory SyncOperation({
    required int id,
    required SyncOperationType operation,
    required String entityType,
    required int entityId,
    required String payload,
    @Default(SyncOperationStatus.pending) SyncOperationStatus status,
    @Default(0) int retryCount,
    required DateTime createdAt,
    DateTime? lastAttemptAt,
    String? errorMessage,
  }) = _SyncOperation;

  factory SyncOperation.fromJson(Map<String, dynamic> json) =>
      _$SyncOperationFromJson(json);
}

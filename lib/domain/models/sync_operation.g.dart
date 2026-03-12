// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_operation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SyncOperation _$SyncOperationFromJson(Map<String, dynamic> json) =>
    _SyncOperation(
      id: (json['id'] as num).toInt(),
      operation: $enumDecode(_$SyncOperationTypeEnumMap, json['operation']),
      entityType: json['entityType'] as String,
      entityId: (json['entityId'] as num).toInt(),
      payload: json['payload'] as String,
      status:
          $enumDecodeNullable(_$SyncOperationStatusEnumMap, json['status']) ??
          SyncOperationStatus.pending,
      retryCount: (json['retryCount'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastAttemptAt: json['lastAttemptAt'] == null
          ? null
          : DateTime.parse(json['lastAttemptAt'] as String),
      errorMessage: json['errorMessage'] as String?,
    );

Map<String, dynamic> _$SyncOperationToJson(_SyncOperation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'operation': _$SyncOperationTypeEnumMap[instance.operation]!,
      'entityType': instance.entityType,
      'entityId': instance.entityId,
      'payload': instance.payload,
      'status': _$SyncOperationStatusEnumMap[instance.status]!,
      'retryCount': instance.retryCount,
      'createdAt': instance.createdAt.toIso8601String(),
      'lastAttemptAt': instance.lastAttemptAt?.toIso8601String(),
      'errorMessage': instance.errorMessage,
    };

const _$SyncOperationTypeEnumMap = {
  SyncOperationType.create: 'create',
  SyncOperationType.update: 'update',
  SyncOperationType.delete: 'delete',
};

const _$SyncOperationStatusEnumMap = {
  SyncOperationStatus.pending: 'pending',
  SyncOperationStatus.inProgress: 'inProgress',
  SyncOperationStatus.failed: 'failed',
  SyncOperationStatus.completed: 'completed',
};

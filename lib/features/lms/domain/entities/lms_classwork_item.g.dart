// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lms_classwork_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LmsClassworkItem _$LmsClassworkItemFromJson(Map<String, dynamic> json) =>
    _LmsClassworkItem(
      id: (json['id'] as num).toInt(),
      classId: (json['classId'] as num).toInt(),
      title: json['title'] as String,
      type: json['type'] as String,
      topic: json['topic'] as String? ?? '',
      status: json['status'] as String? ?? '',
      totalPoints: (json['totalPoints'] as num?)?.toInt() ?? 0,
      submittedCount: (json['submittedCount'] as num?)?.toInt() ?? 0,
      gradedCount: (json['gradedCount'] as num?)?.toInt() ?? 0,
      totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
      dueDate: json['dueDate'] == null
          ? null
          : DateTime.parse(json['dueDate'] as String),
      syncStatus:
          $enumDecodeNullable(_$SyncStatusEnumMap, json['syncStatus']) ??
          SyncStatus.synced,
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      remoteId: (json['remoteId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$LmsClassworkItemToJson(_LmsClassworkItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'classId': instance.classId,
      'title': instance.title,
      'type': instance.type,
      'topic': instance.topic,
      'status': instance.status,
      'totalPoints': instance.totalPoints,
      'submittedCount': instance.submittedCount,
      'gradedCount': instance.gradedCount,
      'totalCount': instance.totalCount,
      'dueDate': instance.dueDate?.toIso8601String(),
      'syncStatus': _$SyncStatusEnumMap[instance.syncStatus]!,
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'remoteId': instance.remoteId,
    };

const _$SyncStatusEnumMap = {
  SyncStatus.synced: 'synced',
  SyncStatus.pending: 'pending',
  SyncStatus.inProgress: 'inProgress',
  SyncStatus.failed: 'failed',
};

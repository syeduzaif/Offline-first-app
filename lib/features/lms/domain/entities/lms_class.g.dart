// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lms_class.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LmsClass _$LmsClassFromJson(Map<String, dynamic> json) => _LmsClass(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  campus: json['campus'] as String? ?? '',
  grade: json['grade'] as String? ?? '',
  section: json['section'] as String? ?? '',
  subject: json['subject'] as String? ?? '',
  teacherName: json['teacherName'] as String? ?? '',
  studentCount: (json['studentCount'] as num?)?.toInt() ?? 0,
  syncStatus:
      $enumDecodeNullable(_$SyncStatusEnumMap, json['syncStatus']) ??
      SyncStatus.synced,
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  remoteId: (json['remoteId'] as num?)?.toInt(),
);

Map<String, dynamic> _$LmsClassToJson(_LmsClass instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'campus': instance.campus,
  'grade': instance.grade,
  'section': instance.section,
  'subject': instance.subject,
  'teacherName': instance.teacherName,
  'studentCount': instance.studentCount,
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

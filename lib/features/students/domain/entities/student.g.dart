// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Student _$StudentFromJson(Map<String, dynamic> json) => _Student(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  email: json['email'] as String? ?? '',
  phone: json['phone'] as String? ?? '',
  grade: json['grade'] as String? ?? '',
  section: json['section'] as String? ?? '',
  branch: json['branch'] as String? ?? '',
  avatarUrl: json['avatarUrl'] as String? ?? '',
  syncStatus:
      $enumDecodeNullable(_$SyncStatusEnumMap, json['syncStatus']) ??
      SyncStatus.synced,
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  remoteId: (json['remoteId'] as num?)?.toInt(),
);

Map<String, dynamic> _$StudentToJson(_Student instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'phone': instance.phone,
  'grade': instance.grade,
  'section': instance.section,
  'branch': instance.branch,
  'avatarUrl': instance.avatarUrl,
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

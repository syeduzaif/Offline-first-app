// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AttendanceRecord _$AttendanceRecordFromJson(Map<String, dynamic> json) =>
    _AttendanceRecord(
      id: (json['id'] as num).toInt(),
      studentId: (json['studentId'] as num).toInt(),
      classId: (json['classId'] as num).toInt(),
      date: DateTime.parse(json['date'] as String),
      status: json['status'] as String,
      notes: json['notes'] as String? ?? '',
      syncStatus:
          $enumDecodeNullable(_$SyncStatusEnumMap, json['syncStatus']) ??
          SyncStatus.synced,
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      remoteId: (json['remoteId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$AttendanceRecordToJson(_AttendanceRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'studentId': instance.studentId,
      'classId': instance.classId,
      'date': instance.date.toIso8601String(),
      'status': instance.status,
      'notes': instance.notes,
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

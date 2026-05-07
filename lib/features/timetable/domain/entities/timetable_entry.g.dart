// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timetable_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TimetableEntry _$TimetableEntryFromJson(Map<String, dynamic> json) =>
    _TimetableEntry(
      id: (json['id'] as num).toInt(),
      className: json['className'] as String,
      subject: json['subject'] as String,
      teacherName: json['teacherName'] as String,
      day: json['day'] as String,
      type: json['type'] as String,
      startTime: json['startTime'] as String? ?? '',
      endTime: json['endTime'] as String? ?? '',
      room: json['room'] as String? ?? '',
      campus: json['campus'] as String? ?? '',
      syncStatus:
          $enumDecodeNullable(_$SyncStatusEnumMap, json['syncStatus']) ??
          SyncStatus.synced,
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      remoteId: (json['remoteId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$TimetableEntryToJson(_TimetableEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'className': instance.className,
      'subject': instance.subject,
      'teacherName': instance.teacherName,
      'day': instance.day,
      'type': instance.type,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'room': instance.room,
      'campus': instance.campus,
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

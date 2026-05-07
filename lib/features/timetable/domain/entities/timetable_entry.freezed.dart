// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'timetable_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TimetableEntry {

 int get id; String get className; String get subject; String get teacherName; String get day;// 'Mon' | 'Tue' | 'Wed' | 'Thu' | 'Fri'
 String get type;// 'lesson' | 'break' | 'free'
 String get startTime; String get endTime; String get room; String get campus; SyncStatus get syncStatus; DateTime? get updatedAt; int? get remoteId;
/// Create a copy of TimetableEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TimetableEntryCopyWith<TimetableEntry> get copyWith => _$TimetableEntryCopyWithImpl<TimetableEntry>(this as TimetableEntry, _$identity);

  /// Serializes this TimetableEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimetableEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.className, className) || other.className == className)&&(identical(other.subject, subject) || other.subject == subject)&&(identical(other.teacherName, teacherName) || other.teacherName == teacherName)&&(identical(other.day, day) || other.day == day)&&(identical(other.type, type) || other.type == type)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.room, room) || other.room == room)&&(identical(other.campus, campus) || other.campus == campus)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.remoteId, remoteId) || other.remoteId == remoteId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,className,subject,teacherName,day,type,startTime,endTime,room,campus,syncStatus,updatedAt,remoteId);

@override
String toString() {
  return 'TimetableEntry(id: $id, className: $className, subject: $subject, teacherName: $teacherName, day: $day, type: $type, startTime: $startTime, endTime: $endTime, room: $room, campus: $campus, syncStatus: $syncStatus, updatedAt: $updatedAt, remoteId: $remoteId)';
}


}

/// @nodoc
abstract mixin class $TimetableEntryCopyWith<$Res>  {
  factory $TimetableEntryCopyWith(TimetableEntry value, $Res Function(TimetableEntry) _then) = _$TimetableEntryCopyWithImpl;
@useResult
$Res call({
 int id, String className, String subject, String teacherName, String day, String type, String startTime, String endTime, String room, String campus, SyncStatus syncStatus, DateTime? updatedAt, int? remoteId
});




}
/// @nodoc
class _$TimetableEntryCopyWithImpl<$Res>
    implements $TimetableEntryCopyWith<$Res> {
  _$TimetableEntryCopyWithImpl(this._self, this._then);

  final TimetableEntry _self;
  final $Res Function(TimetableEntry) _then;

/// Create a copy of TimetableEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? className = null,Object? subject = null,Object? teacherName = null,Object? day = null,Object? type = null,Object? startTime = null,Object? endTime = null,Object? room = null,Object? campus = null,Object? syncStatus = null,Object? updatedAt = freezed,Object? remoteId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,className: null == className ? _self.className : className // ignore: cast_nullable_to_non_nullable
as String,subject: null == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String,teacherName: null == teacherName ? _self.teacherName : teacherName // ignore: cast_nullable_to_non_nullable
as String,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as String,room: null == room ? _self.room : room // ignore: cast_nullable_to_non_nullable
as String,campus: null == campus ? _self.campus : campus // ignore: cast_nullable_to_non_nullable
as String,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as SyncStatus,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,remoteId: freezed == remoteId ? _self.remoteId : remoteId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [TimetableEntry].
extension TimetableEntryPatterns on TimetableEntry {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TimetableEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TimetableEntry() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TimetableEntry value)  $default,){
final _that = this;
switch (_that) {
case _TimetableEntry():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TimetableEntry value)?  $default,){
final _that = this;
switch (_that) {
case _TimetableEntry() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String className,  String subject,  String teacherName,  String day,  String type,  String startTime,  String endTime,  String room,  String campus,  SyncStatus syncStatus,  DateTime? updatedAt,  int? remoteId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TimetableEntry() when $default != null:
return $default(_that.id,_that.className,_that.subject,_that.teacherName,_that.day,_that.type,_that.startTime,_that.endTime,_that.room,_that.campus,_that.syncStatus,_that.updatedAt,_that.remoteId);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String className,  String subject,  String teacherName,  String day,  String type,  String startTime,  String endTime,  String room,  String campus,  SyncStatus syncStatus,  DateTime? updatedAt,  int? remoteId)  $default,) {final _that = this;
switch (_that) {
case _TimetableEntry():
return $default(_that.id,_that.className,_that.subject,_that.teacherName,_that.day,_that.type,_that.startTime,_that.endTime,_that.room,_that.campus,_that.syncStatus,_that.updatedAt,_that.remoteId);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String className,  String subject,  String teacherName,  String day,  String type,  String startTime,  String endTime,  String room,  String campus,  SyncStatus syncStatus,  DateTime? updatedAt,  int? remoteId)?  $default,) {final _that = this;
switch (_that) {
case _TimetableEntry() when $default != null:
return $default(_that.id,_that.className,_that.subject,_that.teacherName,_that.day,_that.type,_that.startTime,_that.endTime,_that.room,_that.campus,_that.syncStatus,_that.updatedAt,_that.remoteId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TimetableEntry implements TimetableEntry {
  const _TimetableEntry({required this.id, required this.className, required this.subject, required this.teacherName, required this.day, required this.type, this.startTime = '', this.endTime = '', this.room = '', this.campus = '', this.syncStatus = SyncStatus.synced, this.updatedAt, this.remoteId});
  factory _TimetableEntry.fromJson(Map<String, dynamic> json) => _$TimetableEntryFromJson(json);

@override final  int id;
@override final  String className;
@override final  String subject;
@override final  String teacherName;
@override final  String day;
// 'Mon' | 'Tue' | 'Wed' | 'Thu' | 'Fri'
@override final  String type;
// 'lesson' | 'break' | 'free'
@override@JsonKey() final  String startTime;
@override@JsonKey() final  String endTime;
@override@JsonKey() final  String room;
@override@JsonKey() final  String campus;
@override@JsonKey() final  SyncStatus syncStatus;
@override final  DateTime? updatedAt;
@override final  int? remoteId;

/// Create a copy of TimetableEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TimetableEntryCopyWith<_TimetableEntry> get copyWith => __$TimetableEntryCopyWithImpl<_TimetableEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TimetableEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TimetableEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.className, className) || other.className == className)&&(identical(other.subject, subject) || other.subject == subject)&&(identical(other.teacherName, teacherName) || other.teacherName == teacherName)&&(identical(other.day, day) || other.day == day)&&(identical(other.type, type) || other.type == type)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.room, room) || other.room == room)&&(identical(other.campus, campus) || other.campus == campus)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.remoteId, remoteId) || other.remoteId == remoteId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,className,subject,teacherName,day,type,startTime,endTime,room,campus,syncStatus,updatedAt,remoteId);

@override
String toString() {
  return 'TimetableEntry(id: $id, className: $className, subject: $subject, teacherName: $teacherName, day: $day, type: $type, startTime: $startTime, endTime: $endTime, room: $room, campus: $campus, syncStatus: $syncStatus, updatedAt: $updatedAt, remoteId: $remoteId)';
}


}

/// @nodoc
abstract mixin class _$TimetableEntryCopyWith<$Res> implements $TimetableEntryCopyWith<$Res> {
  factory _$TimetableEntryCopyWith(_TimetableEntry value, $Res Function(_TimetableEntry) _then) = __$TimetableEntryCopyWithImpl;
@override @useResult
$Res call({
 int id, String className, String subject, String teacherName, String day, String type, String startTime, String endTime, String room, String campus, SyncStatus syncStatus, DateTime? updatedAt, int? remoteId
});




}
/// @nodoc
class __$TimetableEntryCopyWithImpl<$Res>
    implements _$TimetableEntryCopyWith<$Res> {
  __$TimetableEntryCopyWithImpl(this._self, this._then);

  final _TimetableEntry _self;
  final $Res Function(_TimetableEntry) _then;

/// Create a copy of TimetableEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? className = null,Object? subject = null,Object? teacherName = null,Object? day = null,Object? type = null,Object? startTime = null,Object? endTime = null,Object? room = null,Object? campus = null,Object? syncStatus = null,Object? updatedAt = freezed,Object? remoteId = freezed,}) {
  return _then(_TimetableEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,className: null == className ? _self.className : className // ignore: cast_nullable_to_non_nullable
as String,subject: null == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String,teacherName: null == teacherName ? _self.teacherName : teacherName // ignore: cast_nullable_to_non_nullable
as String,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as String,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as String,room: null == room ? _self.room : room // ignore: cast_nullable_to_non_nullable
as String,campus: null == campus ? _self.campus : campus // ignore: cast_nullable_to_non_nullable
as String,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as SyncStatus,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,remoteId: freezed == remoteId ? _self.remoteId : remoteId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on

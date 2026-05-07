// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lms_class.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LmsClass {

 int get id; String get name; String get campus; String get grade; String get section; String get subject; String get teacherName; int get studentCount; SyncStatus get syncStatus; DateTime? get updatedAt; int? get remoteId;
/// Create a copy of LmsClass
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LmsClassCopyWith<LmsClass> get copyWith => _$LmsClassCopyWithImpl<LmsClass>(this as LmsClass, _$identity);

  /// Serializes this LmsClass to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LmsClass&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.campus, campus) || other.campus == campus)&&(identical(other.grade, grade) || other.grade == grade)&&(identical(other.section, section) || other.section == section)&&(identical(other.subject, subject) || other.subject == subject)&&(identical(other.teacherName, teacherName) || other.teacherName == teacherName)&&(identical(other.studentCount, studentCount) || other.studentCount == studentCount)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.remoteId, remoteId) || other.remoteId == remoteId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,campus,grade,section,subject,teacherName,studentCount,syncStatus,updatedAt,remoteId);

@override
String toString() {
  return 'LmsClass(id: $id, name: $name, campus: $campus, grade: $grade, section: $section, subject: $subject, teacherName: $teacherName, studentCount: $studentCount, syncStatus: $syncStatus, updatedAt: $updatedAt, remoteId: $remoteId)';
}


}

/// @nodoc
abstract mixin class $LmsClassCopyWith<$Res>  {
  factory $LmsClassCopyWith(LmsClass value, $Res Function(LmsClass) _then) = _$LmsClassCopyWithImpl;
@useResult
$Res call({
 int id, String name, String campus, String grade, String section, String subject, String teacherName, int studentCount, SyncStatus syncStatus, DateTime? updatedAt, int? remoteId
});




}
/// @nodoc
class _$LmsClassCopyWithImpl<$Res>
    implements $LmsClassCopyWith<$Res> {
  _$LmsClassCopyWithImpl(this._self, this._then);

  final LmsClass _self;
  final $Res Function(LmsClass) _then;

/// Create a copy of LmsClass
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? campus = null,Object? grade = null,Object? section = null,Object? subject = null,Object? teacherName = null,Object? studentCount = null,Object? syncStatus = null,Object? updatedAt = freezed,Object? remoteId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,campus: null == campus ? _self.campus : campus // ignore: cast_nullable_to_non_nullable
as String,grade: null == grade ? _self.grade : grade // ignore: cast_nullable_to_non_nullable
as String,section: null == section ? _self.section : section // ignore: cast_nullable_to_non_nullable
as String,subject: null == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String,teacherName: null == teacherName ? _self.teacherName : teacherName // ignore: cast_nullable_to_non_nullable
as String,studentCount: null == studentCount ? _self.studentCount : studentCount // ignore: cast_nullable_to_non_nullable
as int,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as SyncStatus,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,remoteId: freezed == remoteId ? _self.remoteId : remoteId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [LmsClass].
extension LmsClassPatterns on LmsClass {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LmsClass value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LmsClass() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LmsClass value)  $default,){
final _that = this;
switch (_that) {
case _LmsClass():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LmsClass value)?  $default,){
final _that = this;
switch (_that) {
case _LmsClass() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String campus,  String grade,  String section,  String subject,  String teacherName,  int studentCount,  SyncStatus syncStatus,  DateTime? updatedAt,  int? remoteId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LmsClass() when $default != null:
return $default(_that.id,_that.name,_that.campus,_that.grade,_that.section,_that.subject,_that.teacherName,_that.studentCount,_that.syncStatus,_that.updatedAt,_that.remoteId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String campus,  String grade,  String section,  String subject,  String teacherName,  int studentCount,  SyncStatus syncStatus,  DateTime? updatedAt,  int? remoteId)  $default,) {final _that = this;
switch (_that) {
case _LmsClass():
return $default(_that.id,_that.name,_that.campus,_that.grade,_that.section,_that.subject,_that.teacherName,_that.studentCount,_that.syncStatus,_that.updatedAt,_that.remoteId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String campus,  String grade,  String section,  String subject,  String teacherName,  int studentCount,  SyncStatus syncStatus,  DateTime? updatedAt,  int? remoteId)?  $default,) {final _that = this;
switch (_that) {
case _LmsClass() when $default != null:
return $default(_that.id,_that.name,_that.campus,_that.grade,_that.section,_that.subject,_that.teacherName,_that.studentCount,_that.syncStatus,_that.updatedAt,_that.remoteId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LmsClass implements LmsClass {
  const _LmsClass({required this.id, required this.name, this.campus = '', this.grade = '', this.section = '', this.subject = '', this.teacherName = '', this.studentCount = 0, this.syncStatus = SyncStatus.synced, this.updatedAt, this.remoteId});
  factory _LmsClass.fromJson(Map<String, dynamic> json) => _$LmsClassFromJson(json);

@override final  int id;
@override final  String name;
@override@JsonKey() final  String campus;
@override@JsonKey() final  String grade;
@override@JsonKey() final  String section;
@override@JsonKey() final  String subject;
@override@JsonKey() final  String teacherName;
@override@JsonKey() final  int studentCount;
@override@JsonKey() final  SyncStatus syncStatus;
@override final  DateTime? updatedAt;
@override final  int? remoteId;

/// Create a copy of LmsClass
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LmsClassCopyWith<_LmsClass> get copyWith => __$LmsClassCopyWithImpl<_LmsClass>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LmsClassToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LmsClass&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.campus, campus) || other.campus == campus)&&(identical(other.grade, grade) || other.grade == grade)&&(identical(other.section, section) || other.section == section)&&(identical(other.subject, subject) || other.subject == subject)&&(identical(other.teacherName, teacherName) || other.teacherName == teacherName)&&(identical(other.studentCount, studentCount) || other.studentCount == studentCount)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.remoteId, remoteId) || other.remoteId == remoteId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,campus,grade,section,subject,teacherName,studentCount,syncStatus,updatedAt,remoteId);

@override
String toString() {
  return 'LmsClass(id: $id, name: $name, campus: $campus, grade: $grade, section: $section, subject: $subject, teacherName: $teacherName, studentCount: $studentCount, syncStatus: $syncStatus, updatedAt: $updatedAt, remoteId: $remoteId)';
}


}

/// @nodoc
abstract mixin class _$LmsClassCopyWith<$Res> implements $LmsClassCopyWith<$Res> {
  factory _$LmsClassCopyWith(_LmsClass value, $Res Function(_LmsClass) _then) = __$LmsClassCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String campus, String grade, String section, String subject, String teacherName, int studentCount, SyncStatus syncStatus, DateTime? updatedAt, int? remoteId
});




}
/// @nodoc
class __$LmsClassCopyWithImpl<$Res>
    implements _$LmsClassCopyWith<$Res> {
  __$LmsClassCopyWithImpl(this._self, this._then);

  final _LmsClass _self;
  final $Res Function(_LmsClass) _then;

/// Create a copy of LmsClass
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? campus = null,Object? grade = null,Object? section = null,Object? subject = null,Object? teacherName = null,Object? studentCount = null,Object? syncStatus = null,Object? updatedAt = freezed,Object? remoteId = freezed,}) {
  return _then(_LmsClass(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,campus: null == campus ? _self.campus : campus // ignore: cast_nullable_to_non_nullable
as String,grade: null == grade ? _self.grade : grade // ignore: cast_nullable_to_non_nullable
as String,section: null == section ? _self.section : section // ignore: cast_nullable_to_non_nullable
as String,subject: null == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String,teacherName: null == teacherName ? _self.teacherName : teacherName // ignore: cast_nullable_to_non_nullable
as String,studentCount: null == studentCount ? _self.studentCount : studentCount // ignore: cast_nullable_to_non_nullable
as int,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as SyncStatus,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,remoteId: freezed == remoteId ? _self.remoteId : remoteId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on

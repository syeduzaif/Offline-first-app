// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lms_classwork_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LmsClassworkItem {

 int get id; int get classId; String get title; String get type;// 'assignment' | 'material'
 String get topic; String get status; int get totalPoints; int get submittedCount; int get gradedCount; int get totalCount; DateTime? get dueDate; SyncStatus get syncStatus; DateTime? get updatedAt; int? get remoteId;
/// Create a copy of LmsClassworkItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LmsClassworkItemCopyWith<LmsClassworkItem> get copyWith => _$LmsClassworkItemCopyWithImpl<LmsClassworkItem>(this as LmsClassworkItem, _$identity);

  /// Serializes this LmsClassworkItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LmsClassworkItem&&(identical(other.id, id) || other.id == id)&&(identical(other.classId, classId) || other.classId == classId)&&(identical(other.title, title) || other.title == title)&&(identical(other.type, type) || other.type == type)&&(identical(other.topic, topic) || other.topic == topic)&&(identical(other.status, status) || other.status == status)&&(identical(other.totalPoints, totalPoints) || other.totalPoints == totalPoints)&&(identical(other.submittedCount, submittedCount) || other.submittedCount == submittedCount)&&(identical(other.gradedCount, gradedCount) || other.gradedCount == gradedCount)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.remoteId, remoteId) || other.remoteId == remoteId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,classId,title,type,topic,status,totalPoints,submittedCount,gradedCount,totalCount,dueDate,syncStatus,updatedAt,remoteId);

@override
String toString() {
  return 'LmsClassworkItem(id: $id, classId: $classId, title: $title, type: $type, topic: $topic, status: $status, totalPoints: $totalPoints, submittedCount: $submittedCount, gradedCount: $gradedCount, totalCount: $totalCount, dueDate: $dueDate, syncStatus: $syncStatus, updatedAt: $updatedAt, remoteId: $remoteId)';
}


}

/// @nodoc
abstract mixin class $LmsClassworkItemCopyWith<$Res>  {
  factory $LmsClassworkItemCopyWith(LmsClassworkItem value, $Res Function(LmsClassworkItem) _then) = _$LmsClassworkItemCopyWithImpl;
@useResult
$Res call({
 int id, int classId, String title, String type, String topic, String status, int totalPoints, int submittedCount, int gradedCount, int totalCount, DateTime? dueDate, SyncStatus syncStatus, DateTime? updatedAt, int? remoteId
});




}
/// @nodoc
class _$LmsClassworkItemCopyWithImpl<$Res>
    implements $LmsClassworkItemCopyWith<$Res> {
  _$LmsClassworkItemCopyWithImpl(this._self, this._then);

  final LmsClassworkItem _self;
  final $Res Function(LmsClassworkItem) _then;

/// Create a copy of LmsClassworkItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? classId = null,Object? title = null,Object? type = null,Object? topic = null,Object? status = null,Object? totalPoints = null,Object? submittedCount = null,Object? gradedCount = null,Object? totalCount = null,Object? dueDate = freezed,Object? syncStatus = null,Object? updatedAt = freezed,Object? remoteId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,classId: null == classId ? _self.classId : classId // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,topic: null == topic ? _self.topic : topic // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,totalPoints: null == totalPoints ? _self.totalPoints : totalPoints // ignore: cast_nullable_to_non_nullable
as int,submittedCount: null == submittedCount ? _self.submittedCount : submittedCount // ignore: cast_nullable_to_non_nullable
as int,gradedCount: null == gradedCount ? _self.gradedCount : gradedCount // ignore: cast_nullable_to_non_nullable
as int,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as SyncStatus,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,remoteId: freezed == remoteId ? _self.remoteId : remoteId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [LmsClassworkItem].
extension LmsClassworkItemPatterns on LmsClassworkItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LmsClassworkItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LmsClassworkItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LmsClassworkItem value)  $default,){
final _that = this;
switch (_that) {
case _LmsClassworkItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LmsClassworkItem value)?  $default,){
final _that = this;
switch (_that) {
case _LmsClassworkItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int classId,  String title,  String type,  String topic,  String status,  int totalPoints,  int submittedCount,  int gradedCount,  int totalCount,  DateTime? dueDate,  SyncStatus syncStatus,  DateTime? updatedAt,  int? remoteId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LmsClassworkItem() when $default != null:
return $default(_that.id,_that.classId,_that.title,_that.type,_that.topic,_that.status,_that.totalPoints,_that.submittedCount,_that.gradedCount,_that.totalCount,_that.dueDate,_that.syncStatus,_that.updatedAt,_that.remoteId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int classId,  String title,  String type,  String topic,  String status,  int totalPoints,  int submittedCount,  int gradedCount,  int totalCount,  DateTime? dueDate,  SyncStatus syncStatus,  DateTime? updatedAt,  int? remoteId)  $default,) {final _that = this;
switch (_that) {
case _LmsClassworkItem():
return $default(_that.id,_that.classId,_that.title,_that.type,_that.topic,_that.status,_that.totalPoints,_that.submittedCount,_that.gradedCount,_that.totalCount,_that.dueDate,_that.syncStatus,_that.updatedAt,_that.remoteId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int classId,  String title,  String type,  String topic,  String status,  int totalPoints,  int submittedCount,  int gradedCount,  int totalCount,  DateTime? dueDate,  SyncStatus syncStatus,  DateTime? updatedAt,  int? remoteId)?  $default,) {final _that = this;
switch (_that) {
case _LmsClassworkItem() when $default != null:
return $default(_that.id,_that.classId,_that.title,_that.type,_that.topic,_that.status,_that.totalPoints,_that.submittedCount,_that.gradedCount,_that.totalCount,_that.dueDate,_that.syncStatus,_that.updatedAt,_that.remoteId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LmsClassworkItem implements LmsClassworkItem {
  const _LmsClassworkItem({required this.id, required this.classId, required this.title, required this.type, this.topic = '', this.status = '', this.totalPoints = 0, this.submittedCount = 0, this.gradedCount = 0, this.totalCount = 0, this.dueDate, this.syncStatus = SyncStatus.synced, this.updatedAt, this.remoteId});
  factory _LmsClassworkItem.fromJson(Map<String, dynamic> json) => _$LmsClassworkItemFromJson(json);

@override final  int id;
@override final  int classId;
@override final  String title;
@override final  String type;
// 'assignment' | 'material'
@override@JsonKey() final  String topic;
@override@JsonKey() final  String status;
@override@JsonKey() final  int totalPoints;
@override@JsonKey() final  int submittedCount;
@override@JsonKey() final  int gradedCount;
@override@JsonKey() final  int totalCount;
@override final  DateTime? dueDate;
@override@JsonKey() final  SyncStatus syncStatus;
@override final  DateTime? updatedAt;
@override final  int? remoteId;

/// Create a copy of LmsClassworkItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LmsClassworkItemCopyWith<_LmsClassworkItem> get copyWith => __$LmsClassworkItemCopyWithImpl<_LmsClassworkItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LmsClassworkItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LmsClassworkItem&&(identical(other.id, id) || other.id == id)&&(identical(other.classId, classId) || other.classId == classId)&&(identical(other.title, title) || other.title == title)&&(identical(other.type, type) || other.type == type)&&(identical(other.topic, topic) || other.topic == topic)&&(identical(other.status, status) || other.status == status)&&(identical(other.totalPoints, totalPoints) || other.totalPoints == totalPoints)&&(identical(other.submittedCount, submittedCount) || other.submittedCount == submittedCount)&&(identical(other.gradedCount, gradedCount) || other.gradedCount == gradedCount)&&(identical(other.totalCount, totalCount) || other.totalCount == totalCount)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.remoteId, remoteId) || other.remoteId == remoteId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,classId,title,type,topic,status,totalPoints,submittedCount,gradedCount,totalCount,dueDate,syncStatus,updatedAt,remoteId);

@override
String toString() {
  return 'LmsClassworkItem(id: $id, classId: $classId, title: $title, type: $type, topic: $topic, status: $status, totalPoints: $totalPoints, submittedCount: $submittedCount, gradedCount: $gradedCount, totalCount: $totalCount, dueDate: $dueDate, syncStatus: $syncStatus, updatedAt: $updatedAt, remoteId: $remoteId)';
}


}

/// @nodoc
abstract mixin class _$LmsClassworkItemCopyWith<$Res> implements $LmsClassworkItemCopyWith<$Res> {
  factory _$LmsClassworkItemCopyWith(_LmsClassworkItem value, $Res Function(_LmsClassworkItem) _then) = __$LmsClassworkItemCopyWithImpl;
@override @useResult
$Res call({
 int id, int classId, String title, String type, String topic, String status, int totalPoints, int submittedCount, int gradedCount, int totalCount, DateTime? dueDate, SyncStatus syncStatus, DateTime? updatedAt, int? remoteId
});




}
/// @nodoc
class __$LmsClassworkItemCopyWithImpl<$Res>
    implements _$LmsClassworkItemCopyWith<$Res> {
  __$LmsClassworkItemCopyWithImpl(this._self, this._then);

  final _LmsClassworkItem _self;
  final $Res Function(_LmsClassworkItem) _then;

/// Create a copy of LmsClassworkItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? classId = null,Object? title = null,Object? type = null,Object? topic = null,Object? status = null,Object? totalPoints = null,Object? submittedCount = null,Object? gradedCount = null,Object? totalCount = null,Object? dueDate = freezed,Object? syncStatus = null,Object? updatedAt = freezed,Object? remoteId = freezed,}) {
  return _then(_LmsClassworkItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,classId: null == classId ? _self.classId : classId // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,topic: null == topic ? _self.topic : topic // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,totalPoints: null == totalPoints ? _self.totalPoints : totalPoints // ignore: cast_nullable_to_non_nullable
as int,submittedCount: null == submittedCount ? _self.submittedCount : submittedCount // ignore: cast_nullable_to_non_nullable
as int,gradedCount: null == gradedCount ? _self.gradedCount : gradedCount // ignore: cast_nullable_to_non_nullable
as int,totalCount: null == totalCount ? _self.totalCount : totalCount // ignore: cast_nullable_to_non_nullable
as int,dueDate: freezed == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as SyncStatus,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,remoteId: freezed == remoteId ? _self.remoteId : remoteId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sync_operation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SyncOperation {

 int get id; SyncOperationType get operation; String get entityType; int get entityId; String get payload; SyncOperationStatus get status; int get retryCount; DateTime get createdAt; DateTime? get lastAttemptAt; String? get errorMessage;
/// Create a copy of SyncOperation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SyncOperationCopyWith<SyncOperation> get copyWith => _$SyncOperationCopyWithImpl<SyncOperation>(this as SyncOperation, _$identity);

  /// Serializes this SyncOperation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SyncOperation&&(identical(other.id, id) || other.id == id)&&(identical(other.operation, operation) || other.operation == operation)&&(identical(other.entityType, entityType) || other.entityType == entityType)&&(identical(other.entityId, entityId) || other.entityId == entityId)&&(identical(other.payload, payload) || other.payload == payload)&&(identical(other.status, status) || other.status == status)&&(identical(other.retryCount, retryCount) || other.retryCount == retryCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastAttemptAt, lastAttemptAt) || other.lastAttemptAt == lastAttemptAt)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,operation,entityType,entityId,payload,status,retryCount,createdAt,lastAttemptAt,errorMessage);

@override
String toString() {
  return 'SyncOperation(id: $id, operation: $operation, entityType: $entityType, entityId: $entityId, payload: $payload, status: $status, retryCount: $retryCount, createdAt: $createdAt, lastAttemptAt: $lastAttemptAt, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $SyncOperationCopyWith<$Res>  {
  factory $SyncOperationCopyWith(SyncOperation value, $Res Function(SyncOperation) _then) = _$SyncOperationCopyWithImpl;
@useResult
$Res call({
 int id, SyncOperationType operation, String entityType, int entityId, String payload, SyncOperationStatus status, int retryCount, DateTime createdAt, DateTime? lastAttemptAt, String? errorMessage
});




}
/// @nodoc
class _$SyncOperationCopyWithImpl<$Res>
    implements $SyncOperationCopyWith<$Res> {
  _$SyncOperationCopyWithImpl(this._self, this._then);

  final SyncOperation _self;
  final $Res Function(SyncOperation) _then;

/// Create a copy of SyncOperation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? operation = null,Object? entityType = null,Object? entityId = null,Object? payload = null,Object? status = null,Object? retryCount = null,Object? createdAt = null,Object? lastAttemptAt = freezed,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,operation: null == operation ? _self.operation : operation // ignore: cast_nullable_to_non_nullable
as SyncOperationType,entityType: null == entityType ? _self.entityType : entityType // ignore: cast_nullable_to_non_nullable
as String,entityId: null == entityId ? _self.entityId : entityId // ignore: cast_nullable_to_non_nullable
as int,payload: null == payload ? _self.payload : payload // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SyncOperationStatus,retryCount: null == retryCount ? _self.retryCount : retryCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastAttemptAt: freezed == lastAttemptAt ? _self.lastAttemptAt : lastAttemptAt // ignore: cast_nullable_to_non_nullable
as DateTime?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SyncOperation].
extension SyncOperationPatterns on SyncOperation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SyncOperation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SyncOperation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SyncOperation value)  $default,){
final _that = this;
switch (_that) {
case _SyncOperation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SyncOperation value)?  $default,){
final _that = this;
switch (_that) {
case _SyncOperation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  SyncOperationType operation,  String entityType,  int entityId,  String payload,  SyncOperationStatus status,  int retryCount,  DateTime createdAt,  DateTime? lastAttemptAt,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SyncOperation() when $default != null:
return $default(_that.id,_that.operation,_that.entityType,_that.entityId,_that.payload,_that.status,_that.retryCount,_that.createdAt,_that.lastAttemptAt,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  SyncOperationType operation,  String entityType,  int entityId,  String payload,  SyncOperationStatus status,  int retryCount,  DateTime createdAt,  DateTime? lastAttemptAt,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _SyncOperation():
return $default(_that.id,_that.operation,_that.entityType,_that.entityId,_that.payload,_that.status,_that.retryCount,_that.createdAt,_that.lastAttemptAt,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  SyncOperationType operation,  String entityType,  int entityId,  String payload,  SyncOperationStatus status,  int retryCount,  DateTime createdAt,  DateTime? lastAttemptAt,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _SyncOperation() when $default != null:
return $default(_that.id,_that.operation,_that.entityType,_that.entityId,_that.payload,_that.status,_that.retryCount,_that.createdAt,_that.lastAttemptAt,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SyncOperation implements SyncOperation {
  const _SyncOperation({required this.id, required this.operation, required this.entityType, required this.entityId, required this.payload, this.status = SyncOperationStatus.pending, this.retryCount = 0, required this.createdAt, this.lastAttemptAt, this.errorMessage});
  factory _SyncOperation.fromJson(Map<String, dynamic> json) => _$SyncOperationFromJson(json);

@override final  int id;
@override final  SyncOperationType operation;
@override final  String entityType;
@override final  int entityId;
@override final  String payload;
@override@JsonKey() final  SyncOperationStatus status;
@override@JsonKey() final  int retryCount;
@override final  DateTime createdAt;
@override final  DateTime? lastAttemptAt;
@override final  String? errorMessage;

/// Create a copy of SyncOperation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SyncOperationCopyWith<_SyncOperation> get copyWith => __$SyncOperationCopyWithImpl<_SyncOperation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SyncOperationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SyncOperation&&(identical(other.id, id) || other.id == id)&&(identical(other.operation, operation) || other.operation == operation)&&(identical(other.entityType, entityType) || other.entityType == entityType)&&(identical(other.entityId, entityId) || other.entityId == entityId)&&(identical(other.payload, payload) || other.payload == payload)&&(identical(other.status, status) || other.status == status)&&(identical(other.retryCount, retryCount) || other.retryCount == retryCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastAttemptAt, lastAttemptAt) || other.lastAttemptAt == lastAttemptAt)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,operation,entityType,entityId,payload,status,retryCount,createdAt,lastAttemptAt,errorMessage);

@override
String toString() {
  return 'SyncOperation(id: $id, operation: $operation, entityType: $entityType, entityId: $entityId, payload: $payload, status: $status, retryCount: $retryCount, createdAt: $createdAt, lastAttemptAt: $lastAttemptAt, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$SyncOperationCopyWith<$Res> implements $SyncOperationCopyWith<$Res> {
  factory _$SyncOperationCopyWith(_SyncOperation value, $Res Function(_SyncOperation) _then) = __$SyncOperationCopyWithImpl;
@override @useResult
$Res call({
 int id, SyncOperationType operation, String entityType, int entityId, String payload, SyncOperationStatus status, int retryCount, DateTime createdAt, DateTime? lastAttemptAt, String? errorMessage
});




}
/// @nodoc
class __$SyncOperationCopyWithImpl<$Res>
    implements _$SyncOperationCopyWith<$Res> {
  __$SyncOperationCopyWithImpl(this._self, this._then);

  final _SyncOperation _self;
  final $Res Function(_SyncOperation) _then;

/// Create a copy of SyncOperation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? operation = null,Object? entityType = null,Object? entityId = null,Object? payload = null,Object? status = null,Object? retryCount = null,Object? createdAt = null,Object? lastAttemptAt = freezed,Object? errorMessage = freezed,}) {
  return _then(_SyncOperation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,operation: null == operation ? _self.operation : operation // ignore: cast_nullable_to_non_nullable
as SyncOperationType,entityType: null == entityType ? _self.entityType : entityType // ignore: cast_nullable_to_non_nullable
as String,entityId: null == entityId ? _self.entityId : entityId // ignore: cast_nullable_to_non_nullable
as int,payload: null == payload ? _self.payload : payload // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SyncOperationStatus,retryCount: null == retryCount ? _self.retryCount : retryCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastAttemptAt: freezed == lastAttemptAt ? _self.lastAttemptAt : lastAttemptAt // ignore: cast_nullable_to_non_nullable
as DateTime?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on

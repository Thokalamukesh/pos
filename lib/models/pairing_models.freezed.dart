// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pairing_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PairingStartResponse {

@JsonKey(name: 'pairing_code') String get pairingCode;@JsonKey(name: 'device_uuid') String get deviceUuid;@JsonKey(name: 'expires_at') DateTime? get expiresAt;
/// Create a copy of PairingStartResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PairingStartResponseCopyWith<PairingStartResponse> get copyWith => _$PairingStartResponseCopyWithImpl<PairingStartResponse>(this as PairingStartResponse, _$identity);

  /// Serializes this PairingStartResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PairingStartResponse&&(identical(other.pairingCode, pairingCode) || other.pairingCode == pairingCode)&&(identical(other.deviceUuid, deviceUuid) || other.deviceUuid == deviceUuid)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,pairingCode,deviceUuid,expiresAt);

@override
String toString() {
  return 'PairingStartResponse(pairingCode: $pairingCode, deviceUuid: $deviceUuid, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class $PairingStartResponseCopyWith<$Res>  {
  factory $PairingStartResponseCopyWith(PairingStartResponse value, $Res Function(PairingStartResponse) _then) = _$PairingStartResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'pairing_code') String pairingCode,@JsonKey(name: 'device_uuid') String deviceUuid,@JsonKey(name: 'expires_at') DateTime? expiresAt
});




}
/// @nodoc
class _$PairingStartResponseCopyWithImpl<$Res>
    implements $PairingStartResponseCopyWith<$Res> {
  _$PairingStartResponseCopyWithImpl(this._self, this._then);

  final PairingStartResponse _self;
  final $Res Function(PairingStartResponse) _then;

/// Create a copy of PairingStartResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pairingCode = null,Object? deviceUuid = null,Object? expiresAt = freezed,}) {
  return _then(_self.copyWith(
pairingCode: null == pairingCode ? _self.pairingCode : pairingCode // ignore: cast_nullable_to_non_nullable
as String,deviceUuid: null == deviceUuid ? _self.deviceUuid : deviceUuid // ignore: cast_nullable_to_non_nullable
as String,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [PairingStartResponse].
extension PairingStartResponsePatterns on PairingStartResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PairingStartResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PairingStartResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PairingStartResponse value)  $default,){
final _that = this;
switch (_that) {
case _PairingStartResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PairingStartResponse value)?  $default,){
final _that = this;
switch (_that) {
case _PairingStartResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'pairing_code')  String pairingCode, @JsonKey(name: 'device_uuid')  String deviceUuid, @JsonKey(name: 'expires_at')  DateTime? expiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PairingStartResponse() when $default != null:
return $default(_that.pairingCode,_that.deviceUuid,_that.expiresAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'pairing_code')  String pairingCode, @JsonKey(name: 'device_uuid')  String deviceUuid, @JsonKey(name: 'expires_at')  DateTime? expiresAt)  $default,) {final _that = this;
switch (_that) {
case _PairingStartResponse():
return $default(_that.pairingCode,_that.deviceUuid,_that.expiresAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'pairing_code')  String pairingCode, @JsonKey(name: 'device_uuid')  String deviceUuid, @JsonKey(name: 'expires_at')  DateTime? expiresAt)?  $default,) {final _that = this;
switch (_that) {
case _PairingStartResponse() when $default != null:
return $default(_that.pairingCode,_that.deviceUuid,_that.expiresAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PairingStartResponse implements PairingStartResponse {
  const _PairingStartResponse({@JsonKey(name: 'pairing_code') required this.pairingCode, @JsonKey(name: 'device_uuid') required this.deviceUuid, @JsonKey(name: 'expires_at') this.expiresAt});
  factory _PairingStartResponse.fromJson(Map<String, dynamic> json) => _$PairingStartResponseFromJson(json);

@override@JsonKey(name: 'pairing_code') final  String pairingCode;
@override@JsonKey(name: 'device_uuid') final  String deviceUuid;
@override@JsonKey(name: 'expires_at') final  DateTime? expiresAt;

/// Create a copy of PairingStartResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PairingStartResponseCopyWith<_PairingStartResponse> get copyWith => __$PairingStartResponseCopyWithImpl<_PairingStartResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PairingStartResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PairingStartResponse&&(identical(other.pairingCode, pairingCode) || other.pairingCode == pairingCode)&&(identical(other.deviceUuid, deviceUuid) || other.deviceUuid == deviceUuid)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,pairingCode,deviceUuid,expiresAt);

@override
String toString() {
  return 'PairingStartResponse(pairingCode: $pairingCode, deviceUuid: $deviceUuid, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class _$PairingStartResponseCopyWith<$Res> implements $PairingStartResponseCopyWith<$Res> {
  factory _$PairingStartResponseCopyWith(_PairingStartResponse value, $Res Function(_PairingStartResponse) _then) = __$PairingStartResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'pairing_code') String pairingCode,@JsonKey(name: 'device_uuid') String deviceUuid,@JsonKey(name: 'expires_at') DateTime? expiresAt
});




}
/// @nodoc
class __$PairingStartResponseCopyWithImpl<$Res>
    implements _$PairingStartResponseCopyWith<$Res> {
  __$PairingStartResponseCopyWithImpl(this._self, this._then);

  final _PairingStartResponse _self;
  final $Res Function(_PairingStartResponse) _then;

/// Create a copy of PairingStartResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pairingCode = null,Object? deviceUuid = null,Object? expiresAt = freezed,}) {
  return _then(_PairingStartResponse(
pairingCode: null == pairingCode ? _self.pairingCode : pairingCode // ignore: cast_nullable_to_non_nullable
as String,deviceUuid: null == deviceUuid ? _self.deviceUuid : deviceUuid // ignore: cast_nullable_to_non_nullable
as String,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$PairingStatusResponse {

 String get status;@JsonKey(name: 'pairing_code') String? get pairingCode;@JsonKey(name: 'device_uuid') String? get deviceUuid;@JsonKey(name: 'expires_at') DateTime? get expiresAt;@JsonKey(name: 'restaurant_id') int? get restaurantId;@JsonKey(name: 'restaurant_name') String? get restaurantName;@JsonKey(name: 'branch_id') int? get branchId;@JsonKey(name: 'branch_name') String? get branchName;@JsonKey(name: 'pos_terminal') PosTerminal? get posTerminal;
/// Create a copy of PairingStatusResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PairingStatusResponseCopyWith<PairingStatusResponse> get copyWith => _$PairingStatusResponseCopyWithImpl<PairingStatusResponse>(this as PairingStatusResponse, _$identity);

  /// Serializes this PairingStatusResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PairingStatusResponse&&(identical(other.status, status) || other.status == status)&&(identical(other.pairingCode, pairingCode) || other.pairingCode == pairingCode)&&(identical(other.deviceUuid, deviceUuid) || other.deviceUuid == deviceUuid)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.restaurantId, restaurantId) || other.restaurantId == restaurantId)&&(identical(other.restaurantName, restaurantName) || other.restaurantName == restaurantName)&&(identical(other.branchId, branchId) || other.branchId == branchId)&&(identical(other.branchName, branchName) || other.branchName == branchName)&&(identical(other.posTerminal, posTerminal) || other.posTerminal == posTerminal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,pairingCode,deviceUuid,expiresAt,restaurantId,restaurantName,branchId,branchName,posTerminal);

@override
String toString() {
  return 'PairingStatusResponse(status: $status, pairingCode: $pairingCode, deviceUuid: $deviceUuid, expiresAt: $expiresAt, restaurantId: $restaurantId, restaurantName: $restaurantName, branchId: $branchId, branchName: $branchName, posTerminal: $posTerminal)';
}


}

/// @nodoc
abstract mixin class $PairingStatusResponseCopyWith<$Res>  {
  factory $PairingStatusResponseCopyWith(PairingStatusResponse value, $Res Function(PairingStatusResponse) _then) = _$PairingStatusResponseCopyWithImpl;
@useResult
$Res call({
 String status,@JsonKey(name: 'pairing_code') String? pairingCode,@JsonKey(name: 'device_uuid') String? deviceUuid,@JsonKey(name: 'expires_at') DateTime? expiresAt,@JsonKey(name: 'restaurant_id') int? restaurantId,@JsonKey(name: 'restaurant_name') String? restaurantName,@JsonKey(name: 'branch_id') int? branchId,@JsonKey(name: 'branch_name') String? branchName,@JsonKey(name: 'pos_terminal') PosTerminal? posTerminal
});


$PosTerminalCopyWith<$Res>? get posTerminal;

}
/// @nodoc
class _$PairingStatusResponseCopyWithImpl<$Res>
    implements $PairingStatusResponseCopyWith<$Res> {
  _$PairingStatusResponseCopyWithImpl(this._self, this._then);

  final PairingStatusResponse _self;
  final $Res Function(PairingStatusResponse) _then;

/// Create a copy of PairingStatusResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? pairingCode = freezed,Object? deviceUuid = freezed,Object? expiresAt = freezed,Object? restaurantId = freezed,Object? restaurantName = freezed,Object? branchId = freezed,Object? branchName = freezed,Object? posTerminal = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,pairingCode: freezed == pairingCode ? _self.pairingCode : pairingCode // ignore: cast_nullable_to_non_nullable
as String?,deviceUuid: freezed == deviceUuid ? _self.deviceUuid : deviceUuid // ignore: cast_nullable_to_non_nullable
as String?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,restaurantId: freezed == restaurantId ? _self.restaurantId : restaurantId // ignore: cast_nullable_to_non_nullable
as int?,restaurantName: freezed == restaurantName ? _self.restaurantName : restaurantName // ignore: cast_nullable_to_non_nullable
as String?,branchId: freezed == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as int?,branchName: freezed == branchName ? _self.branchName : branchName // ignore: cast_nullable_to_non_nullable
as String?,posTerminal: freezed == posTerminal ? _self.posTerminal : posTerminal // ignore: cast_nullable_to_non_nullable
as PosTerminal?,
  ));
}
/// Create a copy of PairingStatusResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PosTerminalCopyWith<$Res>? get posTerminal {
    if (_self.posTerminal == null) {
    return null;
  }

  return $PosTerminalCopyWith<$Res>(_self.posTerminal!, (value) {
    return _then(_self.copyWith(posTerminal: value));
  });
}
}


/// Adds pattern-matching-related methods to [PairingStatusResponse].
extension PairingStatusResponsePatterns on PairingStatusResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PairingStatusResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PairingStatusResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PairingStatusResponse value)  $default,){
final _that = this;
switch (_that) {
case _PairingStatusResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PairingStatusResponse value)?  $default,){
final _that = this;
switch (_that) {
case _PairingStatusResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String status, @JsonKey(name: 'pairing_code')  String? pairingCode, @JsonKey(name: 'device_uuid')  String? deviceUuid, @JsonKey(name: 'expires_at')  DateTime? expiresAt, @JsonKey(name: 'restaurant_id')  int? restaurantId, @JsonKey(name: 'restaurant_name')  String? restaurantName, @JsonKey(name: 'branch_id')  int? branchId, @JsonKey(name: 'branch_name')  String? branchName, @JsonKey(name: 'pos_terminal')  PosTerminal? posTerminal)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PairingStatusResponse() when $default != null:
return $default(_that.status,_that.pairingCode,_that.deviceUuid,_that.expiresAt,_that.restaurantId,_that.restaurantName,_that.branchId,_that.branchName,_that.posTerminal);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String status, @JsonKey(name: 'pairing_code')  String? pairingCode, @JsonKey(name: 'device_uuid')  String? deviceUuid, @JsonKey(name: 'expires_at')  DateTime? expiresAt, @JsonKey(name: 'restaurant_id')  int? restaurantId, @JsonKey(name: 'restaurant_name')  String? restaurantName, @JsonKey(name: 'branch_id')  int? branchId, @JsonKey(name: 'branch_name')  String? branchName, @JsonKey(name: 'pos_terminal')  PosTerminal? posTerminal)  $default,) {final _that = this;
switch (_that) {
case _PairingStatusResponse():
return $default(_that.status,_that.pairingCode,_that.deviceUuid,_that.expiresAt,_that.restaurantId,_that.restaurantName,_that.branchId,_that.branchName,_that.posTerminal);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String status, @JsonKey(name: 'pairing_code')  String? pairingCode, @JsonKey(name: 'device_uuid')  String? deviceUuid, @JsonKey(name: 'expires_at')  DateTime? expiresAt, @JsonKey(name: 'restaurant_id')  int? restaurantId, @JsonKey(name: 'restaurant_name')  String? restaurantName, @JsonKey(name: 'branch_id')  int? branchId, @JsonKey(name: 'branch_name')  String? branchName, @JsonKey(name: 'pos_terminal')  PosTerminal? posTerminal)?  $default,) {final _that = this;
switch (_that) {
case _PairingStatusResponse() when $default != null:
return $default(_that.status,_that.pairingCode,_that.deviceUuid,_that.expiresAt,_that.restaurantId,_that.restaurantName,_that.branchId,_that.branchName,_that.posTerminal);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PairingStatusResponse implements PairingStatusResponse {
  const _PairingStatusResponse({required this.status, @JsonKey(name: 'pairing_code') this.pairingCode, @JsonKey(name: 'device_uuid') this.deviceUuid, @JsonKey(name: 'expires_at') this.expiresAt, @JsonKey(name: 'restaurant_id') this.restaurantId, @JsonKey(name: 'restaurant_name') this.restaurantName, @JsonKey(name: 'branch_id') this.branchId, @JsonKey(name: 'branch_name') this.branchName, @JsonKey(name: 'pos_terminal') this.posTerminal});
  factory _PairingStatusResponse.fromJson(Map<String, dynamic> json) => _$PairingStatusResponseFromJson(json);

@override final  String status;
@override@JsonKey(name: 'pairing_code') final  String? pairingCode;
@override@JsonKey(name: 'device_uuid') final  String? deviceUuid;
@override@JsonKey(name: 'expires_at') final  DateTime? expiresAt;
@override@JsonKey(name: 'restaurant_id') final  int? restaurantId;
@override@JsonKey(name: 'restaurant_name') final  String? restaurantName;
@override@JsonKey(name: 'branch_id') final  int? branchId;
@override@JsonKey(name: 'branch_name') final  String? branchName;
@override@JsonKey(name: 'pos_terminal') final  PosTerminal? posTerminal;

/// Create a copy of PairingStatusResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PairingStatusResponseCopyWith<_PairingStatusResponse> get copyWith => __$PairingStatusResponseCopyWithImpl<_PairingStatusResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PairingStatusResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PairingStatusResponse&&(identical(other.status, status) || other.status == status)&&(identical(other.pairingCode, pairingCode) || other.pairingCode == pairingCode)&&(identical(other.deviceUuid, deviceUuid) || other.deviceUuid == deviceUuid)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.restaurantId, restaurantId) || other.restaurantId == restaurantId)&&(identical(other.restaurantName, restaurantName) || other.restaurantName == restaurantName)&&(identical(other.branchId, branchId) || other.branchId == branchId)&&(identical(other.branchName, branchName) || other.branchName == branchName)&&(identical(other.posTerminal, posTerminal) || other.posTerminal == posTerminal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,pairingCode,deviceUuid,expiresAt,restaurantId,restaurantName,branchId,branchName,posTerminal);

@override
String toString() {
  return 'PairingStatusResponse(status: $status, pairingCode: $pairingCode, deviceUuid: $deviceUuid, expiresAt: $expiresAt, restaurantId: $restaurantId, restaurantName: $restaurantName, branchId: $branchId, branchName: $branchName, posTerminal: $posTerminal)';
}


}

/// @nodoc
abstract mixin class _$PairingStatusResponseCopyWith<$Res> implements $PairingStatusResponseCopyWith<$Res> {
  factory _$PairingStatusResponseCopyWith(_PairingStatusResponse value, $Res Function(_PairingStatusResponse) _then) = __$PairingStatusResponseCopyWithImpl;
@override @useResult
$Res call({
 String status,@JsonKey(name: 'pairing_code') String? pairingCode,@JsonKey(name: 'device_uuid') String? deviceUuid,@JsonKey(name: 'expires_at') DateTime? expiresAt,@JsonKey(name: 'restaurant_id') int? restaurantId,@JsonKey(name: 'restaurant_name') String? restaurantName,@JsonKey(name: 'branch_id') int? branchId,@JsonKey(name: 'branch_name') String? branchName,@JsonKey(name: 'pos_terminal') PosTerminal? posTerminal
});


@override $PosTerminalCopyWith<$Res>? get posTerminal;

}
/// @nodoc
class __$PairingStatusResponseCopyWithImpl<$Res>
    implements _$PairingStatusResponseCopyWith<$Res> {
  __$PairingStatusResponseCopyWithImpl(this._self, this._then);

  final _PairingStatusResponse _self;
  final $Res Function(_PairingStatusResponse) _then;

/// Create a copy of PairingStatusResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? pairingCode = freezed,Object? deviceUuid = freezed,Object? expiresAt = freezed,Object? restaurantId = freezed,Object? restaurantName = freezed,Object? branchId = freezed,Object? branchName = freezed,Object? posTerminal = freezed,}) {
  return _then(_PairingStatusResponse(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,pairingCode: freezed == pairingCode ? _self.pairingCode : pairingCode // ignore: cast_nullable_to_non_nullable
as String?,deviceUuid: freezed == deviceUuid ? _self.deviceUuid : deviceUuid // ignore: cast_nullable_to_non_nullable
as String?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,restaurantId: freezed == restaurantId ? _self.restaurantId : restaurantId // ignore: cast_nullable_to_non_nullable
as int?,restaurantName: freezed == restaurantName ? _self.restaurantName : restaurantName // ignore: cast_nullable_to_non_nullable
as String?,branchId: freezed == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as int?,branchName: freezed == branchName ? _self.branchName : branchName // ignore: cast_nullable_to_non_nullable
as String?,posTerminal: freezed == posTerminal ? _self.posTerminal : posTerminal // ignore: cast_nullable_to_non_nullable
as PosTerminal?,
  ));
}

/// Create a copy of PairingStatusResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PosTerminalCopyWith<$Res>? get posTerminal {
    if (_self.posTerminal == null) {
    return null;
  }

  return $PosTerminalCopyWith<$Res>(_self.posTerminal!, (value) {
    return _then(_self.copyWith(posTerminal: value));
  });
}
}


/// @nodoc
mixin _$PairedDevice {

 String get deviceUuid; int get restaurantId; String get restaurantName; int get branchId; String get branchName; PosTerminal get terminal; DateTime get pairedAt;
/// Create a copy of PairedDevice
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PairedDeviceCopyWith<PairedDevice> get copyWith => _$PairedDeviceCopyWithImpl<PairedDevice>(this as PairedDevice, _$identity);

  /// Serializes this PairedDevice to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PairedDevice&&(identical(other.deviceUuid, deviceUuid) || other.deviceUuid == deviceUuid)&&(identical(other.restaurantId, restaurantId) || other.restaurantId == restaurantId)&&(identical(other.restaurantName, restaurantName) || other.restaurantName == restaurantName)&&(identical(other.branchId, branchId) || other.branchId == branchId)&&(identical(other.branchName, branchName) || other.branchName == branchName)&&(identical(other.terminal, terminal) || other.terminal == terminal)&&(identical(other.pairedAt, pairedAt) || other.pairedAt == pairedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,deviceUuid,restaurantId,restaurantName,branchId,branchName,terminal,pairedAt);

@override
String toString() {
  return 'PairedDevice(deviceUuid: $deviceUuid, restaurantId: $restaurantId, restaurantName: $restaurantName, branchId: $branchId, branchName: $branchName, terminal: $terminal, pairedAt: $pairedAt)';
}


}

/// @nodoc
abstract mixin class $PairedDeviceCopyWith<$Res>  {
  factory $PairedDeviceCopyWith(PairedDevice value, $Res Function(PairedDevice) _then) = _$PairedDeviceCopyWithImpl;
@useResult
$Res call({
 String deviceUuid, int restaurantId, String restaurantName, int branchId, String branchName, PosTerminal terminal, DateTime pairedAt
});


$PosTerminalCopyWith<$Res> get terminal;

}
/// @nodoc
class _$PairedDeviceCopyWithImpl<$Res>
    implements $PairedDeviceCopyWith<$Res> {
  _$PairedDeviceCopyWithImpl(this._self, this._then);

  final PairedDevice _self;
  final $Res Function(PairedDevice) _then;

/// Create a copy of PairedDevice
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? deviceUuid = null,Object? restaurantId = null,Object? restaurantName = null,Object? branchId = null,Object? branchName = null,Object? terminal = null,Object? pairedAt = null,}) {
  return _then(_self.copyWith(
deviceUuid: null == deviceUuid ? _self.deviceUuid : deviceUuid // ignore: cast_nullable_to_non_nullable
as String,restaurantId: null == restaurantId ? _self.restaurantId : restaurantId // ignore: cast_nullable_to_non_nullable
as int,restaurantName: null == restaurantName ? _self.restaurantName : restaurantName // ignore: cast_nullable_to_non_nullable
as String,branchId: null == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as int,branchName: null == branchName ? _self.branchName : branchName // ignore: cast_nullable_to_non_nullable
as String,terminal: null == terminal ? _self.terminal : terminal // ignore: cast_nullable_to_non_nullable
as PosTerminal,pairedAt: null == pairedAt ? _self.pairedAt : pairedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of PairedDevice
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PosTerminalCopyWith<$Res> get terminal {
  
  return $PosTerminalCopyWith<$Res>(_self.terminal, (value) {
    return _then(_self.copyWith(terminal: value));
  });
}
}


/// Adds pattern-matching-related methods to [PairedDevice].
extension PairedDevicePatterns on PairedDevice {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PairedDevice value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PairedDevice() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PairedDevice value)  $default,){
final _that = this;
switch (_that) {
case _PairedDevice():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PairedDevice value)?  $default,){
final _that = this;
switch (_that) {
case _PairedDevice() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String deviceUuid,  int restaurantId,  String restaurantName,  int branchId,  String branchName,  PosTerminal terminal,  DateTime pairedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PairedDevice() when $default != null:
return $default(_that.deviceUuid,_that.restaurantId,_that.restaurantName,_that.branchId,_that.branchName,_that.terminal,_that.pairedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String deviceUuid,  int restaurantId,  String restaurantName,  int branchId,  String branchName,  PosTerminal terminal,  DateTime pairedAt)  $default,) {final _that = this;
switch (_that) {
case _PairedDevice():
return $default(_that.deviceUuid,_that.restaurantId,_that.restaurantName,_that.branchId,_that.branchName,_that.terminal,_that.pairedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String deviceUuid,  int restaurantId,  String restaurantName,  int branchId,  String branchName,  PosTerminal terminal,  DateTime pairedAt)?  $default,) {final _that = this;
switch (_that) {
case _PairedDevice() when $default != null:
return $default(_that.deviceUuid,_that.restaurantId,_that.restaurantName,_that.branchId,_that.branchName,_that.terminal,_that.pairedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PairedDevice implements PairedDevice {
  const _PairedDevice({required this.deviceUuid, required this.restaurantId, required this.restaurantName, required this.branchId, required this.branchName, required this.terminal, required this.pairedAt});
  factory _PairedDevice.fromJson(Map<String, dynamic> json) => _$PairedDeviceFromJson(json);

@override final  String deviceUuid;
@override final  int restaurantId;
@override final  String restaurantName;
@override final  int branchId;
@override final  String branchName;
@override final  PosTerminal terminal;
@override final  DateTime pairedAt;

/// Create a copy of PairedDevice
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PairedDeviceCopyWith<_PairedDevice> get copyWith => __$PairedDeviceCopyWithImpl<_PairedDevice>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PairedDeviceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PairedDevice&&(identical(other.deviceUuid, deviceUuid) || other.deviceUuid == deviceUuid)&&(identical(other.restaurantId, restaurantId) || other.restaurantId == restaurantId)&&(identical(other.restaurantName, restaurantName) || other.restaurantName == restaurantName)&&(identical(other.branchId, branchId) || other.branchId == branchId)&&(identical(other.branchName, branchName) || other.branchName == branchName)&&(identical(other.terminal, terminal) || other.terminal == terminal)&&(identical(other.pairedAt, pairedAt) || other.pairedAt == pairedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,deviceUuid,restaurantId,restaurantName,branchId,branchName,terminal,pairedAt);

@override
String toString() {
  return 'PairedDevice(deviceUuid: $deviceUuid, restaurantId: $restaurantId, restaurantName: $restaurantName, branchId: $branchId, branchName: $branchName, terminal: $terminal, pairedAt: $pairedAt)';
}


}

/// @nodoc
abstract mixin class _$PairedDeviceCopyWith<$Res> implements $PairedDeviceCopyWith<$Res> {
  factory _$PairedDeviceCopyWith(_PairedDevice value, $Res Function(_PairedDevice) _then) = __$PairedDeviceCopyWithImpl;
@override @useResult
$Res call({
 String deviceUuid, int restaurantId, String restaurantName, int branchId, String branchName, PosTerminal terminal, DateTime pairedAt
});


@override $PosTerminalCopyWith<$Res> get terminal;

}
/// @nodoc
class __$PairedDeviceCopyWithImpl<$Res>
    implements _$PairedDeviceCopyWith<$Res> {
  __$PairedDeviceCopyWithImpl(this._self, this._then);

  final _PairedDevice _self;
  final $Res Function(_PairedDevice) _then;

/// Create a copy of PairedDevice
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? deviceUuid = null,Object? restaurantId = null,Object? restaurantName = null,Object? branchId = null,Object? branchName = null,Object? terminal = null,Object? pairedAt = null,}) {
  return _then(_PairedDevice(
deviceUuid: null == deviceUuid ? _self.deviceUuid : deviceUuid // ignore: cast_nullable_to_non_nullable
as String,restaurantId: null == restaurantId ? _self.restaurantId : restaurantId // ignore: cast_nullable_to_non_nullable
as int,restaurantName: null == restaurantName ? _self.restaurantName : restaurantName // ignore: cast_nullable_to_non_nullable
as String,branchId: null == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as int,branchName: null == branchName ? _self.branchName : branchName // ignore: cast_nullable_to_non_nullable
as String,terminal: null == terminal ? _self.terminal : terminal // ignore: cast_nullable_to_non_nullable
as PosTerminal,pairedAt: null == pairedAt ? _self.pairedAt : pairedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of PairedDevice
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PosTerminalCopyWith<$Res> get terminal {
  
  return $PosTerminalCopyWith<$Res>(_self.terminal, (value) {
    return _then(_self.copyWith(terminal: value));
  });
}
}

// dart format on

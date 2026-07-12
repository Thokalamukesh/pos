// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pos_terminal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PosTerminal {

 int get id; String get code; String get name;@JsonKey(name: 'sync_token') String? get syncToken;@JsonKey(name: 'display_url') String? get displayUrl;
/// Create a copy of PosTerminal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PosTerminalCopyWith<PosTerminal> get copyWith => _$PosTerminalCopyWithImpl<PosTerminal>(this as PosTerminal, _$identity);

  /// Serializes this PosTerminal to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PosTerminal&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.syncToken, syncToken) || other.syncToken == syncToken)&&(identical(other.displayUrl, displayUrl) || other.displayUrl == displayUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,code,name,syncToken,displayUrl);

@override
String toString() {
  return 'PosTerminal(id: $id, code: $code, name: $name, syncToken: $syncToken, displayUrl: $displayUrl)';
}


}

/// @nodoc
abstract mixin class $PosTerminalCopyWith<$Res>  {
  factory $PosTerminalCopyWith(PosTerminal value, $Res Function(PosTerminal) _then) = _$PosTerminalCopyWithImpl;
@useResult
$Res call({
 int id, String code, String name,@JsonKey(name: 'sync_token') String? syncToken,@JsonKey(name: 'display_url') String? displayUrl
});




}
/// @nodoc
class _$PosTerminalCopyWithImpl<$Res>
    implements $PosTerminalCopyWith<$Res> {
  _$PosTerminalCopyWithImpl(this._self, this._then);

  final PosTerminal _self;
  final $Res Function(PosTerminal) _then;

/// Create a copy of PosTerminal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? code = null,Object? name = null,Object? syncToken = freezed,Object? displayUrl = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,syncToken: freezed == syncToken ? _self.syncToken : syncToken // ignore: cast_nullable_to_non_nullable
as String?,displayUrl: freezed == displayUrl ? _self.displayUrl : displayUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PosTerminal].
extension PosTerminalPatterns on PosTerminal {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PosTerminal value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PosTerminal() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PosTerminal value)  $default,){
final _that = this;
switch (_that) {
case _PosTerminal():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PosTerminal value)?  $default,){
final _that = this;
switch (_that) {
case _PosTerminal() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String code,  String name, @JsonKey(name: 'sync_token')  String? syncToken, @JsonKey(name: 'display_url')  String? displayUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PosTerminal() when $default != null:
return $default(_that.id,_that.code,_that.name,_that.syncToken,_that.displayUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String code,  String name, @JsonKey(name: 'sync_token')  String? syncToken, @JsonKey(name: 'display_url')  String? displayUrl)  $default,) {final _that = this;
switch (_that) {
case _PosTerminal():
return $default(_that.id,_that.code,_that.name,_that.syncToken,_that.displayUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String code,  String name, @JsonKey(name: 'sync_token')  String? syncToken, @JsonKey(name: 'display_url')  String? displayUrl)?  $default,) {final _that = this;
switch (_that) {
case _PosTerminal() when $default != null:
return $default(_that.id,_that.code,_that.name,_that.syncToken,_that.displayUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PosTerminal implements PosTerminal {
  const _PosTerminal({required this.id, required this.code, required this.name, @JsonKey(name: 'sync_token') this.syncToken, @JsonKey(name: 'display_url') this.displayUrl});
  factory _PosTerminal.fromJson(Map<String, dynamic> json) => _$PosTerminalFromJson(json);

@override final  int id;
@override final  String code;
@override final  String name;
@override@JsonKey(name: 'sync_token') final  String? syncToken;
@override@JsonKey(name: 'display_url') final  String? displayUrl;

/// Create a copy of PosTerminal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PosTerminalCopyWith<_PosTerminal> get copyWith => __$PosTerminalCopyWithImpl<_PosTerminal>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PosTerminalToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PosTerminal&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.syncToken, syncToken) || other.syncToken == syncToken)&&(identical(other.displayUrl, displayUrl) || other.displayUrl == displayUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,code,name,syncToken,displayUrl);

@override
String toString() {
  return 'PosTerminal(id: $id, code: $code, name: $name, syncToken: $syncToken, displayUrl: $displayUrl)';
}


}

/// @nodoc
abstract mixin class _$PosTerminalCopyWith<$Res> implements $PosTerminalCopyWith<$Res> {
  factory _$PosTerminalCopyWith(_PosTerminal value, $Res Function(_PosTerminal) _then) = __$PosTerminalCopyWithImpl;
@override @useResult
$Res call({
 int id, String code, String name,@JsonKey(name: 'sync_token') String? syncToken,@JsonKey(name: 'display_url') String? displayUrl
});




}
/// @nodoc
class __$PosTerminalCopyWithImpl<$Res>
    implements _$PosTerminalCopyWith<$Res> {
  __$PosTerminalCopyWithImpl(this._self, this._then);

  final _PosTerminal _self;
  final $Res Function(_PosTerminal) _then;

/// Create a copy of PosTerminal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? code = null,Object? name = null,Object? syncToken = freezed,Object? displayUrl = freezed,}) {
  return _then(_PosTerminal(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,syncToken: freezed == syncToken ? _self.syncToken : syncToken // ignore: cast_nullable_to_non_nullable
as String?,displayUrl: freezed == displayUrl ? _self.displayUrl : displayUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$TerminalContext {

 int get restaurantId; int get branchId; int get terminalId; String get terminalCode; String get terminalName; String get deviceUuid; String? get syncToken; String? get displayUrl;
/// Create a copy of TerminalContext
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TerminalContextCopyWith<TerminalContext> get copyWith => _$TerminalContextCopyWithImpl<TerminalContext>(this as TerminalContext, _$identity);

  /// Serializes this TerminalContext to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TerminalContext&&(identical(other.restaurantId, restaurantId) || other.restaurantId == restaurantId)&&(identical(other.branchId, branchId) || other.branchId == branchId)&&(identical(other.terminalId, terminalId) || other.terminalId == terminalId)&&(identical(other.terminalCode, terminalCode) || other.terminalCode == terminalCode)&&(identical(other.terminalName, terminalName) || other.terminalName == terminalName)&&(identical(other.deviceUuid, deviceUuid) || other.deviceUuid == deviceUuid)&&(identical(other.syncToken, syncToken) || other.syncToken == syncToken)&&(identical(other.displayUrl, displayUrl) || other.displayUrl == displayUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,restaurantId,branchId,terminalId,terminalCode,terminalName,deviceUuid,syncToken,displayUrl);

@override
String toString() {
  return 'TerminalContext(restaurantId: $restaurantId, branchId: $branchId, terminalId: $terminalId, terminalCode: $terminalCode, terminalName: $terminalName, deviceUuid: $deviceUuid, syncToken: $syncToken, displayUrl: $displayUrl)';
}


}

/// @nodoc
abstract mixin class $TerminalContextCopyWith<$Res>  {
  factory $TerminalContextCopyWith(TerminalContext value, $Res Function(TerminalContext) _then) = _$TerminalContextCopyWithImpl;
@useResult
$Res call({
 int restaurantId, int branchId, int terminalId, String terminalCode, String terminalName, String deviceUuid, String? syncToken, String? displayUrl
});




}
/// @nodoc
class _$TerminalContextCopyWithImpl<$Res>
    implements $TerminalContextCopyWith<$Res> {
  _$TerminalContextCopyWithImpl(this._self, this._then);

  final TerminalContext _self;
  final $Res Function(TerminalContext) _then;

/// Create a copy of TerminalContext
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? restaurantId = null,Object? branchId = null,Object? terminalId = null,Object? terminalCode = null,Object? terminalName = null,Object? deviceUuid = null,Object? syncToken = freezed,Object? displayUrl = freezed,}) {
  return _then(_self.copyWith(
restaurantId: null == restaurantId ? _self.restaurantId : restaurantId // ignore: cast_nullable_to_non_nullable
as int,branchId: null == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as int,terminalId: null == terminalId ? _self.terminalId : terminalId // ignore: cast_nullable_to_non_nullable
as int,terminalCode: null == terminalCode ? _self.terminalCode : terminalCode // ignore: cast_nullable_to_non_nullable
as String,terminalName: null == terminalName ? _self.terminalName : terminalName // ignore: cast_nullable_to_non_nullable
as String,deviceUuid: null == deviceUuid ? _self.deviceUuid : deviceUuid // ignore: cast_nullable_to_non_nullable
as String,syncToken: freezed == syncToken ? _self.syncToken : syncToken // ignore: cast_nullable_to_non_nullable
as String?,displayUrl: freezed == displayUrl ? _self.displayUrl : displayUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TerminalContext].
extension TerminalContextPatterns on TerminalContext {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TerminalContext value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TerminalContext() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TerminalContext value)  $default,){
final _that = this;
switch (_that) {
case _TerminalContext():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TerminalContext value)?  $default,){
final _that = this;
switch (_that) {
case _TerminalContext() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int restaurantId,  int branchId,  int terminalId,  String terminalCode,  String terminalName,  String deviceUuid,  String? syncToken,  String? displayUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TerminalContext() when $default != null:
return $default(_that.restaurantId,_that.branchId,_that.terminalId,_that.terminalCode,_that.terminalName,_that.deviceUuid,_that.syncToken,_that.displayUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int restaurantId,  int branchId,  int terminalId,  String terminalCode,  String terminalName,  String deviceUuid,  String? syncToken,  String? displayUrl)  $default,) {final _that = this;
switch (_that) {
case _TerminalContext():
return $default(_that.restaurantId,_that.branchId,_that.terminalId,_that.terminalCode,_that.terminalName,_that.deviceUuid,_that.syncToken,_that.displayUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int restaurantId,  int branchId,  int terminalId,  String terminalCode,  String terminalName,  String deviceUuid,  String? syncToken,  String? displayUrl)?  $default,) {final _that = this;
switch (_that) {
case _TerminalContext() when $default != null:
return $default(_that.restaurantId,_that.branchId,_that.terminalId,_that.terminalCode,_that.terminalName,_that.deviceUuid,_that.syncToken,_that.displayUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TerminalContext implements TerminalContext {
  const _TerminalContext({required this.restaurantId, required this.branchId, required this.terminalId, required this.terminalCode, required this.terminalName, required this.deviceUuid, this.syncToken, this.displayUrl});
  factory _TerminalContext.fromJson(Map<String, dynamic> json) => _$TerminalContextFromJson(json);

@override final  int restaurantId;
@override final  int branchId;
@override final  int terminalId;
@override final  String terminalCode;
@override final  String terminalName;
@override final  String deviceUuid;
@override final  String? syncToken;
@override final  String? displayUrl;

/// Create a copy of TerminalContext
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TerminalContextCopyWith<_TerminalContext> get copyWith => __$TerminalContextCopyWithImpl<_TerminalContext>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TerminalContextToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TerminalContext&&(identical(other.restaurantId, restaurantId) || other.restaurantId == restaurantId)&&(identical(other.branchId, branchId) || other.branchId == branchId)&&(identical(other.terminalId, terminalId) || other.terminalId == terminalId)&&(identical(other.terminalCode, terminalCode) || other.terminalCode == terminalCode)&&(identical(other.terminalName, terminalName) || other.terminalName == terminalName)&&(identical(other.deviceUuid, deviceUuid) || other.deviceUuid == deviceUuid)&&(identical(other.syncToken, syncToken) || other.syncToken == syncToken)&&(identical(other.displayUrl, displayUrl) || other.displayUrl == displayUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,restaurantId,branchId,terminalId,terminalCode,terminalName,deviceUuid,syncToken,displayUrl);

@override
String toString() {
  return 'TerminalContext(restaurantId: $restaurantId, branchId: $branchId, terminalId: $terminalId, terminalCode: $terminalCode, terminalName: $terminalName, deviceUuid: $deviceUuid, syncToken: $syncToken, displayUrl: $displayUrl)';
}


}

/// @nodoc
abstract mixin class _$TerminalContextCopyWith<$Res> implements $TerminalContextCopyWith<$Res> {
  factory _$TerminalContextCopyWith(_TerminalContext value, $Res Function(_TerminalContext) _then) = __$TerminalContextCopyWithImpl;
@override @useResult
$Res call({
 int restaurantId, int branchId, int terminalId, String terminalCode, String terminalName, String deviceUuid, String? syncToken, String? displayUrl
});




}
/// @nodoc
class __$TerminalContextCopyWithImpl<$Res>
    implements _$TerminalContextCopyWith<$Res> {
  __$TerminalContextCopyWithImpl(this._self, this._then);

  final _TerminalContext _self;
  final $Res Function(_TerminalContext) _then;

/// Create a copy of TerminalContext
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? restaurantId = null,Object? branchId = null,Object? terminalId = null,Object? terminalCode = null,Object? terminalName = null,Object? deviceUuid = null,Object? syncToken = freezed,Object? displayUrl = freezed,}) {
  return _then(_TerminalContext(
restaurantId: null == restaurantId ? _self.restaurantId : restaurantId // ignore: cast_nullable_to_non_nullable
as int,branchId: null == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as int,terminalId: null == terminalId ? _self.terminalId : terminalId // ignore: cast_nullable_to_non_nullable
as int,terminalCode: null == terminalCode ? _self.terminalCode : terminalCode // ignore: cast_nullable_to_non_nullable
as String,terminalName: null == terminalName ? _self.terminalName : terminalName // ignore: cast_nullable_to_non_nullable
as String,deviceUuid: null == deviceUuid ? _self.deviceUuid : deviceUuid // ignore: cast_nullable_to_non_nullable
as String,syncToken: freezed == syncToken ? _self.syncToken : syncToken // ignore: cast_nullable_to_non_nullable
as String?,displayUrl: freezed == displayUrl ? _self.displayUrl : displayUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on

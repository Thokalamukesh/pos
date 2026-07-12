// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'branch.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BranchSummary {

 int get id; String get name; String? get slug; String? get address; String? get phone;@JsonKey(name: 'is_default') bool get isDefault;
/// Create a copy of BranchSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BranchSummaryCopyWith<BranchSummary> get copyWith => _$BranchSummaryCopyWithImpl<BranchSummary>(this as BranchSummary, _$identity);

  /// Serializes this BranchSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BranchSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.address, address) || other.address == address)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,slug,address,phone,isDefault);

@override
String toString() {
  return 'BranchSummary(id: $id, name: $name, slug: $slug, address: $address, phone: $phone, isDefault: $isDefault)';
}


}

/// @nodoc
abstract mixin class $BranchSummaryCopyWith<$Res>  {
  factory $BranchSummaryCopyWith(BranchSummary value, $Res Function(BranchSummary) _then) = _$BranchSummaryCopyWithImpl;
@useResult
$Res call({
 int id, String name, String? slug, String? address, String? phone,@JsonKey(name: 'is_default') bool isDefault
});




}
/// @nodoc
class _$BranchSummaryCopyWithImpl<$Res>
    implements $BranchSummaryCopyWith<$Res> {
  _$BranchSummaryCopyWithImpl(this._self, this._then);

  final BranchSummary _self;
  final $Res Function(BranchSummary) _then;

/// Create a copy of BranchSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? slug = freezed,Object? address = freezed,Object? phone = freezed,Object? isDefault = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,slug: freezed == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [BranchSummary].
extension BranchSummaryPatterns on BranchSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BranchSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BranchSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BranchSummary value)  $default,){
final _that = this;
switch (_that) {
case _BranchSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BranchSummary value)?  $default,){
final _that = this;
switch (_that) {
case _BranchSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String? slug,  String? address,  String? phone, @JsonKey(name: 'is_default')  bool isDefault)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BranchSummary() when $default != null:
return $default(_that.id,_that.name,_that.slug,_that.address,_that.phone,_that.isDefault);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String? slug,  String? address,  String? phone, @JsonKey(name: 'is_default')  bool isDefault)  $default,) {final _that = this;
switch (_that) {
case _BranchSummary():
return $default(_that.id,_that.name,_that.slug,_that.address,_that.phone,_that.isDefault);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String? slug,  String? address,  String? phone, @JsonKey(name: 'is_default')  bool isDefault)?  $default,) {final _that = this;
switch (_that) {
case _BranchSummary() when $default != null:
return $default(_that.id,_that.name,_that.slug,_that.address,_that.phone,_that.isDefault);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BranchSummary implements BranchSummary {
  const _BranchSummary({required this.id, required this.name, this.slug, this.address, this.phone, @JsonKey(name: 'is_default') this.isDefault = false});
  factory _BranchSummary.fromJson(Map<String, dynamic> json) => _$BranchSummaryFromJson(json);

@override final  int id;
@override final  String name;
@override final  String? slug;
@override final  String? address;
@override final  String? phone;
@override@JsonKey(name: 'is_default') final  bool isDefault;

/// Create a copy of BranchSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BranchSummaryCopyWith<_BranchSummary> get copyWith => __$BranchSummaryCopyWithImpl<_BranchSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BranchSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BranchSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.address, address) || other.address == address)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,slug,address,phone,isDefault);

@override
String toString() {
  return 'BranchSummary(id: $id, name: $name, slug: $slug, address: $address, phone: $phone, isDefault: $isDefault)';
}


}

/// @nodoc
abstract mixin class _$BranchSummaryCopyWith<$Res> implements $BranchSummaryCopyWith<$Res> {
  factory _$BranchSummaryCopyWith(_BranchSummary value, $Res Function(_BranchSummary) _then) = __$BranchSummaryCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String? slug, String? address, String? phone,@JsonKey(name: 'is_default') bool isDefault
});




}
/// @nodoc
class __$BranchSummaryCopyWithImpl<$Res>
    implements _$BranchSummaryCopyWith<$Res> {
  __$BranchSummaryCopyWithImpl(this._self, this._then);

  final _BranchSummary _self;
  final $Res Function(_BranchSummary) _then;

/// Create a copy of BranchSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? slug = freezed,Object? address = freezed,Object? phone = freezed,Object? isDefault = null,}) {
  return _then(_BranchSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,slug: freezed == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on

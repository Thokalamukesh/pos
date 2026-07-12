// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'restaurant.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RestaurantSummary {

 int get id; String get name; String? get slug; String? get status; String? get role; List<BranchSummary> get branches;
/// Create a copy of RestaurantSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RestaurantSummaryCopyWith<RestaurantSummary> get copyWith => _$RestaurantSummaryCopyWithImpl<RestaurantSummary>(this as RestaurantSummary, _$identity);

  /// Serializes this RestaurantSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RestaurantSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.status, status) || other.status == status)&&(identical(other.role, role) || other.role == role)&&const DeepCollectionEquality().equals(other.branches, branches));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,slug,status,role,const DeepCollectionEquality().hash(branches));

@override
String toString() {
  return 'RestaurantSummary(id: $id, name: $name, slug: $slug, status: $status, role: $role, branches: $branches)';
}


}

/// @nodoc
abstract mixin class $RestaurantSummaryCopyWith<$Res>  {
  factory $RestaurantSummaryCopyWith(RestaurantSummary value, $Res Function(RestaurantSummary) _then) = _$RestaurantSummaryCopyWithImpl;
@useResult
$Res call({
 int id, String name, String? slug, String? status, String? role, List<BranchSummary> branches
});




}
/// @nodoc
class _$RestaurantSummaryCopyWithImpl<$Res>
    implements $RestaurantSummaryCopyWith<$Res> {
  _$RestaurantSummaryCopyWithImpl(this._self, this._then);

  final RestaurantSummary _self;
  final $Res Function(RestaurantSummary) _then;

/// Create a copy of RestaurantSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? slug = freezed,Object? status = freezed,Object? role = freezed,Object? branches = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,slug: freezed == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,role: freezed == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String?,branches: null == branches ? _self.branches : branches // ignore: cast_nullable_to_non_nullable
as List<BranchSummary>,
  ));
}

}


/// Adds pattern-matching-related methods to [RestaurantSummary].
extension RestaurantSummaryPatterns on RestaurantSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RestaurantSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RestaurantSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RestaurantSummary value)  $default,){
final _that = this;
switch (_that) {
case _RestaurantSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RestaurantSummary value)?  $default,){
final _that = this;
switch (_that) {
case _RestaurantSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String? slug,  String? status,  String? role,  List<BranchSummary> branches)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RestaurantSummary() when $default != null:
return $default(_that.id,_that.name,_that.slug,_that.status,_that.role,_that.branches);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String? slug,  String? status,  String? role,  List<BranchSummary> branches)  $default,) {final _that = this;
switch (_that) {
case _RestaurantSummary():
return $default(_that.id,_that.name,_that.slug,_that.status,_that.role,_that.branches);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String? slug,  String? status,  String? role,  List<BranchSummary> branches)?  $default,) {final _that = this;
switch (_that) {
case _RestaurantSummary() when $default != null:
return $default(_that.id,_that.name,_that.slug,_that.status,_that.role,_that.branches);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RestaurantSummary implements RestaurantSummary {
  const _RestaurantSummary({required this.id, required this.name, this.slug, this.status, this.role, final  List<BranchSummary> branches = const <BranchSummary>[]}): _branches = branches;
  factory _RestaurantSummary.fromJson(Map<String, dynamic> json) => _$RestaurantSummaryFromJson(json);

@override final  int id;
@override final  String name;
@override final  String? slug;
@override final  String? status;
@override final  String? role;
 final  List<BranchSummary> _branches;
@override@JsonKey() List<BranchSummary> get branches {
  if (_branches is EqualUnmodifiableListView) return _branches;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_branches);
}


/// Create a copy of RestaurantSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RestaurantSummaryCopyWith<_RestaurantSummary> get copyWith => __$RestaurantSummaryCopyWithImpl<_RestaurantSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RestaurantSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RestaurantSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.status, status) || other.status == status)&&(identical(other.role, role) || other.role == role)&&const DeepCollectionEquality().equals(other._branches, _branches));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,slug,status,role,const DeepCollectionEquality().hash(_branches));

@override
String toString() {
  return 'RestaurantSummary(id: $id, name: $name, slug: $slug, status: $status, role: $role, branches: $branches)';
}


}

/// @nodoc
abstract mixin class _$RestaurantSummaryCopyWith<$Res> implements $RestaurantSummaryCopyWith<$Res> {
  factory _$RestaurantSummaryCopyWith(_RestaurantSummary value, $Res Function(_RestaurantSummary) _then) = __$RestaurantSummaryCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String? slug, String? status, String? role, List<BranchSummary> branches
});




}
/// @nodoc
class __$RestaurantSummaryCopyWithImpl<$Res>
    implements _$RestaurantSummaryCopyWith<$Res> {
  __$RestaurantSummaryCopyWithImpl(this._self, this._then);

  final _RestaurantSummary _self;
  final $Res Function(_RestaurantSummary) _then;

/// Create a copy of RestaurantSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? slug = freezed,Object? status = freezed,Object? role = freezed,Object? branches = null,}) {
  return _then(_RestaurantSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,slug: freezed == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,role: freezed == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String?,branches: null == branches ? _self._branches : branches // ignore: cast_nullable_to_non_nullable
as List<BranchSummary>,
  ));
}


}


/// @nodoc
mixin _$PosRestaurant {

 int get id; String get name; String? get slug;@JsonKey(name: 'logo_url') String? get logoUrl;@JsonKey(name: 'primary_color') String? get primaryColor;@JsonKey(name: 'default_currency') String? get defaultCurrency;@JsonKey(name: 'tax_id') String? get taxId;@JsonKey(name: 'tax_settings') Map<String, dynamic> get taxSettings;@JsonKey(name: 'service_charge') Map<String, dynamic> get serviceCharge;@JsonKey(name: 'order_type_charges') Map<String, dynamic> get orderTypeCharges;@JsonKey(name: 'order_type_surcharge_settings') Map<String, dynamic> get orderTypeSurchargeSettings; Map<String, dynamic> get tips;
/// Create a copy of PosRestaurant
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PosRestaurantCopyWith<PosRestaurant> get copyWith => _$PosRestaurantCopyWithImpl<PosRestaurant>(this as PosRestaurant, _$identity);

  /// Serializes this PosRestaurant to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PosRestaurant&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.primaryColor, primaryColor) || other.primaryColor == primaryColor)&&(identical(other.defaultCurrency, defaultCurrency) || other.defaultCurrency == defaultCurrency)&&(identical(other.taxId, taxId) || other.taxId == taxId)&&const DeepCollectionEquality().equals(other.taxSettings, taxSettings)&&const DeepCollectionEquality().equals(other.serviceCharge, serviceCharge)&&const DeepCollectionEquality().equals(other.orderTypeCharges, orderTypeCharges)&&const DeepCollectionEquality().equals(other.orderTypeSurchargeSettings, orderTypeSurchargeSettings)&&const DeepCollectionEquality().equals(other.tips, tips));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,slug,logoUrl,primaryColor,defaultCurrency,taxId,const DeepCollectionEquality().hash(taxSettings),const DeepCollectionEquality().hash(serviceCharge),const DeepCollectionEquality().hash(orderTypeCharges),const DeepCollectionEquality().hash(orderTypeSurchargeSettings),const DeepCollectionEquality().hash(tips));

@override
String toString() {
  return 'PosRestaurant(id: $id, name: $name, slug: $slug, logoUrl: $logoUrl, primaryColor: $primaryColor, defaultCurrency: $defaultCurrency, taxId: $taxId, taxSettings: $taxSettings, serviceCharge: $serviceCharge, orderTypeCharges: $orderTypeCharges, orderTypeSurchargeSettings: $orderTypeSurchargeSettings, tips: $tips)';
}


}

/// @nodoc
abstract mixin class $PosRestaurantCopyWith<$Res>  {
  factory $PosRestaurantCopyWith(PosRestaurant value, $Res Function(PosRestaurant) _then) = _$PosRestaurantCopyWithImpl;
@useResult
$Res call({
 int id, String name, String? slug,@JsonKey(name: 'logo_url') String? logoUrl,@JsonKey(name: 'primary_color') String? primaryColor,@JsonKey(name: 'default_currency') String? defaultCurrency,@JsonKey(name: 'tax_id') String? taxId,@JsonKey(name: 'tax_settings') Map<String, dynamic> taxSettings,@JsonKey(name: 'service_charge') Map<String, dynamic> serviceCharge,@JsonKey(name: 'order_type_charges') Map<String, dynamic> orderTypeCharges,@JsonKey(name: 'order_type_surcharge_settings') Map<String, dynamic> orderTypeSurchargeSettings, Map<String, dynamic> tips
});




}
/// @nodoc
class _$PosRestaurantCopyWithImpl<$Res>
    implements $PosRestaurantCopyWith<$Res> {
  _$PosRestaurantCopyWithImpl(this._self, this._then);

  final PosRestaurant _self;
  final $Res Function(PosRestaurant) _then;

/// Create a copy of PosRestaurant
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? slug = freezed,Object? logoUrl = freezed,Object? primaryColor = freezed,Object? defaultCurrency = freezed,Object? taxId = freezed,Object? taxSettings = null,Object? serviceCharge = null,Object? orderTypeCharges = null,Object? orderTypeSurchargeSettings = null,Object? tips = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,slug: freezed == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String?,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,primaryColor: freezed == primaryColor ? _self.primaryColor : primaryColor // ignore: cast_nullable_to_non_nullable
as String?,defaultCurrency: freezed == defaultCurrency ? _self.defaultCurrency : defaultCurrency // ignore: cast_nullable_to_non_nullable
as String?,taxId: freezed == taxId ? _self.taxId : taxId // ignore: cast_nullable_to_non_nullable
as String?,taxSettings: null == taxSettings ? _self.taxSettings : taxSettings // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,serviceCharge: null == serviceCharge ? _self.serviceCharge : serviceCharge // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,orderTypeCharges: null == orderTypeCharges ? _self.orderTypeCharges : orderTypeCharges // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,orderTypeSurchargeSettings: null == orderTypeSurchargeSettings ? _self.orderTypeSurchargeSettings : orderTypeSurchargeSettings // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,tips: null == tips ? _self.tips : tips // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [PosRestaurant].
extension PosRestaurantPatterns on PosRestaurant {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PosRestaurant value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PosRestaurant() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PosRestaurant value)  $default,){
final _that = this;
switch (_that) {
case _PosRestaurant():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PosRestaurant value)?  $default,){
final _that = this;
switch (_that) {
case _PosRestaurant() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String? slug, @JsonKey(name: 'logo_url')  String? logoUrl, @JsonKey(name: 'primary_color')  String? primaryColor, @JsonKey(name: 'default_currency')  String? defaultCurrency, @JsonKey(name: 'tax_id')  String? taxId, @JsonKey(name: 'tax_settings')  Map<String, dynamic> taxSettings, @JsonKey(name: 'service_charge')  Map<String, dynamic> serviceCharge, @JsonKey(name: 'order_type_charges')  Map<String, dynamic> orderTypeCharges, @JsonKey(name: 'order_type_surcharge_settings')  Map<String, dynamic> orderTypeSurchargeSettings,  Map<String, dynamic> tips)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PosRestaurant() when $default != null:
return $default(_that.id,_that.name,_that.slug,_that.logoUrl,_that.primaryColor,_that.defaultCurrency,_that.taxId,_that.taxSettings,_that.serviceCharge,_that.orderTypeCharges,_that.orderTypeSurchargeSettings,_that.tips);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String? slug, @JsonKey(name: 'logo_url')  String? logoUrl, @JsonKey(name: 'primary_color')  String? primaryColor, @JsonKey(name: 'default_currency')  String? defaultCurrency, @JsonKey(name: 'tax_id')  String? taxId, @JsonKey(name: 'tax_settings')  Map<String, dynamic> taxSettings, @JsonKey(name: 'service_charge')  Map<String, dynamic> serviceCharge, @JsonKey(name: 'order_type_charges')  Map<String, dynamic> orderTypeCharges, @JsonKey(name: 'order_type_surcharge_settings')  Map<String, dynamic> orderTypeSurchargeSettings,  Map<String, dynamic> tips)  $default,) {final _that = this;
switch (_that) {
case _PosRestaurant():
return $default(_that.id,_that.name,_that.slug,_that.logoUrl,_that.primaryColor,_that.defaultCurrency,_that.taxId,_that.taxSettings,_that.serviceCharge,_that.orderTypeCharges,_that.orderTypeSurchargeSettings,_that.tips);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String? slug, @JsonKey(name: 'logo_url')  String? logoUrl, @JsonKey(name: 'primary_color')  String? primaryColor, @JsonKey(name: 'default_currency')  String? defaultCurrency, @JsonKey(name: 'tax_id')  String? taxId, @JsonKey(name: 'tax_settings')  Map<String, dynamic> taxSettings, @JsonKey(name: 'service_charge')  Map<String, dynamic> serviceCharge, @JsonKey(name: 'order_type_charges')  Map<String, dynamic> orderTypeCharges, @JsonKey(name: 'order_type_surcharge_settings')  Map<String, dynamic> orderTypeSurchargeSettings,  Map<String, dynamic> tips)?  $default,) {final _that = this;
switch (_that) {
case _PosRestaurant() when $default != null:
return $default(_that.id,_that.name,_that.slug,_that.logoUrl,_that.primaryColor,_that.defaultCurrency,_that.taxId,_that.taxSettings,_that.serviceCharge,_that.orderTypeCharges,_that.orderTypeSurchargeSettings,_that.tips);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PosRestaurant implements PosRestaurant {
  const _PosRestaurant({required this.id, required this.name, this.slug, @JsonKey(name: 'logo_url') this.logoUrl, @JsonKey(name: 'primary_color') this.primaryColor, @JsonKey(name: 'default_currency') this.defaultCurrency, @JsonKey(name: 'tax_id') this.taxId, @JsonKey(name: 'tax_settings') final  Map<String, dynamic> taxSettings = const <String, dynamic>{}, @JsonKey(name: 'service_charge') final  Map<String, dynamic> serviceCharge = const <String, dynamic>{}, @JsonKey(name: 'order_type_charges') final  Map<String, dynamic> orderTypeCharges = const <String, dynamic>{}, @JsonKey(name: 'order_type_surcharge_settings') final  Map<String, dynamic> orderTypeSurchargeSettings = const <String, dynamic>{}, final  Map<String, dynamic> tips = const <String, dynamic>{}}): _taxSettings = taxSettings,_serviceCharge = serviceCharge,_orderTypeCharges = orderTypeCharges,_orderTypeSurchargeSettings = orderTypeSurchargeSettings,_tips = tips;
  factory _PosRestaurant.fromJson(Map<String, dynamic> json) => _$PosRestaurantFromJson(json);

@override final  int id;
@override final  String name;
@override final  String? slug;
@override@JsonKey(name: 'logo_url') final  String? logoUrl;
@override@JsonKey(name: 'primary_color') final  String? primaryColor;
@override@JsonKey(name: 'default_currency') final  String? defaultCurrency;
@override@JsonKey(name: 'tax_id') final  String? taxId;
 final  Map<String, dynamic> _taxSettings;
@override@JsonKey(name: 'tax_settings') Map<String, dynamic> get taxSettings {
  if (_taxSettings is EqualUnmodifiableMapView) return _taxSettings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_taxSettings);
}

 final  Map<String, dynamic> _serviceCharge;
@override@JsonKey(name: 'service_charge') Map<String, dynamic> get serviceCharge {
  if (_serviceCharge is EqualUnmodifiableMapView) return _serviceCharge;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_serviceCharge);
}

 final  Map<String, dynamic> _orderTypeCharges;
@override@JsonKey(name: 'order_type_charges') Map<String, dynamic> get orderTypeCharges {
  if (_orderTypeCharges is EqualUnmodifiableMapView) return _orderTypeCharges;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_orderTypeCharges);
}

 final  Map<String, dynamic> _orderTypeSurchargeSettings;
@override@JsonKey(name: 'order_type_surcharge_settings') Map<String, dynamic> get orderTypeSurchargeSettings {
  if (_orderTypeSurchargeSettings is EqualUnmodifiableMapView) return _orderTypeSurchargeSettings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_orderTypeSurchargeSettings);
}

 final  Map<String, dynamic> _tips;
@override@JsonKey() Map<String, dynamic> get tips {
  if (_tips is EqualUnmodifiableMapView) return _tips;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_tips);
}


/// Create a copy of PosRestaurant
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PosRestaurantCopyWith<_PosRestaurant> get copyWith => __$PosRestaurantCopyWithImpl<_PosRestaurant>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PosRestaurantToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PosRestaurant&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.primaryColor, primaryColor) || other.primaryColor == primaryColor)&&(identical(other.defaultCurrency, defaultCurrency) || other.defaultCurrency == defaultCurrency)&&(identical(other.taxId, taxId) || other.taxId == taxId)&&const DeepCollectionEquality().equals(other._taxSettings, _taxSettings)&&const DeepCollectionEquality().equals(other._serviceCharge, _serviceCharge)&&const DeepCollectionEquality().equals(other._orderTypeCharges, _orderTypeCharges)&&const DeepCollectionEquality().equals(other._orderTypeSurchargeSettings, _orderTypeSurchargeSettings)&&const DeepCollectionEquality().equals(other._tips, _tips));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,slug,logoUrl,primaryColor,defaultCurrency,taxId,const DeepCollectionEquality().hash(_taxSettings),const DeepCollectionEquality().hash(_serviceCharge),const DeepCollectionEquality().hash(_orderTypeCharges),const DeepCollectionEquality().hash(_orderTypeSurchargeSettings),const DeepCollectionEquality().hash(_tips));

@override
String toString() {
  return 'PosRestaurant(id: $id, name: $name, slug: $slug, logoUrl: $logoUrl, primaryColor: $primaryColor, defaultCurrency: $defaultCurrency, taxId: $taxId, taxSettings: $taxSettings, serviceCharge: $serviceCharge, orderTypeCharges: $orderTypeCharges, orderTypeSurchargeSettings: $orderTypeSurchargeSettings, tips: $tips)';
}


}

/// @nodoc
abstract mixin class _$PosRestaurantCopyWith<$Res> implements $PosRestaurantCopyWith<$Res> {
  factory _$PosRestaurantCopyWith(_PosRestaurant value, $Res Function(_PosRestaurant) _then) = __$PosRestaurantCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String? slug,@JsonKey(name: 'logo_url') String? logoUrl,@JsonKey(name: 'primary_color') String? primaryColor,@JsonKey(name: 'default_currency') String? defaultCurrency,@JsonKey(name: 'tax_id') String? taxId,@JsonKey(name: 'tax_settings') Map<String, dynamic> taxSettings,@JsonKey(name: 'service_charge') Map<String, dynamic> serviceCharge,@JsonKey(name: 'order_type_charges') Map<String, dynamic> orderTypeCharges,@JsonKey(name: 'order_type_surcharge_settings') Map<String, dynamic> orderTypeSurchargeSettings, Map<String, dynamic> tips
});




}
/// @nodoc
class __$PosRestaurantCopyWithImpl<$Res>
    implements _$PosRestaurantCopyWith<$Res> {
  __$PosRestaurantCopyWithImpl(this._self, this._then);

  final _PosRestaurant _self;
  final $Res Function(_PosRestaurant) _then;

/// Create a copy of PosRestaurant
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? slug = freezed,Object? logoUrl = freezed,Object? primaryColor = freezed,Object? defaultCurrency = freezed,Object? taxId = freezed,Object? taxSettings = null,Object? serviceCharge = null,Object? orderTypeCharges = null,Object? orderTypeSurchargeSettings = null,Object? tips = null,}) {
  return _then(_PosRestaurant(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,slug: freezed == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String?,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,primaryColor: freezed == primaryColor ? _self.primaryColor : primaryColor // ignore: cast_nullable_to_non_nullable
as String?,defaultCurrency: freezed == defaultCurrency ? _self.defaultCurrency : defaultCurrency // ignore: cast_nullable_to_non_nullable
as String?,taxId: freezed == taxId ? _self.taxId : taxId // ignore: cast_nullable_to_non_nullable
as String?,taxSettings: null == taxSettings ? _self._taxSettings : taxSettings // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,serviceCharge: null == serviceCharge ? _self._serviceCharge : serviceCharge // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,orderTypeCharges: null == orderTypeCharges ? _self._orderTypeCharges : orderTypeCharges // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,orderTypeSurchargeSettings: null == orderTypeSurchargeSettings ? _self._orderTypeSurchargeSettings : orderTypeSurchargeSettings // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,tips: null == tips ? _self._tips : tips // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

// dart format on

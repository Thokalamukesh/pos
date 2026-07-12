// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pos_bootstrap.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PosBootstrap {

 PosRestaurant? get restaurant; BranchSummary? get branch;@JsonKey(name: 'receipt_settings') Map<String, dynamic> get receiptSettings;@JsonKey(name: 'popular_items') List<Map<String, dynamic>> get popularItems; List<Map<String, dynamic>> get categories; List<BranchSummary> get branches;@JsonKey(name: 'current_shift') Map<String, dynamic>? get currentShift;@JsonKey(name: 'require_shift_for_pos') bool get requireShiftForPos;@JsonKey(name: 'pos_blocked') bool get posBlocked;@JsonKey(name: 'pos_terminals') List<PosTerminal> get posTerminals; List<String> get permissions;@JsonKey(name: 'plan_features') List<String> get planFeatures; PosBootstrapSync? get sync;
/// Create a copy of PosBootstrap
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PosBootstrapCopyWith<PosBootstrap> get copyWith => _$PosBootstrapCopyWithImpl<PosBootstrap>(this as PosBootstrap, _$identity);

  /// Serializes this PosBootstrap to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PosBootstrap&&(identical(other.restaurant, restaurant) || other.restaurant == restaurant)&&(identical(other.branch, branch) || other.branch == branch)&&const DeepCollectionEquality().equals(other.receiptSettings, receiptSettings)&&const DeepCollectionEquality().equals(other.popularItems, popularItems)&&const DeepCollectionEquality().equals(other.categories, categories)&&const DeepCollectionEquality().equals(other.branches, branches)&&const DeepCollectionEquality().equals(other.currentShift, currentShift)&&(identical(other.requireShiftForPos, requireShiftForPos) || other.requireShiftForPos == requireShiftForPos)&&(identical(other.posBlocked, posBlocked) || other.posBlocked == posBlocked)&&const DeepCollectionEquality().equals(other.posTerminals, posTerminals)&&const DeepCollectionEquality().equals(other.permissions, permissions)&&const DeepCollectionEquality().equals(other.planFeatures, planFeatures)&&(identical(other.sync, sync) || other.sync == sync));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,restaurant,branch,const DeepCollectionEquality().hash(receiptSettings),const DeepCollectionEquality().hash(popularItems),const DeepCollectionEquality().hash(categories),const DeepCollectionEquality().hash(branches),const DeepCollectionEquality().hash(currentShift),requireShiftForPos,posBlocked,const DeepCollectionEquality().hash(posTerminals),const DeepCollectionEquality().hash(permissions),const DeepCollectionEquality().hash(planFeatures),sync);

@override
String toString() {
  return 'PosBootstrap(restaurant: $restaurant, branch: $branch, receiptSettings: $receiptSettings, popularItems: $popularItems, categories: $categories, branches: $branches, currentShift: $currentShift, requireShiftForPos: $requireShiftForPos, posBlocked: $posBlocked, posTerminals: $posTerminals, permissions: $permissions, planFeatures: $planFeatures, sync: $sync)';
}


}

/// @nodoc
abstract mixin class $PosBootstrapCopyWith<$Res>  {
  factory $PosBootstrapCopyWith(PosBootstrap value, $Res Function(PosBootstrap) _then) = _$PosBootstrapCopyWithImpl;
@useResult
$Res call({
 PosRestaurant? restaurant, BranchSummary? branch,@JsonKey(name: 'receipt_settings') Map<String, dynamic> receiptSettings,@JsonKey(name: 'popular_items') List<Map<String, dynamic>> popularItems, List<Map<String, dynamic>> categories, List<BranchSummary> branches,@JsonKey(name: 'current_shift') Map<String, dynamic>? currentShift,@JsonKey(name: 'require_shift_for_pos') bool requireShiftForPos,@JsonKey(name: 'pos_blocked') bool posBlocked,@JsonKey(name: 'pos_terminals') List<PosTerminal> posTerminals, List<String> permissions,@JsonKey(name: 'plan_features') List<String> planFeatures, PosBootstrapSync? sync
});


$PosRestaurantCopyWith<$Res>? get restaurant;$BranchSummaryCopyWith<$Res>? get branch;$PosBootstrapSyncCopyWith<$Res>? get sync;

}
/// @nodoc
class _$PosBootstrapCopyWithImpl<$Res>
    implements $PosBootstrapCopyWith<$Res> {
  _$PosBootstrapCopyWithImpl(this._self, this._then);

  final PosBootstrap _self;
  final $Res Function(PosBootstrap) _then;

/// Create a copy of PosBootstrap
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? restaurant = freezed,Object? branch = freezed,Object? receiptSettings = null,Object? popularItems = null,Object? categories = null,Object? branches = null,Object? currentShift = freezed,Object? requireShiftForPos = null,Object? posBlocked = null,Object? posTerminals = null,Object? permissions = null,Object? planFeatures = null,Object? sync = freezed,}) {
  return _then(_self.copyWith(
restaurant: freezed == restaurant ? _self.restaurant : restaurant // ignore: cast_nullable_to_non_nullable
as PosRestaurant?,branch: freezed == branch ? _self.branch : branch // ignore: cast_nullable_to_non_nullable
as BranchSummary?,receiptSettings: null == receiptSettings ? _self.receiptSettings : receiptSettings // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,popularItems: null == popularItems ? _self.popularItems : popularItems // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,branches: null == branches ? _self.branches : branches // ignore: cast_nullable_to_non_nullable
as List<BranchSummary>,currentShift: freezed == currentShift ? _self.currentShift : currentShift // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,requireShiftForPos: null == requireShiftForPos ? _self.requireShiftForPos : requireShiftForPos // ignore: cast_nullable_to_non_nullable
as bool,posBlocked: null == posBlocked ? _self.posBlocked : posBlocked // ignore: cast_nullable_to_non_nullable
as bool,posTerminals: null == posTerminals ? _self.posTerminals : posTerminals // ignore: cast_nullable_to_non_nullable
as List<PosTerminal>,permissions: null == permissions ? _self.permissions : permissions // ignore: cast_nullable_to_non_nullable
as List<String>,planFeatures: null == planFeatures ? _self.planFeatures : planFeatures // ignore: cast_nullable_to_non_nullable
as List<String>,sync: freezed == sync ? _self.sync : sync // ignore: cast_nullable_to_non_nullable
as PosBootstrapSync?,
  ));
}
/// Create a copy of PosBootstrap
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PosRestaurantCopyWith<$Res>? get restaurant {
    if (_self.restaurant == null) {
    return null;
  }

  return $PosRestaurantCopyWith<$Res>(_self.restaurant!, (value) {
    return _then(_self.copyWith(restaurant: value));
  });
}/// Create a copy of PosBootstrap
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BranchSummaryCopyWith<$Res>? get branch {
    if (_self.branch == null) {
    return null;
  }

  return $BranchSummaryCopyWith<$Res>(_self.branch!, (value) {
    return _then(_self.copyWith(branch: value));
  });
}/// Create a copy of PosBootstrap
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PosBootstrapSyncCopyWith<$Res>? get sync {
    if (_self.sync == null) {
    return null;
  }

  return $PosBootstrapSyncCopyWith<$Res>(_self.sync!, (value) {
    return _then(_self.copyWith(sync: value));
  });
}
}


/// Adds pattern-matching-related methods to [PosBootstrap].
extension PosBootstrapPatterns on PosBootstrap {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PosBootstrap value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PosBootstrap() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PosBootstrap value)  $default,){
final _that = this;
switch (_that) {
case _PosBootstrap():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PosBootstrap value)?  $default,){
final _that = this;
switch (_that) {
case _PosBootstrap() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PosRestaurant? restaurant,  BranchSummary? branch, @JsonKey(name: 'receipt_settings')  Map<String, dynamic> receiptSettings, @JsonKey(name: 'popular_items')  List<Map<String, dynamic>> popularItems,  List<Map<String, dynamic>> categories,  List<BranchSummary> branches, @JsonKey(name: 'current_shift')  Map<String, dynamic>? currentShift, @JsonKey(name: 'require_shift_for_pos')  bool requireShiftForPos, @JsonKey(name: 'pos_blocked')  bool posBlocked, @JsonKey(name: 'pos_terminals')  List<PosTerminal> posTerminals,  List<String> permissions, @JsonKey(name: 'plan_features')  List<String> planFeatures,  PosBootstrapSync? sync)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PosBootstrap() when $default != null:
return $default(_that.restaurant,_that.branch,_that.receiptSettings,_that.popularItems,_that.categories,_that.branches,_that.currentShift,_that.requireShiftForPos,_that.posBlocked,_that.posTerminals,_that.permissions,_that.planFeatures,_that.sync);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PosRestaurant? restaurant,  BranchSummary? branch, @JsonKey(name: 'receipt_settings')  Map<String, dynamic> receiptSettings, @JsonKey(name: 'popular_items')  List<Map<String, dynamic>> popularItems,  List<Map<String, dynamic>> categories,  List<BranchSummary> branches, @JsonKey(name: 'current_shift')  Map<String, dynamic>? currentShift, @JsonKey(name: 'require_shift_for_pos')  bool requireShiftForPos, @JsonKey(name: 'pos_blocked')  bool posBlocked, @JsonKey(name: 'pos_terminals')  List<PosTerminal> posTerminals,  List<String> permissions, @JsonKey(name: 'plan_features')  List<String> planFeatures,  PosBootstrapSync? sync)  $default,) {final _that = this;
switch (_that) {
case _PosBootstrap():
return $default(_that.restaurant,_that.branch,_that.receiptSettings,_that.popularItems,_that.categories,_that.branches,_that.currentShift,_that.requireShiftForPos,_that.posBlocked,_that.posTerminals,_that.permissions,_that.planFeatures,_that.sync);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PosRestaurant? restaurant,  BranchSummary? branch, @JsonKey(name: 'receipt_settings')  Map<String, dynamic> receiptSettings, @JsonKey(name: 'popular_items')  List<Map<String, dynamic>> popularItems,  List<Map<String, dynamic>> categories,  List<BranchSummary> branches, @JsonKey(name: 'current_shift')  Map<String, dynamic>? currentShift, @JsonKey(name: 'require_shift_for_pos')  bool requireShiftForPos, @JsonKey(name: 'pos_blocked')  bool posBlocked, @JsonKey(name: 'pos_terminals')  List<PosTerminal> posTerminals,  List<String> permissions, @JsonKey(name: 'plan_features')  List<String> planFeatures,  PosBootstrapSync? sync)?  $default,) {final _that = this;
switch (_that) {
case _PosBootstrap() when $default != null:
return $default(_that.restaurant,_that.branch,_that.receiptSettings,_that.popularItems,_that.categories,_that.branches,_that.currentShift,_that.requireShiftForPos,_that.posBlocked,_that.posTerminals,_that.permissions,_that.planFeatures,_that.sync);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PosBootstrap implements PosBootstrap {
  const _PosBootstrap({this.restaurant, this.branch, @JsonKey(name: 'receipt_settings') final  Map<String, dynamic> receiptSettings = const <String, dynamic>{}, @JsonKey(name: 'popular_items') final  List<Map<String, dynamic>> popularItems = const <Map<String, dynamic>>[], final  List<Map<String, dynamic>> categories = const <Map<String, dynamic>>[], final  List<BranchSummary> branches = const <BranchSummary>[], @JsonKey(name: 'current_shift') final  Map<String, dynamic>? currentShift, @JsonKey(name: 'require_shift_for_pos') this.requireShiftForPos = false, @JsonKey(name: 'pos_blocked') this.posBlocked = false, @JsonKey(name: 'pos_terminals') final  List<PosTerminal> posTerminals = const <PosTerminal>[], final  List<String> permissions = const <String>[], @JsonKey(name: 'plan_features') final  List<String> planFeatures = const <String>[], this.sync}): _receiptSettings = receiptSettings,_popularItems = popularItems,_categories = categories,_branches = branches,_currentShift = currentShift,_posTerminals = posTerminals,_permissions = permissions,_planFeatures = planFeatures;
  factory _PosBootstrap.fromJson(Map<String, dynamic> json) => _$PosBootstrapFromJson(json);

@override final  PosRestaurant? restaurant;
@override final  BranchSummary? branch;
 final  Map<String, dynamic> _receiptSettings;
@override@JsonKey(name: 'receipt_settings') Map<String, dynamic> get receiptSettings {
  if (_receiptSettings is EqualUnmodifiableMapView) return _receiptSettings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_receiptSettings);
}

 final  List<Map<String, dynamic>> _popularItems;
@override@JsonKey(name: 'popular_items') List<Map<String, dynamic>> get popularItems {
  if (_popularItems is EqualUnmodifiableListView) return _popularItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_popularItems);
}

 final  List<Map<String, dynamic>> _categories;
@override@JsonKey() List<Map<String, dynamic>> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}

 final  List<BranchSummary> _branches;
@override@JsonKey() List<BranchSummary> get branches {
  if (_branches is EqualUnmodifiableListView) return _branches;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_branches);
}

 final  Map<String, dynamic>? _currentShift;
@override@JsonKey(name: 'current_shift') Map<String, dynamic>? get currentShift {
  final value = _currentShift;
  if (value == null) return null;
  if (_currentShift is EqualUnmodifiableMapView) return _currentShift;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override@JsonKey(name: 'require_shift_for_pos') final  bool requireShiftForPos;
@override@JsonKey(name: 'pos_blocked') final  bool posBlocked;
 final  List<PosTerminal> _posTerminals;
@override@JsonKey(name: 'pos_terminals') List<PosTerminal> get posTerminals {
  if (_posTerminals is EqualUnmodifiableListView) return _posTerminals;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_posTerminals);
}

 final  List<String> _permissions;
@override@JsonKey() List<String> get permissions {
  if (_permissions is EqualUnmodifiableListView) return _permissions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_permissions);
}

 final  List<String> _planFeatures;
@override@JsonKey(name: 'plan_features') List<String> get planFeatures {
  if (_planFeatures is EqualUnmodifiableListView) return _planFeatures;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_planFeatures);
}

@override final  PosBootstrapSync? sync;

/// Create a copy of PosBootstrap
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PosBootstrapCopyWith<_PosBootstrap> get copyWith => __$PosBootstrapCopyWithImpl<_PosBootstrap>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PosBootstrapToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PosBootstrap&&(identical(other.restaurant, restaurant) || other.restaurant == restaurant)&&(identical(other.branch, branch) || other.branch == branch)&&const DeepCollectionEquality().equals(other._receiptSettings, _receiptSettings)&&const DeepCollectionEquality().equals(other._popularItems, _popularItems)&&const DeepCollectionEquality().equals(other._categories, _categories)&&const DeepCollectionEquality().equals(other._branches, _branches)&&const DeepCollectionEquality().equals(other._currentShift, _currentShift)&&(identical(other.requireShiftForPos, requireShiftForPos) || other.requireShiftForPos == requireShiftForPos)&&(identical(other.posBlocked, posBlocked) || other.posBlocked == posBlocked)&&const DeepCollectionEquality().equals(other._posTerminals, _posTerminals)&&const DeepCollectionEquality().equals(other._permissions, _permissions)&&const DeepCollectionEquality().equals(other._planFeatures, _planFeatures)&&(identical(other.sync, sync) || other.sync == sync));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,restaurant,branch,const DeepCollectionEquality().hash(_receiptSettings),const DeepCollectionEquality().hash(_popularItems),const DeepCollectionEquality().hash(_categories),const DeepCollectionEquality().hash(_branches),const DeepCollectionEquality().hash(_currentShift),requireShiftForPos,posBlocked,const DeepCollectionEquality().hash(_posTerminals),const DeepCollectionEquality().hash(_permissions),const DeepCollectionEquality().hash(_planFeatures),sync);

@override
String toString() {
  return 'PosBootstrap(restaurant: $restaurant, branch: $branch, receiptSettings: $receiptSettings, popularItems: $popularItems, categories: $categories, branches: $branches, currentShift: $currentShift, requireShiftForPos: $requireShiftForPos, posBlocked: $posBlocked, posTerminals: $posTerminals, permissions: $permissions, planFeatures: $planFeatures, sync: $sync)';
}


}

/// @nodoc
abstract mixin class _$PosBootstrapCopyWith<$Res> implements $PosBootstrapCopyWith<$Res> {
  factory _$PosBootstrapCopyWith(_PosBootstrap value, $Res Function(_PosBootstrap) _then) = __$PosBootstrapCopyWithImpl;
@override @useResult
$Res call({
 PosRestaurant? restaurant, BranchSummary? branch,@JsonKey(name: 'receipt_settings') Map<String, dynamic> receiptSettings,@JsonKey(name: 'popular_items') List<Map<String, dynamic>> popularItems, List<Map<String, dynamic>> categories, List<BranchSummary> branches,@JsonKey(name: 'current_shift') Map<String, dynamic>? currentShift,@JsonKey(name: 'require_shift_for_pos') bool requireShiftForPos,@JsonKey(name: 'pos_blocked') bool posBlocked,@JsonKey(name: 'pos_terminals') List<PosTerminal> posTerminals, List<String> permissions,@JsonKey(name: 'plan_features') List<String> planFeatures, PosBootstrapSync? sync
});


@override $PosRestaurantCopyWith<$Res>? get restaurant;@override $BranchSummaryCopyWith<$Res>? get branch;@override $PosBootstrapSyncCopyWith<$Res>? get sync;

}
/// @nodoc
class __$PosBootstrapCopyWithImpl<$Res>
    implements _$PosBootstrapCopyWith<$Res> {
  __$PosBootstrapCopyWithImpl(this._self, this._then);

  final _PosBootstrap _self;
  final $Res Function(_PosBootstrap) _then;

/// Create a copy of PosBootstrap
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? restaurant = freezed,Object? branch = freezed,Object? receiptSettings = null,Object? popularItems = null,Object? categories = null,Object? branches = null,Object? currentShift = freezed,Object? requireShiftForPos = null,Object? posBlocked = null,Object? posTerminals = null,Object? permissions = null,Object? planFeatures = null,Object? sync = freezed,}) {
  return _then(_PosBootstrap(
restaurant: freezed == restaurant ? _self.restaurant : restaurant // ignore: cast_nullable_to_non_nullable
as PosRestaurant?,branch: freezed == branch ? _self.branch : branch // ignore: cast_nullable_to_non_nullable
as BranchSummary?,receiptSettings: null == receiptSettings ? _self._receiptSettings : receiptSettings // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,popularItems: null == popularItems ? _self._popularItems : popularItems // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,branches: null == branches ? _self._branches : branches // ignore: cast_nullable_to_non_nullable
as List<BranchSummary>,currentShift: freezed == currentShift ? _self._currentShift : currentShift // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,requireShiftForPos: null == requireShiftForPos ? _self.requireShiftForPos : requireShiftForPos // ignore: cast_nullable_to_non_nullable
as bool,posBlocked: null == posBlocked ? _self.posBlocked : posBlocked // ignore: cast_nullable_to_non_nullable
as bool,posTerminals: null == posTerminals ? _self._posTerminals : posTerminals // ignore: cast_nullable_to_non_nullable
as List<PosTerminal>,permissions: null == permissions ? _self._permissions : permissions // ignore: cast_nullable_to_non_nullable
as List<String>,planFeatures: null == planFeatures ? _self._planFeatures : planFeatures // ignore: cast_nullable_to_non_nullable
as List<String>,sync: freezed == sync ? _self.sync : sync // ignore: cast_nullable_to_non_nullable
as PosBootstrapSync?,
  ));
}

/// Create a copy of PosBootstrap
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PosRestaurantCopyWith<$Res>? get restaurant {
    if (_self.restaurant == null) {
    return null;
  }

  return $PosRestaurantCopyWith<$Res>(_self.restaurant!, (value) {
    return _then(_self.copyWith(restaurant: value));
  });
}/// Create a copy of PosBootstrap
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BranchSummaryCopyWith<$Res>? get branch {
    if (_self.branch == null) {
    return null;
  }

  return $BranchSummaryCopyWith<$Res>(_self.branch!, (value) {
    return _then(_self.copyWith(branch: value));
  });
}/// Create a copy of PosBootstrap
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PosBootstrapSyncCopyWith<$Res>? get sync {
    if (_self.sync == null) {
    return null;
  }

  return $PosBootstrapSyncCopyWith<$Res>(_self.sync!, (value) {
    return _then(_self.copyWith(sync: value));
  });
}
}


/// @nodoc
mixin _$PosBootstrapSync {

@JsonKey(name: 'menu_revision') String? get menuRevision;@JsonKey(name: 'bootstrap_revision') String? get bootstrapRevision;
/// Create a copy of PosBootstrapSync
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PosBootstrapSyncCopyWith<PosBootstrapSync> get copyWith => _$PosBootstrapSyncCopyWithImpl<PosBootstrapSync>(this as PosBootstrapSync, _$identity);

  /// Serializes this PosBootstrapSync to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PosBootstrapSync&&(identical(other.menuRevision, menuRevision) || other.menuRevision == menuRevision)&&(identical(other.bootstrapRevision, bootstrapRevision) || other.bootstrapRevision == bootstrapRevision));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,menuRevision,bootstrapRevision);

@override
String toString() {
  return 'PosBootstrapSync(menuRevision: $menuRevision, bootstrapRevision: $bootstrapRevision)';
}


}

/// @nodoc
abstract mixin class $PosBootstrapSyncCopyWith<$Res>  {
  factory $PosBootstrapSyncCopyWith(PosBootstrapSync value, $Res Function(PosBootstrapSync) _then) = _$PosBootstrapSyncCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'menu_revision') String? menuRevision,@JsonKey(name: 'bootstrap_revision') String? bootstrapRevision
});




}
/// @nodoc
class _$PosBootstrapSyncCopyWithImpl<$Res>
    implements $PosBootstrapSyncCopyWith<$Res> {
  _$PosBootstrapSyncCopyWithImpl(this._self, this._then);

  final PosBootstrapSync _self;
  final $Res Function(PosBootstrapSync) _then;

/// Create a copy of PosBootstrapSync
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? menuRevision = freezed,Object? bootstrapRevision = freezed,}) {
  return _then(_self.copyWith(
menuRevision: freezed == menuRevision ? _self.menuRevision : menuRevision // ignore: cast_nullable_to_non_nullable
as String?,bootstrapRevision: freezed == bootstrapRevision ? _self.bootstrapRevision : bootstrapRevision // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PosBootstrapSync].
extension PosBootstrapSyncPatterns on PosBootstrapSync {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PosBootstrapSync value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PosBootstrapSync() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PosBootstrapSync value)  $default,){
final _that = this;
switch (_that) {
case _PosBootstrapSync():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PosBootstrapSync value)?  $default,){
final _that = this;
switch (_that) {
case _PosBootstrapSync() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'menu_revision')  String? menuRevision, @JsonKey(name: 'bootstrap_revision')  String? bootstrapRevision)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PosBootstrapSync() when $default != null:
return $default(_that.menuRevision,_that.bootstrapRevision);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'menu_revision')  String? menuRevision, @JsonKey(name: 'bootstrap_revision')  String? bootstrapRevision)  $default,) {final _that = this;
switch (_that) {
case _PosBootstrapSync():
return $default(_that.menuRevision,_that.bootstrapRevision);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'menu_revision')  String? menuRevision, @JsonKey(name: 'bootstrap_revision')  String? bootstrapRevision)?  $default,) {final _that = this;
switch (_that) {
case _PosBootstrapSync() when $default != null:
return $default(_that.menuRevision,_that.bootstrapRevision);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PosBootstrapSync implements PosBootstrapSync {
  const _PosBootstrapSync({@JsonKey(name: 'menu_revision') this.menuRevision, @JsonKey(name: 'bootstrap_revision') this.bootstrapRevision});
  factory _PosBootstrapSync.fromJson(Map<String, dynamic> json) => _$PosBootstrapSyncFromJson(json);

@override@JsonKey(name: 'menu_revision') final  String? menuRevision;
@override@JsonKey(name: 'bootstrap_revision') final  String? bootstrapRevision;

/// Create a copy of PosBootstrapSync
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PosBootstrapSyncCopyWith<_PosBootstrapSync> get copyWith => __$PosBootstrapSyncCopyWithImpl<_PosBootstrapSync>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PosBootstrapSyncToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PosBootstrapSync&&(identical(other.menuRevision, menuRevision) || other.menuRevision == menuRevision)&&(identical(other.bootstrapRevision, bootstrapRevision) || other.bootstrapRevision == bootstrapRevision));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,menuRevision,bootstrapRevision);

@override
String toString() {
  return 'PosBootstrapSync(menuRevision: $menuRevision, bootstrapRevision: $bootstrapRevision)';
}


}

/// @nodoc
abstract mixin class _$PosBootstrapSyncCopyWith<$Res> implements $PosBootstrapSyncCopyWith<$Res> {
  factory _$PosBootstrapSyncCopyWith(_PosBootstrapSync value, $Res Function(_PosBootstrapSync) _then) = __$PosBootstrapSyncCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'menu_revision') String? menuRevision,@JsonKey(name: 'bootstrap_revision') String? bootstrapRevision
});




}
/// @nodoc
class __$PosBootstrapSyncCopyWithImpl<$Res>
    implements _$PosBootstrapSyncCopyWith<$Res> {
  __$PosBootstrapSyncCopyWithImpl(this._self, this._then);

  final _PosBootstrapSync _self;
  final $Res Function(_PosBootstrapSync) _then;

/// Create a copy of PosBootstrapSync
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? menuRevision = freezed,Object? bootstrapRevision = freezed,}) {
  return _then(_PosBootstrapSync(
menuRevision: freezed == menuRevision ? _self.menuRevision : menuRevision // ignore: cast_nullable_to_non_nullable
as String?,bootstrapRevision: freezed == bootstrapRevision ? _self.bootstrapRevision : bootstrapRevision // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on

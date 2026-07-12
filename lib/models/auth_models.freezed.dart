// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AuthUser {

 int get id; String get name; String get email;@JsonKey(name: 'has_pos_pin') bool get hasPosPin;
/// Create a copy of AuthUser
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthUserCopyWith<AuthUser> get copyWith => _$AuthUserCopyWithImpl<AuthUser>(this as AuthUser, _$identity);

  /// Serializes this AuthUser to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthUser&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.hasPosPin, hasPosPin) || other.hasPosPin == hasPosPin));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,email,hasPosPin);

@override
String toString() {
  return 'AuthUser(id: $id, name: $name, email: $email, hasPosPin: $hasPosPin)';
}


}

/// @nodoc
abstract mixin class $AuthUserCopyWith<$Res>  {
  factory $AuthUserCopyWith(AuthUser value, $Res Function(AuthUser) _then) = _$AuthUserCopyWithImpl;
@useResult
$Res call({
 int id, String name, String email,@JsonKey(name: 'has_pos_pin') bool hasPosPin
});




}
/// @nodoc
class _$AuthUserCopyWithImpl<$Res>
    implements $AuthUserCopyWith<$Res> {
  _$AuthUserCopyWithImpl(this._self, this._then);

  final AuthUser _self;
  final $Res Function(AuthUser) _then;

/// Create a copy of AuthUser
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? email = null,Object? hasPosPin = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,hasPosPin: null == hasPosPin ? _self.hasPosPin : hasPosPin // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AuthUser].
extension AuthUserPatterns on AuthUser {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthUser value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthUser() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthUser value)  $default,){
final _that = this;
switch (_that) {
case _AuthUser():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthUser value)?  $default,){
final _that = this;
switch (_that) {
case _AuthUser() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String email, @JsonKey(name: 'has_pos_pin')  bool hasPosPin)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthUser() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.hasPosPin);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String email, @JsonKey(name: 'has_pos_pin')  bool hasPosPin)  $default,) {final _that = this;
switch (_that) {
case _AuthUser():
return $default(_that.id,_that.name,_that.email,_that.hasPosPin);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String email, @JsonKey(name: 'has_pos_pin')  bool hasPosPin)?  $default,) {final _that = this;
switch (_that) {
case _AuthUser() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.hasPosPin);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuthUser implements AuthUser {
  const _AuthUser({required this.id, required this.name, required this.email, @JsonKey(name: 'has_pos_pin') this.hasPosPin = false});
  factory _AuthUser.fromJson(Map<String, dynamic> json) => _$AuthUserFromJson(json);

@override final  int id;
@override final  String name;
@override final  String email;
@override@JsonKey(name: 'has_pos_pin') final  bool hasPosPin;

/// Create a copy of AuthUser
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthUserCopyWith<_AuthUser> get copyWith => __$AuthUserCopyWithImpl<_AuthUser>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuthUserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthUser&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.hasPosPin, hasPosPin) || other.hasPosPin == hasPosPin));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,email,hasPosPin);

@override
String toString() {
  return 'AuthUser(id: $id, name: $name, email: $email, hasPosPin: $hasPosPin)';
}


}

/// @nodoc
abstract mixin class _$AuthUserCopyWith<$Res> implements $AuthUserCopyWith<$Res> {
  factory _$AuthUserCopyWith(_AuthUser value, $Res Function(_AuthUser) _then) = __$AuthUserCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String email,@JsonKey(name: 'has_pos_pin') bool hasPosPin
});




}
/// @nodoc
class __$AuthUserCopyWithImpl<$Res>
    implements _$AuthUserCopyWith<$Res> {
  __$AuthUserCopyWithImpl(this._self, this._then);

  final _AuthUser _self;
  final $Res Function(_AuthUser) _then;

/// Create a copy of AuthUser
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? email = null,Object? hasPosPin = null,}) {
  return _then(_AuthUser(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,hasPosPin: null == hasPosPin ? _self.hasPosPin : hasPosPin // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$AuthSession {

 String get token;@JsonKey(name: 'token_type') String get tokenType; List<String> get abilities; AuthUser get user;@JsonKey(name: 'is_super_admin') bool get isSuperAdmin; List<RestaurantSummary> get restaurants;@JsonKey(name: 'current_restaurant') RestaurantSummary? get currentRestaurant;@JsonKey(name: 'current_branch') BranchSummary? get currentBranch; List<String> get permissions;@JsonKey(name: 'plan_features') List<String> get planFeatures;
/// Create a copy of AuthSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthSessionCopyWith<AuthSession> get copyWith => _$AuthSessionCopyWithImpl<AuthSession>(this as AuthSession, _$identity);

  /// Serializes this AuthSession to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthSession&&(identical(other.token, token) || other.token == token)&&(identical(other.tokenType, tokenType) || other.tokenType == tokenType)&&const DeepCollectionEquality().equals(other.abilities, abilities)&&(identical(other.user, user) || other.user == user)&&(identical(other.isSuperAdmin, isSuperAdmin) || other.isSuperAdmin == isSuperAdmin)&&const DeepCollectionEquality().equals(other.restaurants, restaurants)&&(identical(other.currentRestaurant, currentRestaurant) || other.currentRestaurant == currentRestaurant)&&(identical(other.currentBranch, currentBranch) || other.currentBranch == currentBranch)&&const DeepCollectionEquality().equals(other.permissions, permissions)&&const DeepCollectionEquality().equals(other.planFeatures, planFeatures));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,token,tokenType,const DeepCollectionEquality().hash(abilities),user,isSuperAdmin,const DeepCollectionEquality().hash(restaurants),currentRestaurant,currentBranch,const DeepCollectionEquality().hash(permissions),const DeepCollectionEquality().hash(planFeatures));

@override
String toString() {
  return 'AuthSession(token: $token, tokenType: $tokenType, abilities: $abilities, user: $user, isSuperAdmin: $isSuperAdmin, restaurants: $restaurants, currentRestaurant: $currentRestaurant, currentBranch: $currentBranch, permissions: $permissions, planFeatures: $planFeatures)';
}


}

/// @nodoc
abstract mixin class $AuthSessionCopyWith<$Res>  {
  factory $AuthSessionCopyWith(AuthSession value, $Res Function(AuthSession) _then) = _$AuthSessionCopyWithImpl;
@useResult
$Res call({
 String token,@JsonKey(name: 'token_type') String tokenType, List<String> abilities, AuthUser user,@JsonKey(name: 'is_super_admin') bool isSuperAdmin, List<RestaurantSummary> restaurants,@JsonKey(name: 'current_restaurant') RestaurantSummary? currentRestaurant,@JsonKey(name: 'current_branch') BranchSummary? currentBranch, List<String> permissions,@JsonKey(name: 'plan_features') List<String> planFeatures
});


$AuthUserCopyWith<$Res> get user;$RestaurantSummaryCopyWith<$Res>? get currentRestaurant;$BranchSummaryCopyWith<$Res>? get currentBranch;

}
/// @nodoc
class _$AuthSessionCopyWithImpl<$Res>
    implements $AuthSessionCopyWith<$Res> {
  _$AuthSessionCopyWithImpl(this._self, this._then);

  final AuthSession _self;
  final $Res Function(AuthSession) _then;

/// Create a copy of AuthSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? token = null,Object? tokenType = null,Object? abilities = null,Object? user = null,Object? isSuperAdmin = null,Object? restaurants = null,Object? currentRestaurant = freezed,Object? currentBranch = freezed,Object? permissions = null,Object? planFeatures = null,}) {
  return _then(_self.copyWith(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,tokenType: null == tokenType ? _self.tokenType : tokenType // ignore: cast_nullable_to_non_nullable
as String,abilities: null == abilities ? _self.abilities : abilities // ignore: cast_nullable_to_non_nullable
as List<String>,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as AuthUser,isSuperAdmin: null == isSuperAdmin ? _self.isSuperAdmin : isSuperAdmin // ignore: cast_nullable_to_non_nullable
as bool,restaurants: null == restaurants ? _self.restaurants : restaurants // ignore: cast_nullable_to_non_nullable
as List<RestaurantSummary>,currentRestaurant: freezed == currentRestaurant ? _self.currentRestaurant : currentRestaurant // ignore: cast_nullable_to_non_nullable
as RestaurantSummary?,currentBranch: freezed == currentBranch ? _self.currentBranch : currentBranch // ignore: cast_nullable_to_non_nullable
as BranchSummary?,permissions: null == permissions ? _self.permissions : permissions // ignore: cast_nullable_to_non_nullable
as List<String>,planFeatures: null == planFeatures ? _self.planFeatures : planFeatures // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}
/// Create a copy of AuthSession
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthUserCopyWith<$Res> get user {
  
  return $AuthUserCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}/// Create a copy of AuthSession
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RestaurantSummaryCopyWith<$Res>? get currentRestaurant {
    if (_self.currentRestaurant == null) {
    return null;
  }

  return $RestaurantSummaryCopyWith<$Res>(_self.currentRestaurant!, (value) {
    return _then(_self.copyWith(currentRestaurant: value));
  });
}/// Create a copy of AuthSession
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BranchSummaryCopyWith<$Res>? get currentBranch {
    if (_self.currentBranch == null) {
    return null;
  }

  return $BranchSummaryCopyWith<$Res>(_self.currentBranch!, (value) {
    return _then(_self.copyWith(currentBranch: value));
  });
}
}


/// Adds pattern-matching-related methods to [AuthSession].
extension AuthSessionPatterns on AuthSession {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthSession value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthSession() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthSession value)  $default,){
final _that = this;
switch (_that) {
case _AuthSession():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthSession value)?  $default,){
final _that = this;
switch (_that) {
case _AuthSession() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String token, @JsonKey(name: 'token_type')  String tokenType,  List<String> abilities,  AuthUser user, @JsonKey(name: 'is_super_admin')  bool isSuperAdmin,  List<RestaurantSummary> restaurants, @JsonKey(name: 'current_restaurant')  RestaurantSummary? currentRestaurant, @JsonKey(name: 'current_branch')  BranchSummary? currentBranch,  List<String> permissions, @JsonKey(name: 'plan_features')  List<String> planFeatures)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthSession() when $default != null:
return $default(_that.token,_that.tokenType,_that.abilities,_that.user,_that.isSuperAdmin,_that.restaurants,_that.currentRestaurant,_that.currentBranch,_that.permissions,_that.planFeatures);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String token, @JsonKey(name: 'token_type')  String tokenType,  List<String> abilities,  AuthUser user, @JsonKey(name: 'is_super_admin')  bool isSuperAdmin,  List<RestaurantSummary> restaurants, @JsonKey(name: 'current_restaurant')  RestaurantSummary? currentRestaurant, @JsonKey(name: 'current_branch')  BranchSummary? currentBranch,  List<String> permissions, @JsonKey(name: 'plan_features')  List<String> planFeatures)  $default,) {final _that = this;
switch (_that) {
case _AuthSession():
return $default(_that.token,_that.tokenType,_that.abilities,_that.user,_that.isSuperAdmin,_that.restaurants,_that.currentRestaurant,_that.currentBranch,_that.permissions,_that.planFeatures);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String token, @JsonKey(name: 'token_type')  String tokenType,  List<String> abilities,  AuthUser user, @JsonKey(name: 'is_super_admin')  bool isSuperAdmin,  List<RestaurantSummary> restaurants, @JsonKey(name: 'current_restaurant')  RestaurantSummary? currentRestaurant, @JsonKey(name: 'current_branch')  BranchSummary? currentBranch,  List<String> permissions, @JsonKey(name: 'plan_features')  List<String> planFeatures)?  $default,) {final _that = this;
switch (_that) {
case _AuthSession() when $default != null:
return $default(_that.token,_that.tokenType,_that.abilities,_that.user,_that.isSuperAdmin,_that.restaurants,_that.currentRestaurant,_that.currentBranch,_that.permissions,_that.planFeatures);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuthSession implements AuthSession {
  const _AuthSession({required this.token, @JsonKey(name: 'token_type') this.tokenType = 'Bearer', final  List<String> abilities = const <String>[], required this.user, @JsonKey(name: 'is_super_admin') this.isSuperAdmin = false, final  List<RestaurantSummary> restaurants = const <RestaurantSummary>[], @JsonKey(name: 'current_restaurant') this.currentRestaurant, @JsonKey(name: 'current_branch') this.currentBranch, final  List<String> permissions = const <String>[], @JsonKey(name: 'plan_features') final  List<String> planFeatures = const <String>[]}): _abilities = abilities,_restaurants = restaurants,_permissions = permissions,_planFeatures = planFeatures;
  factory _AuthSession.fromJson(Map<String, dynamic> json) => _$AuthSessionFromJson(json);

@override final  String token;
@override@JsonKey(name: 'token_type') final  String tokenType;
 final  List<String> _abilities;
@override@JsonKey() List<String> get abilities {
  if (_abilities is EqualUnmodifiableListView) return _abilities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_abilities);
}

@override final  AuthUser user;
@override@JsonKey(name: 'is_super_admin') final  bool isSuperAdmin;
 final  List<RestaurantSummary> _restaurants;
@override@JsonKey() List<RestaurantSummary> get restaurants {
  if (_restaurants is EqualUnmodifiableListView) return _restaurants;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_restaurants);
}

@override@JsonKey(name: 'current_restaurant') final  RestaurantSummary? currentRestaurant;
@override@JsonKey(name: 'current_branch') final  BranchSummary? currentBranch;
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


/// Create a copy of AuthSession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthSessionCopyWith<_AuthSession> get copyWith => __$AuthSessionCopyWithImpl<_AuthSession>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuthSessionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthSession&&(identical(other.token, token) || other.token == token)&&(identical(other.tokenType, tokenType) || other.tokenType == tokenType)&&const DeepCollectionEquality().equals(other._abilities, _abilities)&&(identical(other.user, user) || other.user == user)&&(identical(other.isSuperAdmin, isSuperAdmin) || other.isSuperAdmin == isSuperAdmin)&&const DeepCollectionEquality().equals(other._restaurants, _restaurants)&&(identical(other.currentRestaurant, currentRestaurant) || other.currentRestaurant == currentRestaurant)&&(identical(other.currentBranch, currentBranch) || other.currentBranch == currentBranch)&&const DeepCollectionEquality().equals(other._permissions, _permissions)&&const DeepCollectionEquality().equals(other._planFeatures, _planFeatures));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,token,tokenType,const DeepCollectionEquality().hash(_abilities),user,isSuperAdmin,const DeepCollectionEquality().hash(_restaurants),currentRestaurant,currentBranch,const DeepCollectionEquality().hash(_permissions),const DeepCollectionEquality().hash(_planFeatures));

@override
String toString() {
  return 'AuthSession(token: $token, tokenType: $tokenType, abilities: $abilities, user: $user, isSuperAdmin: $isSuperAdmin, restaurants: $restaurants, currentRestaurant: $currentRestaurant, currentBranch: $currentBranch, permissions: $permissions, planFeatures: $planFeatures)';
}


}

/// @nodoc
abstract mixin class _$AuthSessionCopyWith<$Res> implements $AuthSessionCopyWith<$Res> {
  factory _$AuthSessionCopyWith(_AuthSession value, $Res Function(_AuthSession) _then) = __$AuthSessionCopyWithImpl;
@override @useResult
$Res call({
 String token,@JsonKey(name: 'token_type') String tokenType, List<String> abilities, AuthUser user,@JsonKey(name: 'is_super_admin') bool isSuperAdmin, List<RestaurantSummary> restaurants,@JsonKey(name: 'current_restaurant') RestaurantSummary? currentRestaurant,@JsonKey(name: 'current_branch') BranchSummary? currentBranch, List<String> permissions,@JsonKey(name: 'plan_features') List<String> planFeatures
});


@override $AuthUserCopyWith<$Res> get user;@override $RestaurantSummaryCopyWith<$Res>? get currentRestaurant;@override $BranchSummaryCopyWith<$Res>? get currentBranch;

}
/// @nodoc
class __$AuthSessionCopyWithImpl<$Res>
    implements _$AuthSessionCopyWith<$Res> {
  __$AuthSessionCopyWithImpl(this._self, this._then);

  final _AuthSession _self;
  final $Res Function(_AuthSession) _then;

/// Create a copy of AuthSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? token = null,Object? tokenType = null,Object? abilities = null,Object? user = null,Object? isSuperAdmin = null,Object? restaurants = null,Object? currentRestaurant = freezed,Object? currentBranch = freezed,Object? permissions = null,Object? planFeatures = null,}) {
  return _then(_AuthSession(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,tokenType: null == tokenType ? _self.tokenType : tokenType // ignore: cast_nullable_to_non_nullable
as String,abilities: null == abilities ? _self._abilities : abilities // ignore: cast_nullable_to_non_nullable
as List<String>,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as AuthUser,isSuperAdmin: null == isSuperAdmin ? _self.isSuperAdmin : isSuperAdmin // ignore: cast_nullable_to_non_nullable
as bool,restaurants: null == restaurants ? _self._restaurants : restaurants // ignore: cast_nullable_to_non_nullable
as List<RestaurantSummary>,currentRestaurant: freezed == currentRestaurant ? _self.currentRestaurant : currentRestaurant // ignore: cast_nullable_to_non_nullable
as RestaurantSummary?,currentBranch: freezed == currentBranch ? _self.currentBranch : currentBranch // ignore: cast_nullable_to_non_nullable
as BranchSummary?,permissions: null == permissions ? _self._permissions : permissions // ignore: cast_nullable_to_non_nullable
as List<String>,planFeatures: null == planFeatures ? _self._planFeatures : planFeatures // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

/// Create a copy of AuthSession
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthUserCopyWith<$Res> get user {
  
  return $AuthUserCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}/// Create a copy of AuthSession
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RestaurantSummaryCopyWith<$Res>? get currentRestaurant {
    if (_self.currentRestaurant == null) {
    return null;
  }

  return $RestaurantSummaryCopyWith<$Res>(_self.currentRestaurant!, (value) {
    return _then(_self.copyWith(currentRestaurant: value));
  });
}/// Create a copy of AuthSession
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BranchSummaryCopyWith<$Res>? get currentBranch {
    if (_self.currentBranch == null) {
    return null;
  }

  return $BranchSummaryCopyWith<$Res>(_self.currentBranch!, (value) {
    return _then(_self.copyWith(currentBranch: value));
  });
}
}

// dart format on

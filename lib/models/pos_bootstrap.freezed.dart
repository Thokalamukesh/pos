// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pos_bootstrap.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PosBootstrap _$PosBootstrapFromJson(Map<String, dynamic> json) {
  return _PosBootstrap.fromJson(json);
}

/// @nodoc
mixin _$PosBootstrap {
  PosRestaurant? get restaurant => throw _privateConstructorUsedError;
  BranchSummary? get branch => throw _privateConstructorUsedError;
  @JsonKey(name: 'receipt_settings')
  Map<String, dynamic> get receiptSettings =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'popular_items')
  List<Map<String, dynamic>> get popularItems =>
      throw _privateConstructorUsedError;
  List<Map<String, dynamic>> get categories =>
      throw _privateConstructorUsedError;
  List<BranchSummary> get branches => throw _privateConstructorUsedError;
  @JsonKey(name: 'current_shift')
  Map<String, dynamic>? get currentShift => throw _privateConstructorUsedError;
  @JsonKey(name: 'require_shift_for_pos')
  bool get requireShiftForPos => throw _privateConstructorUsedError;
  @JsonKey(name: 'pos_blocked')
  bool get posBlocked => throw _privateConstructorUsedError;
  @JsonKey(name: 'pos_terminals')
  List<PosTerminal> get posTerminals => throw _privateConstructorUsedError;
  @JsonKey(readValue: _readLanguages)
  List<Object?> get languages => throw _privateConstructorUsedError;
  List<String> get permissions => throw _privateConstructorUsedError;
  @JsonKey(name: 'plan_features')
  List<String> get planFeatures => throw _privateConstructorUsedError;
  PosBootstrapSync? get sync => throw _privateConstructorUsedError;

  /// Serializes this PosBootstrap to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PosBootstrap
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PosBootstrapCopyWith<PosBootstrap> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PosBootstrapCopyWith<$Res> {
  factory $PosBootstrapCopyWith(
    PosBootstrap value,
    $Res Function(PosBootstrap) then,
  ) = _$PosBootstrapCopyWithImpl<$Res, PosBootstrap>;
  @useResult
  $Res call({
    PosRestaurant? restaurant,
    BranchSummary? branch,
    @JsonKey(name: 'receipt_settings') Map<String, dynamic> receiptSettings,
    @JsonKey(name: 'popular_items') List<Map<String, dynamic>> popularItems,
    List<Map<String, dynamic>> categories,
    List<BranchSummary> branches,
    @JsonKey(name: 'current_shift') Map<String, dynamic>? currentShift,
    @JsonKey(name: 'require_shift_for_pos') bool requireShiftForPos,
    @JsonKey(name: 'pos_blocked') bool posBlocked,
    @JsonKey(name: 'pos_terminals') List<PosTerminal> posTerminals,
    @JsonKey(readValue: _readLanguages) List<Object?> languages,
    List<String> permissions,
    @JsonKey(name: 'plan_features') List<String> planFeatures,
    PosBootstrapSync? sync,
  });

  $PosRestaurantCopyWith<$Res>? get restaurant;
  $BranchSummaryCopyWith<$Res>? get branch;
  $PosBootstrapSyncCopyWith<$Res>? get sync;
}

/// @nodoc
class _$PosBootstrapCopyWithImpl<$Res, $Val extends PosBootstrap>
    implements $PosBootstrapCopyWith<$Res> {
  _$PosBootstrapCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PosBootstrap
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? restaurant = freezed,
    Object? branch = freezed,
    Object? receiptSettings = null,
    Object? popularItems = null,
    Object? categories = null,
    Object? branches = null,
    Object? currentShift = freezed,
    Object? requireShiftForPos = null,
    Object? posBlocked = null,
    Object? posTerminals = null,
    Object? languages = null,
    Object? permissions = null,
    Object? planFeatures = null,
    Object? sync = freezed,
  }) {
    return _then(
      _value.copyWith(
            restaurant: freezed == restaurant
                ? _value.restaurant
                : restaurant // ignore: cast_nullable_to_non_nullable
                      as PosRestaurant?,
            branch: freezed == branch
                ? _value.branch
                : branch // ignore: cast_nullable_to_non_nullable
                      as BranchSummary?,
            receiptSettings: null == receiptSettings
                ? _value.receiptSettings
                : receiptSettings // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            popularItems: null == popularItems
                ? _value.popularItems
                : popularItems // ignore: cast_nullable_to_non_nullable
                      as List<Map<String, dynamic>>,
            categories: null == categories
                ? _value.categories
                : categories // ignore: cast_nullable_to_non_nullable
                      as List<Map<String, dynamic>>,
            branches: null == branches
                ? _value.branches
                : branches // ignore: cast_nullable_to_non_nullable
                      as List<BranchSummary>,
            currentShift: freezed == currentShift
                ? _value.currentShift
                : currentShift // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            requireShiftForPos: null == requireShiftForPos
                ? _value.requireShiftForPos
                : requireShiftForPos // ignore: cast_nullable_to_non_nullable
                      as bool,
            posBlocked: null == posBlocked
                ? _value.posBlocked
                : posBlocked // ignore: cast_nullable_to_non_nullable
                      as bool,
            posTerminals: null == posTerminals
                ? _value.posTerminals
                : posTerminals // ignore: cast_nullable_to_non_nullable
                      as List<PosTerminal>,
            languages: null == languages
                ? _value.languages
                : languages // ignore: cast_nullable_to_non_nullable
                      as List<Object?>,
            permissions: null == permissions
                ? _value.permissions
                : permissions // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            planFeatures: null == planFeatures
                ? _value.planFeatures
                : planFeatures // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            sync: freezed == sync
                ? _value.sync
                : sync // ignore: cast_nullable_to_non_nullable
                      as PosBootstrapSync?,
          )
          as $Val,
    );
  }

  /// Create a copy of PosBootstrap
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PosRestaurantCopyWith<$Res>? get restaurant {
    if (_value.restaurant == null) {
      return null;
    }

    return $PosRestaurantCopyWith<$Res>(_value.restaurant!, (value) {
      return _then(_value.copyWith(restaurant: value) as $Val);
    });
  }

  /// Create a copy of PosBootstrap
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BranchSummaryCopyWith<$Res>? get branch {
    if (_value.branch == null) {
      return null;
    }

    return $BranchSummaryCopyWith<$Res>(_value.branch!, (value) {
      return _then(_value.copyWith(branch: value) as $Val);
    });
  }

  /// Create a copy of PosBootstrap
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PosBootstrapSyncCopyWith<$Res>? get sync {
    if (_value.sync == null) {
      return null;
    }

    return $PosBootstrapSyncCopyWith<$Res>(_value.sync!, (value) {
      return _then(_value.copyWith(sync: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PosBootstrapImplCopyWith<$Res>
    implements $PosBootstrapCopyWith<$Res> {
  factory _$$PosBootstrapImplCopyWith(
    _$PosBootstrapImpl value,
    $Res Function(_$PosBootstrapImpl) then,
  ) = __$$PosBootstrapImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    PosRestaurant? restaurant,
    BranchSummary? branch,
    @JsonKey(name: 'receipt_settings') Map<String, dynamic> receiptSettings,
    @JsonKey(name: 'popular_items') List<Map<String, dynamic>> popularItems,
    List<Map<String, dynamic>> categories,
    List<BranchSummary> branches,
    @JsonKey(name: 'current_shift') Map<String, dynamic>? currentShift,
    @JsonKey(name: 'require_shift_for_pos') bool requireShiftForPos,
    @JsonKey(name: 'pos_blocked') bool posBlocked,
    @JsonKey(name: 'pos_terminals') List<PosTerminal> posTerminals,
    @JsonKey(readValue: _readLanguages) List<Object?> languages,
    List<String> permissions,
    @JsonKey(name: 'plan_features') List<String> planFeatures,
    PosBootstrapSync? sync,
  });

  @override
  $PosRestaurantCopyWith<$Res>? get restaurant;
  @override
  $BranchSummaryCopyWith<$Res>? get branch;
  @override
  $PosBootstrapSyncCopyWith<$Res>? get sync;
}

/// @nodoc
class __$$PosBootstrapImplCopyWithImpl<$Res>
    extends _$PosBootstrapCopyWithImpl<$Res, _$PosBootstrapImpl>
    implements _$$PosBootstrapImplCopyWith<$Res> {
  __$$PosBootstrapImplCopyWithImpl(
    _$PosBootstrapImpl _value,
    $Res Function(_$PosBootstrapImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PosBootstrap
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? restaurant = freezed,
    Object? branch = freezed,
    Object? receiptSettings = null,
    Object? popularItems = null,
    Object? categories = null,
    Object? branches = null,
    Object? currentShift = freezed,
    Object? requireShiftForPos = null,
    Object? posBlocked = null,
    Object? posTerminals = null,
    Object? languages = null,
    Object? permissions = null,
    Object? planFeatures = null,
    Object? sync = freezed,
  }) {
    return _then(
      _$PosBootstrapImpl(
        restaurant: freezed == restaurant
            ? _value.restaurant
            : restaurant // ignore: cast_nullable_to_non_nullable
                  as PosRestaurant?,
        branch: freezed == branch
            ? _value.branch
            : branch // ignore: cast_nullable_to_non_nullable
                  as BranchSummary?,
        receiptSettings: null == receiptSettings
            ? _value._receiptSettings
            : receiptSettings // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        popularItems: null == popularItems
            ? _value._popularItems
            : popularItems // ignore: cast_nullable_to_non_nullable
                  as List<Map<String, dynamic>>,
        categories: null == categories
            ? _value._categories
            : categories // ignore: cast_nullable_to_non_nullable
                  as List<Map<String, dynamic>>,
        branches: null == branches
            ? _value._branches
            : branches // ignore: cast_nullable_to_non_nullable
                  as List<BranchSummary>,
        currentShift: freezed == currentShift
            ? _value._currentShift
            : currentShift // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        requireShiftForPos: null == requireShiftForPos
            ? _value.requireShiftForPos
            : requireShiftForPos // ignore: cast_nullable_to_non_nullable
                  as bool,
        posBlocked: null == posBlocked
            ? _value.posBlocked
            : posBlocked // ignore: cast_nullable_to_non_nullable
                  as bool,
        posTerminals: null == posTerminals
            ? _value._posTerminals
            : posTerminals // ignore: cast_nullable_to_non_nullable
                  as List<PosTerminal>,
        languages: null == languages
            ? _value._languages
            : languages // ignore: cast_nullable_to_non_nullable
                  as List<Object?>,
        permissions: null == permissions
            ? _value._permissions
            : permissions // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        planFeatures: null == planFeatures
            ? _value._planFeatures
            : planFeatures // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        sync: freezed == sync
            ? _value.sync
            : sync // ignore: cast_nullable_to_non_nullable
                  as PosBootstrapSync?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PosBootstrapImpl implements _PosBootstrap {
  const _$PosBootstrapImpl({
    this.restaurant,
    this.branch,
    @JsonKey(name: 'receipt_settings')
    final Map<String, dynamic> receiptSettings = const <String, dynamic>{},
    @JsonKey(name: 'popular_items')
    final List<Map<String, dynamic>> popularItems =
        const <Map<String, dynamic>>[],
    final List<Map<String, dynamic>> categories =
        const <Map<String, dynamic>>[],
    final List<BranchSummary> branches = const <BranchSummary>[],
    @JsonKey(name: 'current_shift') final Map<String, dynamic>? currentShift,
    @JsonKey(name: 'require_shift_for_pos') this.requireShiftForPos = false,
    @JsonKey(name: 'pos_blocked') this.posBlocked = false,
    @JsonKey(name: 'pos_terminals')
    final List<PosTerminal> posTerminals = const <PosTerminal>[],
    @JsonKey(readValue: _readLanguages)
    final List<Object?> languages = const <Object?>[],
    final List<String> permissions = const <String>[],
    @JsonKey(name: 'plan_features')
    final List<String> planFeatures = const <String>[],
    this.sync,
  }) : _receiptSettings = receiptSettings,
       _popularItems = popularItems,
       _categories = categories,
       _branches = branches,
       _currentShift = currentShift,
       _posTerminals = posTerminals,
       _languages = languages,
       _permissions = permissions,
       _planFeatures = planFeatures;

  factory _$PosBootstrapImpl.fromJson(Map<String, dynamic> json) =>
      _$$PosBootstrapImplFromJson(json);

  @override
  final PosRestaurant? restaurant;
  @override
  final BranchSummary? branch;
  final Map<String, dynamic> _receiptSettings;
  @override
  @JsonKey(name: 'receipt_settings')
  Map<String, dynamic> get receiptSettings {
    if (_receiptSettings is EqualUnmodifiableMapView) return _receiptSettings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_receiptSettings);
  }

  final List<Map<String, dynamic>> _popularItems;
  @override
  @JsonKey(name: 'popular_items')
  List<Map<String, dynamic>> get popularItems {
    if (_popularItems is EqualUnmodifiableListView) return _popularItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_popularItems);
  }

  final List<Map<String, dynamic>> _categories;
  @override
  @JsonKey()
  List<Map<String, dynamic>> get categories {
    if (_categories is EqualUnmodifiableListView) return _categories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_categories);
  }

  final List<BranchSummary> _branches;
  @override
  @JsonKey()
  List<BranchSummary> get branches {
    if (_branches is EqualUnmodifiableListView) return _branches;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_branches);
  }

  final Map<String, dynamic>? _currentShift;
  @override
  @JsonKey(name: 'current_shift')
  Map<String, dynamic>? get currentShift {
    final value = _currentShift;
    if (value == null) return null;
    if (_currentShift is EqualUnmodifiableMapView) return _currentShift;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey(name: 'require_shift_for_pos')
  final bool requireShiftForPos;
  @override
  @JsonKey(name: 'pos_blocked')
  final bool posBlocked;
  final List<PosTerminal> _posTerminals;
  @override
  @JsonKey(name: 'pos_terminals')
  List<PosTerminal> get posTerminals {
    if (_posTerminals is EqualUnmodifiableListView) return _posTerminals;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_posTerminals);
  }

  final List<Object?> _languages;
  @override
  @JsonKey(readValue: _readLanguages)
  List<Object?> get languages {
    if (_languages is EqualUnmodifiableListView) return _languages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_languages);
  }

  final List<String> _permissions;
  @override
  @JsonKey()
  List<String> get permissions {
    if (_permissions is EqualUnmodifiableListView) return _permissions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_permissions);
  }

  final List<String> _planFeatures;
  @override
  @JsonKey(name: 'plan_features')
  List<String> get planFeatures {
    if (_planFeatures is EqualUnmodifiableListView) return _planFeatures;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_planFeatures);
  }

  @override
  final PosBootstrapSync? sync;

  @override
  String toString() {
    return 'PosBootstrap(restaurant: $restaurant, branch: $branch, receiptSettings: $receiptSettings, popularItems: $popularItems, categories: $categories, branches: $branches, currentShift: $currentShift, requireShiftForPos: $requireShiftForPos, posBlocked: $posBlocked, posTerminals: $posTerminals, languages: $languages, permissions: $permissions, planFeatures: $planFeatures, sync: $sync)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PosBootstrapImpl &&
            (identical(other.restaurant, restaurant) ||
                other.restaurant == restaurant) &&
            (identical(other.branch, branch) || other.branch == branch) &&
            const DeepCollectionEquality().equals(
              other._receiptSettings,
              _receiptSettings,
            ) &&
            const DeepCollectionEquality().equals(
              other._popularItems,
              _popularItems,
            ) &&
            const DeepCollectionEquality().equals(
              other._categories,
              _categories,
            ) &&
            const DeepCollectionEquality().equals(other._branches, _branches) &&
            const DeepCollectionEquality().equals(
              other._currentShift,
              _currentShift,
            ) &&
            (identical(other.requireShiftForPos, requireShiftForPos) ||
                other.requireShiftForPos == requireShiftForPos) &&
            (identical(other.posBlocked, posBlocked) ||
                other.posBlocked == posBlocked) &&
            const DeepCollectionEquality().equals(
              other._posTerminals,
              _posTerminals,
            ) &&
            const DeepCollectionEquality().equals(
              other._languages,
              _languages,
            ) &&
            const DeepCollectionEquality().equals(
              other._permissions,
              _permissions,
            ) &&
            const DeepCollectionEquality().equals(
              other._planFeatures,
              _planFeatures,
            ) &&
            (identical(other.sync, sync) || other.sync == sync));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    restaurant,
    branch,
    const DeepCollectionEquality().hash(_receiptSettings),
    const DeepCollectionEquality().hash(_popularItems),
    const DeepCollectionEquality().hash(_categories),
    const DeepCollectionEquality().hash(_branches),
    const DeepCollectionEquality().hash(_currentShift),
    requireShiftForPos,
    posBlocked,
    const DeepCollectionEquality().hash(_posTerminals),
    const DeepCollectionEquality().hash(_languages),
    const DeepCollectionEquality().hash(_permissions),
    const DeepCollectionEquality().hash(_planFeatures),
    sync,
  );

  /// Create a copy of PosBootstrap
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PosBootstrapImplCopyWith<_$PosBootstrapImpl> get copyWith =>
      __$$PosBootstrapImplCopyWithImpl<_$PosBootstrapImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PosBootstrapImplToJson(this);
  }
}

abstract class _PosBootstrap implements PosBootstrap {
  const factory _PosBootstrap({
    final PosRestaurant? restaurant,
    final BranchSummary? branch,
    @JsonKey(name: 'receipt_settings')
    final Map<String, dynamic> receiptSettings,
    @JsonKey(name: 'popular_items')
    final List<Map<String, dynamic>> popularItems,
    final List<Map<String, dynamic>> categories,
    final List<BranchSummary> branches,
    @JsonKey(name: 'current_shift') final Map<String, dynamic>? currentShift,
    @JsonKey(name: 'require_shift_for_pos') final bool requireShiftForPos,
    @JsonKey(name: 'pos_blocked') final bool posBlocked,
    @JsonKey(name: 'pos_terminals') final List<PosTerminal> posTerminals,
    @JsonKey(readValue: _readLanguages) final List<Object?> languages,
    final List<String> permissions,
    @JsonKey(name: 'plan_features') final List<String> planFeatures,
    final PosBootstrapSync? sync,
  }) = _$PosBootstrapImpl;

  factory _PosBootstrap.fromJson(Map<String, dynamic> json) =
      _$PosBootstrapImpl.fromJson;

  @override
  PosRestaurant? get restaurant;
  @override
  BranchSummary? get branch;
  @override
  @JsonKey(name: 'receipt_settings')
  Map<String, dynamic> get receiptSettings;
  @override
  @JsonKey(name: 'popular_items')
  List<Map<String, dynamic>> get popularItems;
  @override
  List<Map<String, dynamic>> get categories;
  @override
  List<BranchSummary> get branches;
  @override
  @JsonKey(name: 'current_shift')
  Map<String, dynamic>? get currentShift;
  @override
  @JsonKey(name: 'require_shift_for_pos')
  bool get requireShiftForPos;
  @override
  @JsonKey(name: 'pos_blocked')
  bool get posBlocked;
  @override
  @JsonKey(name: 'pos_terminals')
  List<PosTerminal> get posTerminals;
  @override
  @JsonKey(readValue: _readLanguages)
  List<Object?> get languages;
  @override
  List<String> get permissions;
  @override
  @JsonKey(name: 'plan_features')
  List<String> get planFeatures;
  @override
  PosBootstrapSync? get sync;

  /// Create a copy of PosBootstrap
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PosBootstrapImplCopyWith<_$PosBootstrapImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PosBootstrapSync _$PosBootstrapSyncFromJson(Map<String, dynamic> json) {
  return _PosBootstrapSync.fromJson(json);
}

/// @nodoc
mixin _$PosBootstrapSync {
  @JsonKey(name: 'menu_revision')
  String? get menuRevision => throw _privateConstructorUsedError;
  @JsonKey(name: 'bootstrap_revision')
  String? get bootstrapRevision => throw _privateConstructorUsedError;

  /// Serializes this PosBootstrapSync to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PosBootstrapSync
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PosBootstrapSyncCopyWith<PosBootstrapSync> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PosBootstrapSyncCopyWith<$Res> {
  factory $PosBootstrapSyncCopyWith(
    PosBootstrapSync value,
    $Res Function(PosBootstrapSync) then,
  ) = _$PosBootstrapSyncCopyWithImpl<$Res, PosBootstrapSync>;
  @useResult
  $Res call({
    @JsonKey(name: 'menu_revision') String? menuRevision,
    @JsonKey(name: 'bootstrap_revision') String? bootstrapRevision,
  });
}

/// @nodoc
class _$PosBootstrapSyncCopyWithImpl<$Res, $Val extends PosBootstrapSync>
    implements $PosBootstrapSyncCopyWith<$Res> {
  _$PosBootstrapSyncCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PosBootstrapSync
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? menuRevision = freezed,
    Object? bootstrapRevision = freezed,
  }) {
    return _then(
      _value.copyWith(
            menuRevision: freezed == menuRevision
                ? _value.menuRevision
                : menuRevision // ignore: cast_nullable_to_non_nullable
                      as String?,
            bootstrapRevision: freezed == bootstrapRevision
                ? _value.bootstrapRevision
                : bootstrapRevision // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PosBootstrapSyncImplCopyWith<$Res>
    implements $PosBootstrapSyncCopyWith<$Res> {
  factory _$$PosBootstrapSyncImplCopyWith(
    _$PosBootstrapSyncImpl value,
    $Res Function(_$PosBootstrapSyncImpl) then,
  ) = __$$PosBootstrapSyncImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'menu_revision') String? menuRevision,
    @JsonKey(name: 'bootstrap_revision') String? bootstrapRevision,
  });
}

/// @nodoc
class __$$PosBootstrapSyncImplCopyWithImpl<$Res>
    extends _$PosBootstrapSyncCopyWithImpl<$Res, _$PosBootstrapSyncImpl>
    implements _$$PosBootstrapSyncImplCopyWith<$Res> {
  __$$PosBootstrapSyncImplCopyWithImpl(
    _$PosBootstrapSyncImpl _value,
    $Res Function(_$PosBootstrapSyncImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PosBootstrapSync
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? menuRevision = freezed,
    Object? bootstrapRevision = freezed,
  }) {
    return _then(
      _$PosBootstrapSyncImpl(
        menuRevision: freezed == menuRevision
            ? _value.menuRevision
            : menuRevision // ignore: cast_nullable_to_non_nullable
                  as String?,
        bootstrapRevision: freezed == bootstrapRevision
            ? _value.bootstrapRevision
            : bootstrapRevision // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PosBootstrapSyncImpl implements _PosBootstrapSync {
  const _$PosBootstrapSyncImpl({
    @JsonKey(name: 'menu_revision') this.menuRevision,
    @JsonKey(name: 'bootstrap_revision') this.bootstrapRevision,
  });

  factory _$PosBootstrapSyncImpl.fromJson(Map<String, dynamic> json) =>
      _$$PosBootstrapSyncImplFromJson(json);

  @override
  @JsonKey(name: 'menu_revision')
  final String? menuRevision;
  @override
  @JsonKey(name: 'bootstrap_revision')
  final String? bootstrapRevision;

  @override
  String toString() {
    return 'PosBootstrapSync(menuRevision: $menuRevision, bootstrapRevision: $bootstrapRevision)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PosBootstrapSyncImpl &&
            (identical(other.menuRevision, menuRevision) ||
                other.menuRevision == menuRevision) &&
            (identical(other.bootstrapRevision, bootstrapRevision) ||
                other.bootstrapRevision == bootstrapRevision));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, menuRevision, bootstrapRevision);

  /// Create a copy of PosBootstrapSync
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PosBootstrapSyncImplCopyWith<_$PosBootstrapSyncImpl> get copyWith =>
      __$$PosBootstrapSyncImplCopyWithImpl<_$PosBootstrapSyncImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PosBootstrapSyncImplToJson(this);
  }
}

abstract class _PosBootstrapSync implements PosBootstrapSync {
  const factory _PosBootstrapSync({
    @JsonKey(name: 'menu_revision') final String? menuRevision,
    @JsonKey(name: 'bootstrap_revision') final String? bootstrapRevision,
  }) = _$PosBootstrapSyncImpl;

  factory _PosBootstrapSync.fromJson(Map<String, dynamic> json) =
      _$PosBootstrapSyncImpl.fromJson;

  @override
  @JsonKey(name: 'menu_revision')
  String? get menuRevision;
  @override
  @JsonKey(name: 'bootstrap_revision')
  String? get bootstrapRevision;

  /// Create a copy of PosBootstrapSync
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PosBootstrapSyncImplCopyWith<_$PosBootstrapSyncImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

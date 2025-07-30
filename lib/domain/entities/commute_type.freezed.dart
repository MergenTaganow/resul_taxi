// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'commute_type.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CommuteType _$CommuteTypeFromJson(Map<String, dynamic> json) {
  return _CommuteType.fromJson(json);
}

/// @nodoc
mixin _$CommuteType {
  int get id => throw _privateConstructorUsedError;
  String get section => throw _privateConstructorUsedError;
  String get key => throw _privateConstructorUsedError;
  String get value => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;

  /// Serializes this CommuteType to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CommuteType
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommuteTypeCopyWith<CommuteType> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommuteTypeCopyWith<$Res> {
  factory $CommuteTypeCopyWith(
          CommuteType value, $Res Function(CommuteType) then) =
      _$CommuteTypeCopyWithImpl<$Res, CommuteType>;
  @useResult
  $Res call(
      {int id,
      String section,
      String key,
      String value,
      String description,
      String type});
}

/// @nodoc
class _$CommuteTypeCopyWithImpl<$Res, $Val extends CommuteType>
    implements $CommuteTypeCopyWith<$Res> {
  _$CommuteTypeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommuteType
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? section = null,
    Object? key = null,
    Object? value = null,
    Object? description = null,
    Object? type = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      section: null == section
          ? _value.section
          : section // ignore: cast_nullable_to_non_nullable
              as String,
      key: null == key
          ? _value.key
          : key // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CommuteTypeImplCopyWith<$Res>
    implements $CommuteTypeCopyWith<$Res> {
  factory _$$CommuteTypeImplCopyWith(
          _$CommuteTypeImpl value, $Res Function(_$CommuteTypeImpl) then) =
      __$$CommuteTypeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String section,
      String key,
      String value,
      String description,
      String type});
}

/// @nodoc
class __$$CommuteTypeImplCopyWithImpl<$Res>
    extends _$CommuteTypeCopyWithImpl<$Res, _$CommuteTypeImpl>
    implements _$$CommuteTypeImplCopyWith<$Res> {
  __$$CommuteTypeImplCopyWithImpl(
      _$CommuteTypeImpl _value, $Res Function(_$CommuteTypeImpl) _then)
      : super(_value, _then);

  /// Create a copy of CommuteType
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? section = null,
    Object? key = null,
    Object? value = null,
    Object? description = null,
    Object? type = null,
  }) {
    return _then(_$CommuteTypeImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      section: null == section
          ? _value.section
          : section // ignore: cast_nullable_to_non_nullable
              as String,
      key: null == key
          ? _value.key
          : key // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CommuteTypeImpl implements _CommuteType {
  const _$CommuteTypeImpl(
      {required this.id,
      required this.section,
      required this.key,
      required this.value,
      required this.description,
      required this.type});

  factory _$CommuteTypeImpl.fromJson(Map<String, dynamic> json) =>
      _$$CommuteTypeImplFromJson(json);

  @override
  final int id;
  @override
  final String section;
  @override
  final String key;
  @override
  final String value;
  @override
  final String description;
  @override
  final String type;

  @override
  String toString() {
    return 'CommuteType(id: $id, section: $section, key: $key, value: $value, description: $description, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommuteTypeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.section, section) || other.section == section) &&
            (identical(other.key, key) || other.key == key) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.type, type) || other.type == type));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, section, key, value, description, type);

  /// Create a copy of CommuteType
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommuteTypeImplCopyWith<_$CommuteTypeImpl> get copyWith =>
      __$$CommuteTypeImplCopyWithImpl<_$CommuteTypeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CommuteTypeImplToJson(
      this,
    );
  }
}

abstract class _CommuteType implements CommuteType {
  const factory _CommuteType(
      {required final int id,
      required final String section,
      required final String key,
      required final String value,
      required final String description,
      required final String type}) = _$CommuteTypeImpl;

  factory _CommuteType.fromJson(Map<String, dynamic> json) =
      _$CommuteTypeImpl.fromJson;

  @override
  int get id;
  @override
  String get section;
  @override
  String get key;
  @override
  String get value;
  @override
  String get description;
  @override
  String get type;

  /// Create a copy of CommuteType
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommuteTypeImplCopyWith<_$CommuteTypeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

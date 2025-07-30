// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Order _$OrderFromJson(Map<String, dynamic> json) {
  return _Order.fromJson(json);
}

/// @nodoc
mixin _$Order {
  int get id => throw _privateConstructorUsedError;
  OrderStatus get status =>
      throw _privateConstructorUsedError; // Extended fields from socket DTO
  @JsonKey(name: 'district_slug')
  String? get districtSlug => throw _privateConstructorUsedError;
  @JsonKey(name: 'district_id')
  int? get districtId => throw _privateConstructorUsedError;
  @JsonKey(name: 'tarrif_id')
  int? get tarrifId => throw _privateConstructorUsedError;
  @JsonKey(name: 'tarrif_slug')
  String? get tarrifSlug => throw _privateConstructorUsedError;
  String? get phonenumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'driver_notified_time')
  String? get driverNotifiedTime => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'requested_address')
  String? get requestedAddress => throw _privateConstructorUsedError;
  @JsonKey(name: 'requested_time')
  String? get requestedTime => throw _privateConstructorUsedError;
  @NumConverter()
  @JsonKey(name: 'approx_price')
  num? get approxPrice => throw _privateConstructorUsedError;

  /// Serializes this Order to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderCopyWith<Order> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderCopyWith<$Res> {
  factory $OrderCopyWith(Order value, $Res Function(Order) then) =
      _$OrderCopyWithImpl<$Res, Order>;
  @useResult
  $Res call(
      {int id,
      OrderStatus status,
      @JsonKey(name: 'district_slug') String? districtSlug,
      @JsonKey(name: 'district_id') int? districtId,
      @JsonKey(name: 'tarrif_id') int? tarrifId,
      @JsonKey(name: 'tarrif_slug') String? tarrifSlug,
      String? phonenumber,
      @JsonKey(name: 'driver_notified_time') String? driverNotifiedTime,
      String? note,
      @JsonKey(name: 'created_at') String? createdAt,
      @JsonKey(name: 'requested_address') String? requestedAddress,
      @JsonKey(name: 'requested_time') String? requestedTime,
      @NumConverter() @JsonKey(name: 'approx_price') num? approxPrice});
}

/// @nodoc
class _$OrderCopyWithImpl<$Res, $Val extends Order>
    implements $OrderCopyWith<$Res> {
  _$OrderCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? status = null,
    Object? districtSlug = freezed,
    Object? districtId = freezed,
    Object? tarrifId = freezed,
    Object? tarrifSlug = freezed,
    Object? phonenumber = freezed,
    Object? driverNotifiedTime = freezed,
    Object? note = freezed,
    Object? createdAt = freezed,
    Object? requestedAddress = freezed,
    Object? requestedTime = freezed,
    Object? approxPrice = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as OrderStatus,
      districtSlug: freezed == districtSlug
          ? _value.districtSlug
          : districtSlug // ignore: cast_nullable_to_non_nullable
              as String?,
      districtId: freezed == districtId
          ? _value.districtId
          : districtId // ignore: cast_nullable_to_non_nullable
              as int?,
      tarrifId: freezed == tarrifId
          ? _value.tarrifId
          : tarrifId // ignore: cast_nullable_to_non_nullable
              as int?,
      tarrifSlug: freezed == tarrifSlug
          ? _value.tarrifSlug
          : tarrifSlug // ignore: cast_nullable_to_non_nullable
              as String?,
      phonenumber: freezed == phonenumber
          ? _value.phonenumber
          : phonenumber // ignore: cast_nullable_to_non_nullable
              as String?,
      driverNotifiedTime: freezed == driverNotifiedTime
          ? _value.driverNotifiedTime
          : driverNotifiedTime // ignore: cast_nullable_to_non_nullable
              as String?,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      requestedAddress: freezed == requestedAddress
          ? _value.requestedAddress
          : requestedAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      requestedTime: freezed == requestedTime
          ? _value.requestedTime
          : requestedTime // ignore: cast_nullable_to_non_nullable
              as String?,
      approxPrice: freezed == approxPrice
          ? _value.approxPrice
          : approxPrice // ignore: cast_nullable_to_non_nullable
              as num?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OrderImplCopyWith<$Res> implements $OrderCopyWith<$Res> {
  factory _$$OrderImplCopyWith(
          _$OrderImpl value, $Res Function(_$OrderImpl) then) =
      __$$OrderImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      OrderStatus status,
      @JsonKey(name: 'district_slug') String? districtSlug,
      @JsonKey(name: 'district_id') int? districtId,
      @JsonKey(name: 'tarrif_id') int? tarrifId,
      @JsonKey(name: 'tarrif_slug') String? tarrifSlug,
      String? phonenumber,
      @JsonKey(name: 'driver_notified_time') String? driverNotifiedTime,
      String? note,
      @JsonKey(name: 'created_at') String? createdAt,
      @JsonKey(name: 'requested_address') String? requestedAddress,
      @JsonKey(name: 'requested_time') String? requestedTime,
      @NumConverter() @JsonKey(name: 'approx_price') num? approxPrice});
}

/// @nodoc
class __$$OrderImplCopyWithImpl<$Res>
    extends _$OrderCopyWithImpl<$Res, _$OrderImpl>
    implements _$$OrderImplCopyWith<$Res> {
  __$$OrderImplCopyWithImpl(
      _$OrderImpl _value, $Res Function(_$OrderImpl) _then)
      : super(_value, _then);

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? status = null,
    Object? districtSlug = freezed,
    Object? districtId = freezed,
    Object? tarrifId = freezed,
    Object? tarrifSlug = freezed,
    Object? phonenumber = freezed,
    Object? driverNotifiedTime = freezed,
    Object? note = freezed,
    Object? createdAt = freezed,
    Object? requestedAddress = freezed,
    Object? requestedTime = freezed,
    Object? approxPrice = freezed,
  }) {
    return _then(_$OrderImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as OrderStatus,
      districtSlug: freezed == districtSlug
          ? _value.districtSlug
          : districtSlug // ignore: cast_nullable_to_non_nullable
              as String?,
      districtId: freezed == districtId
          ? _value.districtId
          : districtId // ignore: cast_nullable_to_non_nullable
              as int?,
      tarrifId: freezed == tarrifId
          ? _value.tarrifId
          : tarrifId // ignore: cast_nullable_to_non_nullable
              as int?,
      tarrifSlug: freezed == tarrifSlug
          ? _value.tarrifSlug
          : tarrifSlug // ignore: cast_nullable_to_non_nullable
              as String?,
      phonenumber: freezed == phonenumber
          ? _value.phonenumber
          : phonenumber // ignore: cast_nullable_to_non_nullable
              as String?,
      driverNotifiedTime: freezed == driverNotifiedTime
          ? _value.driverNotifiedTime
          : driverNotifiedTime // ignore: cast_nullable_to_non_nullable
              as String?,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      requestedAddress: freezed == requestedAddress
          ? _value.requestedAddress
          : requestedAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      requestedTime: freezed == requestedTime
          ? _value.requestedTime
          : requestedTime // ignore: cast_nullable_to_non_nullable
              as String?,
      approxPrice: freezed == approxPrice
          ? _value.approxPrice
          : approxPrice // ignore: cast_nullable_to_non_nullable
              as num?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OrderImpl implements _Order {
  const _$OrderImpl(
      {required this.id,
      required this.status,
      @JsonKey(name: 'district_slug') this.districtSlug,
      @JsonKey(name: 'district_id') this.districtId,
      @JsonKey(name: 'tarrif_id') this.tarrifId,
      @JsonKey(name: 'tarrif_slug') this.tarrifSlug,
      this.phonenumber,
      @JsonKey(name: 'driver_notified_time') this.driverNotifiedTime,
      this.note,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'requested_address') this.requestedAddress,
      @JsonKey(name: 'requested_time') this.requestedTime,
      @NumConverter() @JsonKey(name: 'approx_price') this.approxPrice});

  factory _$OrderImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderImplFromJson(json);

  @override
  final int id;
  @override
  final OrderStatus status;
// Extended fields from socket DTO
  @override
  @JsonKey(name: 'district_slug')
  final String? districtSlug;
  @override
  @JsonKey(name: 'district_id')
  final int? districtId;
  @override
  @JsonKey(name: 'tarrif_id')
  final int? tarrifId;
  @override
  @JsonKey(name: 'tarrif_slug')
  final String? tarrifSlug;
  @override
  final String? phonenumber;
  @override
  @JsonKey(name: 'driver_notified_time')
  final String? driverNotifiedTime;
  @override
  final String? note;
  @override
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @override
  @JsonKey(name: 'requested_address')
  final String? requestedAddress;
  @override
  @JsonKey(name: 'requested_time')
  final String? requestedTime;
  @override
  @NumConverter()
  @JsonKey(name: 'approx_price')
  final num? approxPrice;

  @override
  String toString() {
    return 'Order(id: $id, status: $status, districtSlug: $districtSlug, districtId: $districtId, tarrifId: $tarrifId, tarrifSlug: $tarrifSlug, phonenumber: $phonenumber, driverNotifiedTime: $driverNotifiedTime, note: $note, createdAt: $createdAt, requestedAddress: $requestedAddress, requestedTime: $requestedTime, approxPrice: $approxPrice)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.districtSlug, districtSlug) ||
                other.districtSlug == districtSlug) &&
            (identical(other.districtId, districtId) ||
                other.districtId == districtId) &&
            (identical(other.tarrifId, tarrifId) ||
                other.tarrifId == tarrifId) &&
            (identical(other.tarrifSlug, tarrifSlug) ||
                other.tarrifSlug == tarrifSlug) &&
            (identical(other.phonenumber, phonenumber) ||
                other.phonenumber == phonenumber) &&
            (identical(other.driverNotifiedTime, driverNotifiedTime) ||
                other.driverNotifiedTime == driverNotifiedTime) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.requestedAddress, requestedAddress) ||
                other.requestedAddress == requestedAddress) &&
            (identical(other.requestedTime, requestedTime) ||
                other.requestedTime == requestedTime) &&
            (identical(other.approxPrice, approxPrice) ||
                other.approxPrice == approxPrice));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      status,
      districtSlug,
      districtId,
      tarrifId,
      tarrifSlug,
      phonenumber,
      driverNotifiedTime,
      note,
      createdAt,
      requestedAddress,
      requestedTime,
      approxPrice);

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderImplCopyWith<_$OrderImpl> get copyWith =>
      __$$OrderImplCopyWithImpl<_$OrderImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OrderImplToJson(
      this,
    );
  }
}

abstract class _Order implements Order {
  const factory _Order(
      {required final int id,
      required final OrderStatus status,
      @JsonKey(name: 'district_slug') final String? districtSlug,
      @JsonKey(name: 'district_id') final int? districtId,
      @JsonKey(name: 'tarrif_id') final int? tarrifId,
      @JsonKey(name: 'tarrif_slug') final String? tarrifSlug,
      final String? phonenumber,
      @JsonKey(name: 'driver_notified_time') final String? driverNotifiedTime,
      final String? note,
      @JsonKey(name: 'created_at') final String? createdAt,
      @JsonKey(name: 'requested_address') final String? requestedAddress,
      @JsonKey(name: 'requested_time') final String? requestedTime,
      @NumConverter()
      @JsonKey(name: 'approx_price')
      final num? approxPrice}) = _$OrderImpl;

  factory _Order.fromJson(Map<String, dynamic> json) = _$OrderImpl.fromJson;

  @override
  int get id;
  @override
  OrderStatus get status; // Extended fields from socket DTO
  @override
  @JsonKey(name: 'district_slug')
  String? get districtSlug;
  @override
  @JsonKey(name: 'district_id')
  int? get districtId;
  @override
  @JsonKey(name: 'tarrif_id')
  int? get tarrifId;
  @override
  @JsonKey(name: 'tarrif_slug')
  String? get tarrifSlug;
  @override
  String? get phonenumber;
  @override
  @JsonKey(name: 'driver_notified_time')
  String? get driverNotifiedTime;
  @override
  String? get note;
  @override
  @JsonKey(name: 'created_at')
  String? get createdAt;
  @override
  @JsonKey(name: 'requested_address')
  String? get requestedAddress;
  @override
  @JsonKey(name: 'requested_time')
  String? get requestedTime;
  @override
  @NumConverter()
  @JsonKey(name: 'approx_price')
  num? get approxPrice;

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderImplCopyWith<_$OrderImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

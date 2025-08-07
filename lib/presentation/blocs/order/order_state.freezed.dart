// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$OrderState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(Order order, String? commuteTime) orderReceived,
    required TResult Function(Order order, bool freeOrder, String? commuteTime)
        orderAccepted,
    required TResult Function(Order order, String? commuteTime) orderInProgress,
    required TResult Function(Order order) orderCompleted,
    required TResult Function(String message) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(Order order, String? commuteTime)? orderReceived,
    TResult? Function(Order order, bool freeOrder, String? commuteTime)?
        orderAccepted,
    TResult? Function(Order order, String? commuteTime)? orderInProgress,
    TResult? Function(Order order)? orderCompleted,
    TResult? Function(String message)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(Order order, String? commuteTime)? orderReceived,
    TResult Function(Order order, bool freeOrder, String? commuteTime)?
        orderAccepted,
    TResult Function(Order order, String? commuteTime)? orderInProgress,
    TResult Function(Order order)? orderCompleted,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_OrderReceived value) orderReceived,
    required TResult Function(_OrderAccepted value) orderAccepted,
    required TResult Function(_OrderInProgress value) orderInProgress,
    required TResult Function(_OrderCompleted value) orderCompleted,
    required TResult Function(_Error value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_OrderReceived value)? orderReceived,
    TResult? Function(_OrderAccepted value)? orderAccepted,
    TResult? Function(_OrderInProgress value)? orderInProgress,
    TResult? Function(_OrderCompleted value)? orderCompleted,
    TResult? Function(_Error value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_OrderReceived value)? orderReceived,
    TResult Function(_OrderAccepted value)? orderAccepted,
    TResult Function(_OrderInProgress value)? orderInProgress,
    TResult Function(_OrderCompleted value)? orderCompleted,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderStateCopyWith<$Res> {
  factory $OrderStateCopyWith(
          OrderState value, $Res Function(OrderState) then) =
      _$OrderStateCopyWithImpl<$Res, OrderState>;
}

/// @nodoc
class _$OrderStateCopyWithImpl<$Res, $Val extends OrderState>
    implements $OrderStateCopyWith<$Res> {
  _$OrderStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrderState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$InitialImplCopyWith<$Res> {
  factory _$$InitialImplCopyWith(
          _$InitialImpl value, $Res Function(_$InitialImpl) then) =
      __$$InitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$InitialImplCopyWithImpl<$Res>
    extends _$OrderStateCopyWithImpl<$Res, _$InitialImpl>
    implements _$$InitialImplCopyWith<$Res> {
  __$$InitialImplCopyWithImpl(
      _$InitialImpl _value, $Res Function(_$InitialImpl) _then)
      : super(_value, _then);

  /// Create a copy of OrderState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$InitialImpl implements _Initial {
  const _$InitialImpl();

  @override
  String toString() {
    return 'OrderState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$InitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(Order order, String? commuteTime) orderReceived,
    required TResult Function(Order order, bool freeOrder, String? commuteTime)
        orderAccepted,
    required TResult Function(Order order, String? commuteTime) orderInProgress,
    required TResult Function(Order order) orderCompleted,
    required TResult Function(String message) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(Order order, String? commuteTime)? orderReceived,
    TResult? Function(Order order, bool freeOrder, String? commuteTime)?
        orderAccepted,
    TResult? Function(Order order, String? commuteTime)? orderInProgress,
    TResult? Function(Order order)? orderCompleted,
    TResult? Function(String message)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(Order order, String? commuteTime)? orderReceived,
    TResult Function(Order order, bool freeOrder, String? commuteTime)?
        orderAccepted,
    TResult Function(Order order, String? commuteTime)? orderInProgress,
    TResult Function(Order order)? orderCompleted,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_OrderReceived value) orderReceived,
    required TResult Function(_OrderAccepted value) orderAccepted,
    required TResult Function(_OrderInProgress value) orderInProgress,
    required TResult Function(_OrderCompleted value) orderCompleted,
    required TResult Function(_Error value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_OrderReceived value)? orderReceived,
    TResult? Function(_OrderAccepted value)? orderAccepted,
    TResult? Function(_OrderInProgress value)? orderInProgress,
    TResult? Function(_OrderCompleted value)? orderCompleted,
    TResult? Function(_Error value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_OrderReceived value)? orderReceived,
    TResult Function(_OrderAccepted value)? orderAccepted,
    TResult Function(_OrderInProgress value)? orderInProgress,
    TResult Function(_OrderCompleted value)? orderCompleted,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _Initial implements OrderState {
  const factory _Initial() = _$InitialImpl;
}

/// @nodoc
abstract class _$$LoadingImplCopyWith<$Res> {
  factory _$$LoadingImplCopyWith(
          _$LoadingImpl value, $Res Function(_$LoadingImpl) then) =
      __$$LoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LoadingImplCopyWithImpl<$Res>
    extends _$OrderStateCopyWithImpl<$Res, _$LoadingImpl>
    implements _$$LoadingImplCopyWith<$Res> {
  __$$LoadingImplCopyWithImpl(
      _$LoadingImpl _value, $Res Function(_$LoadingImpl) _then)
      : super(_value, _then);

  /// Create a copy of OrderState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$LoadingImpl implements _Loading {
  const _$LoadingImpl();

  @override
  String toString() {
    return 'OrderState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(Order order, String? commuteTime) orderReceived,
    required TResult Function(Order order, bool freeOrder, String? commuteTime)
        orderAccepted,
    required TResult Function(Order order, String? commuteTime) orderInProgress,
    required TResult Function(Order order) orderCompleted,
    required TResult Function(String message) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(Order order, String? commuteTime)? orderReceived,
    TResult? Function(Order order, bool freeOrder, String? commuteTime)?
        orderAccepted,
    TResult? Function(Order order, String? commuteTime)? orderInProgress,
    TResult? Function(Order order)? orderCompleted,
    TResult? Function(String message)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(Order order, String? commuteTime)? orderReceived,
    TResult Function(Order order, bool freeOrder, String? commuteTime)?
        orderAccepted,
    TResult Function(Order order, String? commuteTime)? orderInProgress,
    TResult Function(Order order)? orderCompleted,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_OrderReceived value) orderReceived,
    required TResult Function(_OrderAccepted value) orderAccepted,
    required TResult Function(_OrderInProgress value) orderInProgress,
    required TResult Function(_OrderCompleted value) orderCompleted,
    required TResult Function(_Error value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_OrderReceived value)? orderReceived,
    TResult? Function(_OrderAccepted value)? orderAccepted,
    TResult? Function(_OrderInProgress value)? orderInProgress,
    TResult? Function(_OrderCompleted value)? orderCompleted,
    TResult? Function(_Error value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_OrderReceived value)? orderReceived,
    TResult Function(_OrderAccepted value)? orderAccepted,
    TResult Function(_OrderInProgress value)? orderInProgress,
    TResult Function(_OrderCompleted value)? orderCompleted,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _Loading implements OrderState {
  const factory _Loading() = _$LoadingImpl;
}

/// @nodoc
abstract class _$$OrderReceivedImplCopyWith<$Res> {
  factory _$$OrderReceivedImplCopyWith(
          _$OrderReceivedImpl value, $Res Function(_$OrderReceivedImpl) then) =
      __$$OrderReceivedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Order order, String? commuteTime});

  $OrderCopyWith<$Res> get order;
}

/// @nodoc
class __$$OrderReceivedImplCopyWithImpl<$Res>
    extends _$OrderStateCopyWithImpl<$Res, _$OrderReceivedImpl>
    implements _$$OrderReceivedImplCopyWith<$Res> {
  __$$OrderReceivedImplCopyWithImpl(
      _$OrderReceivedImpl _value, $Res Function(_$OrderReceivedImpl) _then)
      : super(_value, _then);

  /// Create a copy of OrderState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? order = null,
    Object? commuteTime = freezed,
  }) {
    return _then(_$OrderReceivedImpl(
      null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as Order,
      commuteTime: freezed == commuteTime
          ? _value.commuteTime
          : commuteTime // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }

  /// Create a copy of OrderState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $OrderCopyWith<$Res> get order {
    return $OrderCopyWith<$Res>(_value.order, (value) {
      return _then(_value.copyWith(order: value));
    });
  }
}

/// @nodoc

class _$OrderReceivedImpl implements _OrderReceived {
  const _$OrderReceivedImpl(this.order, {this.commuteTime});

  @override
  final Order order;
  @override
  final String? commuteTime;

  @override
  String toString() {
    return 'OrderState.orderReceived(order: $order, commuteTime: $commuteTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderReceivedImpl &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.commuteTime, commuteTime) ||
                other.commuteTime == commuteTime));
  }

  @override
  int get hashCode => Object.hash(runtimeType, order, commuteTime);

  /// Create a copy of OrderState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderReceivedImplCopyWith<_$OrderReceivedImpl> get copyWith =>
      __$$OrderReceivedImplCopyWithImpl<_$OrderReceivedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(Order order, String? commuteTime) orderReceived,
    required TResult Function(Order order, bool freeOrder, String? commuteTime)
        orderAccepted,
    required TResult Function(Order order, String? commuteTime) orderInProgress,
    required TResult Function(Order order) orderCompleted,
    required TResult Function(String message) error,
  }) {
    return orderReceived(order, commuteTime);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(Order order, String? commuteTime)? orderReceived,
    TResult? Function(Order order, bool freeOrder, String? commuteTime)?
        orderAccepted,
    TResult? Function(Order order, String? commuteTime)? orderInProgress,
    TResult? Function(Order order)? orderCompleted,
    TResult? Function(String message)? error,
  }) {
    return orderReceived?.call(order, commuteTime);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(Order order, String? commuteTime)? orderReceived,
    TResult Function(Order order, bool freeOrder, String? commuteTime)?
        orderAccepted,
    TResult Function(Order order, String? commuteTime)? orderInProgress,
    TResult Function(Order order)? orderCompleted,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (orderReceived != null) {
      return orderReceived(order, commuteTime);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_OrderReceived value) orderReceived,
    required TResult Function(_OrderAccepted value) orderAccepted,
    required TResult Function(_OrderInProgress value) orderInProgress,
    required TResult Function(_OrderCompleted value) orderCompleted,
    required TResult Function(_Error value) error,
  }) {
    return orderReceived(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_OrderReceived value)? orderReceived,
    TResult? Function(_OrderAccepted value)? orderAccepted,
    TResult? Function(_OrderInProgress value)? orderInProgress,
    TResult? Function(_OrderCompleted value)? orderCompleted,
    TResult? Function(_Error value)? error,
  }) {
    return orderReceived?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_OrderReceived value)? orderReceived,
    TResult Function(_OrderAccepted value)? orderAccepted,
    TResult Function(_OrderInProgress value)? orderInProgress,
    TResult Function(_OrderCompleted value)? orderCompleted,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (orderReceived != null) {
      return orderReceived(this);
    }
    return orElse();
  }
}

abstract class _OrderReceived implements OrderState {
  const factory _OrderReceived(final Order order, {final String? commuteTime}) =
      _$OrderReceivedImpl;

  Order get order;
  String? get commuteTime;

  /// Create a copy of OrderState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderReceivedImplCopyWith<_$OrderReceivedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$OrderAcceptedImplCopyWith<$Res> {
  factory _$$OrderAcceptedImplCopyWith(
          _$OrderAcceptedImpl value, $Res Function(_$OrderAcceptedImpl) then) =
      __$$OrderAcceptedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Order order, bool freeOrder, String? commuteTime});

  $OrderCopyWith<$Res> get order;
}

/// @nodoc
class __$$OrderAcceptedImplCopyWithImpl<$Res>
    extends _$OrderStateCopyWithImpl<$Res, _$OrderAcceptedImpl>
    implements _$$OrderAcceptedImplCopyWith<$Res> {
  __$$OrderAcceptedImplCopyWithImpl(
      _$OrderAcceptedImpl _value, $Res Function(_$OrderAcceptedImpl) _then)
      : super(_value, _then);

  /// Create a copy of OrderState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? order = null,
    Object? freeOrder = null,
    Object? commuteTime = freezed,
  }) {
    return _then(_$OrderAcceptedImpl(
      null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as Order,
      null == freeOrder
          ? _value.freeOrder
          : freeOrder // ignore: cast_nullable_to_non_nullable
              as bool,
      commuteTime: freezed == commuteTime
          ? _value.commuteTime
          : commuteTime // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }

  /// Create a copy of OrderState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $OrderCopyWith<$Res> get order {
    return $OrderCopyWith<$Res>(_value.order, (value) {
      return _then(_value.copyWith(order: value));
    });
  }
}

/// @nodoc

class _$OrderAcceptedImpl implements _OrderAccepted {
  const _$OrderAcceptedImpl(this.order, this.freeOrder, {this.commuteTime});

  @override
  final Order order;
  @override
  final bool freeOrder;
  @override
  final String? commuteTime;

  @override
  String toString() {
    return 'OrderState.orderAccepted(order: $order, freeOrder: $freeOrder, commuteTime: $commuteTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderAcceptedImpl &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.freeOrder, freeOrder) ||
                other.freeOrder == freeOrder) &&
            (identical(other.commuteTime, commuteTime) ||
                other.commuteTime == commuteTime));
  }

  @override
  int get hashCode => Object.hash(runtimeType, order, freeOrder, commuteTime);

  /// Create a copy of OrderState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderAcceptedImplCopyWith<_$OrderAcceptedImpl> get copyWith =>
      __$$OrderAcceptedImplCopyWithImpl<_$OrderAcceptedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(Order order, String? commuteTime) orderReceived,
    required TResult Function(Order order, bool freeOrder, String? commuteTime)
        orderAccepted,
    required TResult Function(Order order, String? commuteTime) orderInProgress,
    required TResult Function(Order order) orderCompleted,
    required TResult Function(String message) error,
  }) {
    return orderAccepted(order, freeOrder, commuteTime);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(Order order, String? commuteTime)? orderReceived,
    TResult? Function(Order order, bool freeOrder, String? commuteTime)?
        orderAccepted,
    TResult? Function(Order order, String? commuteTime)? orderInProgress,
    TResult? Function(Order order)? orderCompleted,
    TResult? Function(String message)? error,
  }) {
    return orderAccepted?.call(order, freeOrder, commuteTime);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(Order order, String? commuteTime)? orderReceived,
    TResult Function(Order order, bool freeOrder, String? commuteTime)?
        orderAccepted,
    TResult Function(Order order, String? commuteTime)? orderInProgress,
    TResult Function(Order order)? orderCompleted,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (orderAccepted != null) {
      return orderAccepted(order, freeOrder, commuteTime);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_OrderReceived value) orderReceived,
    required TResult Function(_OrderAccepted value) orderAccepted,
    required TResult Function(_OrderInProgress value) orderInProgress,
    required TResult Function(_OrderCompleted value) orderCompleted,
    required TResult Function(_Error value) error,
  }) {
    return orderAccepted(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_OrderReceived value)? orderReceived,
    TResult? Function(_OrderAccepted value)? orderAccepted,
    TResult? Function(_OrderInProgress value)? orderInProgress,
    TResult? Function(_OrderCompleted value)? orderCompleted,
    TResult? Function(_Error value)? error,
  }) {
    return orderAccepted?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_OrderReceived value)? orderReceived,
    TResult Function(_OrderAccepted value)? orderAccepted,
    TResult Function(_OrderInProgress value)? orderInProgress,
    TResult Function(_OrderCompleted value)? orderCompleted,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (orderAccepted != null) {
      return orderAccepted(this);
    }
    return orElse();
  }
}

abstract class _OrderAccepted implements OrderState {
  const factory _OrderAccepted(final Order order, final bool freeOrder,
      {final String? commuteTime}) = _$OrderAcceptedImpl;

  Order get order;
  bool get freeOrder;
  String? get commuteTime;

  /// Create a copy of OrderState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderAcceptedImplCopyWith<_$OrderAcceptedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$OrderInProgressImplCopyWith<$Res> {
  factory _$$OrderInProgressImplCopyWith(_$OrderInProgressImpl value,
          $Res Function(_$OrderInProgressImpl) then) =
      __$$OrderInProgressImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Order order, String? commuteTime});

  $OrderCopyWith<$Res> get order;
}

/// @nodoc
class __$$OrderInProgressImplCopyWithImpl<$Res>
    extends _$OrderStateCopyWithImpl<$Res, _$OrderInProgressImpl>
    implements _$$OrderInProgressImplCopyWith<$Res> {
  __$$OrderInProgressImplCopyWithImpl(
      _$OrderInProgressImpl _value, $Res Function(_$OrderInProgressImpl) _then)
      : super(_value, _then);

  /// Create a copy of OrderState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? order = null,
    Object? commuteTime = freezed,
  }) {
    return _then(_$OrderInProgressImpl(
      null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as Order,
      commuteTime: freezed == commuteTime
          ? _value.commuteTime
          : commuteTime // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }

  /// Create a copy of OrderState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $OrderCopyWith<$Res> get order {
    return $OrderCopyWith<$Res>(_value.order, (value) {
      return _then(_value.copyWith(order: value));
    });
  }
}

/// @nodoc

class _$OrderInProgressImpl implements _OrderInProgress {
  const _$OrderInProgressImpl(this.order, {this.commuteTime});

  @override
  final Order order;
  @override
  final String? commuteTime;

  @override
  String toString() {
    return 'OrderState.orderInProgress(order: $order, commuteTime: $commuteTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderInProgressImpl &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.commuteTime, commuteTime) ||
                other.commuteTime == commuteTime));
  }

  @override
  int get hashCode => Object.hash(runtimeType, order, commuteTime);

  /// Create a copy of OrderState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderInProgressImplCopyWith<_$OrderInProgressImpl> get copyWith =>
      __$$OrderInProgressImplCopyWithImpl<_$OrderInProgressImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(Order order, String? commuteTime) orderReceived,
    required TResult Function(Order order, bool freeOrder, String? commuteTime)
        orderAccepted,
    required TResult Function(Order order, String? commuteTime) orderInProgress,
    required TResult Function(Order order) orderCompleted,
    required TResult Function(String message) error,
  }) {
    return orderInProgress(order, commuteTime);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(Order order, String? commuteTime)? orderReceived,
    TResult? Function(Order order, bool freeOrder, String? commuteTime)?
        orderAccepted,
    TResult? Function(Order order, String? commuteTime)? orderInProgress,
    TResult? Function(Order order)? orderCompleted,
    TResult? Function(String message)? error,
  }) {
    return orderInProgress?.call(order, commuteTime);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(Order order, String? commuteTime)? orderReceived,
    TResult Function(Order order, bool freeOrder, String? commuteTime)?
        orderAccepted,
    TResult Function(Order order, String? commuteTime)? orderInProgress,
    TResult Function(Order order)? orderCompleted,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (orderInProgress != null) {
      return orderInProgress(order, commuteTime);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_OrderReceived value) orderReceived,
    required TResult Function(_OrderAccepted value) orderAccepted,
    required TResult Function(_OrderInProgress value) orderInProgress,
    required TResult Function(_OrderCompleted value) orderCompleted,
    required TResult Function(_Error value) error,
  }) {
    return orderInProgress(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_OrderReceived value)? orderReceived,
    TResult? Function(_OrderAccepted value)? orderAccepted,
    TResult? Function(_OrderInProgress value)? orderInProgress,
    TResult? Function(_OrderCompleted value)? orderCompleted,
    TResult? Function(_Error value)? error,
  }) {
    return orderInProgress?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_OrderReceived value)? orderReceived,
    TResult Function(_OrderAccepted value)? orderAccepted,
    TResult Function(_OrderInProgress value)? orderInProgress,
    TResult Function(_OrderCompleted value)? orderCompleted,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (orderInProgress != null) {
      return orderInProgress(this);
    }
    return orElse();
  }
}

abstract class _OrderInProgress implements OrderState {
  const factory _OrderInProgress(final Order order,
      {final String? commuteTime}) = _$OrderInProgressImpl;

  Order get order;
  String? get commuteTime;

  /// Create a copy of OrderState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderInProgressImplCopyWith<_$OrderInProgressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$OrderCompletedImplCopyWith<$Res> {
  factory _$$OrderCompletedImplCopyWith(_$OrderCompletedImpl value,
          $Res Function(_$OrderCompletedImpl) then) =
      __$$OrderCompletedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Order order});

  $OrderCopyWith<$Res> get order;
}

/// @nodoc
class __$$OrderCompletedImplCopyWithImpl<$Res>
    extends _$OrderStateCopyWithImpl<$Res, _$OrderCompletedImpl>
    implements _$$OrderCompletedImplCopyWith<$Res> {
  __$$OrderCompletedImplCopyWithImpl(
      _$OrderCompletedImpl _value, $Res Function(_$OrderCompletedImpl) _then)
      : super(_value, _then);

  /// Create a copy of OrderState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? order = null,
  }) {
    return _then(_$OrderCompletedImpl(
      null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as Order,
    ));
  }

  /// Create a copy of OrderState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $OrderCopyWith<$Res> get order {
    return $OrderCopyWith<$Res>(_value.order, (value) {
      return _then(_value.copyWith(order: value));
    });
  }
}

/// @nodoc

class _$OrderCompletedImpl implements _OrderCompleted {
  const _$OrderCompletedImpl(this.order);

  @override
  final Order order;

  @override
  String toString() {
    return 'OrderState.orderCompleted(order: $order)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderCompletedImpl &&
            (identical(other.order, order) || other.order == order));
  }

  @override
  int get hashCode => Object.hash(runtimeType, order);

  /// Create a copy of OrderState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderCompletedImplCopyWith<_$OrderCompletedImpl> get copyWith =>
      __$$OrderCompletedImplCopyWithImpl<_$OrderCompletedImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(Order order, String? commuteTime) orderReceived,
    required TResult Function(Order order, bool freeOrder, String? commuteTime)
        orderAccepted,
    required TResult Function(Order order, String? commuteTime) orderInProgress,
    required TResult Function(Order order) orderCompleted,
    required TResult Function(String message) error,
  }) {
    return orderCompleted(order);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(Order order, String? commuteTime)? orderReceived,
    TResult? Function(Order order, bool freeOrder, String? commuteTime)?
        orderAccepted,
    TResult? Function(Order order, String? commuteTime)? orderInProgress,
    TResult? Function(Order order)? orderCompleted,
    TResult? Function(String message)? error,
  }) {
    return orderCompleted?.call(order);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(Order order, String? commuteTime)? orderReceived,
    TResult Function(Order order, bool freeOrder, String? commuteTime)?
        orderAccepted,
    TResult Function(Order order, String? commuteTime)? orderInProgress,
    TResult Function(Order order)? orderCompleted,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (orderCompleted != null) {
      return orderCompleted(order);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_OrderReceived value) orderReceived,
    required TResult Function(_OrderAccepted value) orderAccepted,
    required TResult Function(_OrderInProgress value) orderInProgress,
    required TResult Function(_OrderCompleted value) orderCompleted,
    required TResult Function(_Error value) error,
  }) {
    return orderCompleted(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_OrderReceived value)? orderReceived,
    TResult? Function(_OrderAccepted value)? orderAccepted,
    TResult? Function(_OrderInProgress value)? orderInProgress,
    TResult? Function(_OrderCompleted value)? orderCompleted,
    TResult? Function(_Error value)? error,
  }) {
    return orderCompleted?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_OrderReceived value)? orderReceived,
    TResult Function(_OrderAccepted value)? orderAccepted,
    TResult Function(_OrderInProgress value)? orderInProgress,
    TResult Function(_OrderCompleted value)? orderCompleted,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (orderCompleted != null) {
      return orderCompleted(this);
    }
    return orElse();
  }
}

abstract class _OrderCompleted implements OrderState {
  const factory _OrderCompleted(final Order order) = _$OrderCompletedImpl;

  Order get order;

  /// Create a copy of OrderState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderCompletedImplCopyWith<_$OrderCompletedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ErrorImplCopyWith<$Res> {
  factory _$$ErrorImplCopyWith(
          _$ErrorImpl value, $Res Function(_$ErrorImpl) then) =
      __$$ErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$ErrorImplCopyWithImpl<$Res>
    extends _$OrderStateCopyWithImpl<$Res, _$ErrorImpl>
    implements _$$ErrorImplCopyWith<$Res> {
  __$$ErrorImplCopyWithImpl(
      _$ErrorImpl _value, $Res Function(_$ErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of OrderState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$ErrorImpl(
      null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ErrorImpl implements _Error {
  const _$ErrorImpl(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'OrderState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of OrderState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      __$$ErrorImplCopyWithImpl<_$ErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(Order order, String? commuteTime) orderReceived,
    required TResult Function(Order order, bool freeOrder, String? commuteTime)
        orderAccepted,
    required TResult Function(Order order, String? commuteTime) orderInProgress,
    required TResult Function(Order order) orderCompleted,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(Order order, String? commuteTime)? orderReceived,
    TResult? Function(Order order, bool freeOrder, String? commuteTime)?
        orderAccepted,
    TResult? Function(Order order, String? commuteTime)? orderInProgress,
    TResult? Function(Order order)? orderCompleted,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(Order order, String? commuteTime)? orderReceived,
    TResult Function(Order order, bool freeOrder, String? commuteTime)?
        orderAccepted,
    TResult Function(Order order, String? commuteTime)? orderInProgress,
    TResult Function(Order order)? orderCompleted,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_OrderReceived value) orderReceived,
    required TResult Function(_OrderAccepted value) orderAccepted,
    required TResult Function(_OrderInProgress value) orderInProgress,
    required TResult Function(_OrderCompleted value) orderCompleted,
    required TResult Function(_Error value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_OrderReceived value)? orderReceived,
    TResult? Function(_OrderAccepted value)? orderAccepted,
    TResult? Function(_OrderInProgress value)? orderInProgress,
    TResult? Function(_OrderCompleted value)? orderCompleted,
    TResult? Function(_Error value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_OrderReceived value)? orderReceived,
    TResult Function(_OrderAccepted value)? orderAccepted,
    TResult Function(_OrderInProgress value)? orderInProgress,
    TResult Function(_OrderCompleted value)? orderCompleted,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _Error implements OrderState {
  const factory _Error(final String message) = _$ErrorImpl;

  String get message;

  /// Create a copy of OrderState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

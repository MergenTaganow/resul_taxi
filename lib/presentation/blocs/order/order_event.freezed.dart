// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$OrderEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Order order) orderReceived,
    required TResult Function(int orderId, Order order, String commuteTime)
        acceptOrder,
    required TResult Function(int orderId) rejectOrder,
    required TResult Function(int orderId, Order order) startOrder,
    required TResult Function(int orderId, Order order) completeOrder,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Order order)? orderReceived,
    TResult? Function(int orderId, Order order, String commuteTime)?
        acceptOrder,
    TResult? Function(int orderId)? rejectOrder,
    TResult? Function(int orderId, Order order)? startOrder,
    TResult? Function(int orderId, Order order)? completeOrder,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Order order)? orderReceived,
    TResult Function(int orderId, Order order, String commuteTime)? acceptOrder,
    TResult Function(int orderId)? rejectOrder,
    TResult Function(int orderId, Order order)? startOrder,
    TResult Function(int orderId, Order order)? completeOrder,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(OrderReceivedEvent value) orderReceived,
    required TResult Function(AcceptOrderEvent value) acceptOrder,
    required TResult Function(RejectOrderEvent value) rejectOrder,
    required TResult Function(StartOrderEvent value) startOrder,
    required TResult Function(CompleteOrderEvent value) completeOrder,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(OrderReceivedEvent value)? orderReceived,
    TResult? Function(AcceptOrderEvent value)? acceptOrder,
    TResult? Function(RejectOrderEvent value)? rejectOrder,
    TResult? Function(StartOrderEvent value)? startOrder,
    TResult? Function(CompleteOrderEvent value)? completeOrder,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(OrderReceivedEvent value)? orderReceived,
    TResult Function(AcceptOrderEvent value)? acceptOrder,
    TResult Function(RejectOrderEvent value)? rejectOrder,
    TResult Function(StartOrderEvent value)? startOrder,
    TResult Function(CompleteOrderEvent value)? completeOrder,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderEventCopyWith<$Res> {
  factory $OrderEventCopyWith(
          OrderEvent value, $Res Function(OrderEvent) then) =
      _$OrderEventCopyWithImpl<$Res, OrderEvent>;
}

/// @nodoc
class _$OrderEventCopyWithImpl<$Res, $Val extends OrderEvent>
    implements $OrderEventCopyWith<$Res> {
  _$OrderEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrderEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$OrderReceivedEventImplCopyWith<$Res> {
  factory _$$OrderReceivedEventImplCopyWith(_$OrderReceivedEventImpl value,
          $Res Function(_$OrderReceivedEventImpl) then) =
      __$$OrderReceivedEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Order order});

  $OrderCopyWith<$Res> get order;
}

/// @nodoc
class __$$OrderReceivedEventImplCopyWithImpl<$Res>
    extends _$OrderEventCopyWithImpl<$Res, _$OrderReceivedEventImpl>
    implements _$$OrderReceivedEventImplCopyWith<$Res> {
  __$$OrderReceivedEventImplCopyWithImpl(_$OrderReceivedEventImpl _value,
      $Res Function(_$OrderReceivedEventImpl) _then)
      : super(_value, _then);

  /// Create a copy of OrderEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? order = null,
  }) {
    return _then(_$OrderReceivedEventImpl(
      null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as Order,
    ));
  }

  /// Create a copy of OrderEvent
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

class _$OrderReceivedEventImpl implements OrderReceivedEvent {
  const _$OrderReceivedEventImpl(this.order);

  @override
  final Order order;

  @override
  String toString() {
    return 'OrderEvent.orderReceived(order: $order)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderReceivedEventImpl &&
            (identical(other.order, order) || other.order == order));
  }

  @override
  int get hashCode => Object.hash(runtimeType, order);

  /// Create a copy of OrderEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderReceivedEventImplCopyWith<_$OrderReceivedEventImpl> get copyWith =>
      __$$OrderReceivedEventImplCopyWithImpl<_$OrderReceivedEventImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Order order) orderReceived,
    required TResult Function(int orderId, Order order, String commuteTime)
        acceptOrder,
    required TResult Function(int orderId) rejectOrder,
    required TResult Function(int orderId, Order order) startOrder,
    required TResult Function(int orderId, Order order) completeOrder,
  }) {
    return orderReceived(order);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Order order)? orderReceived,
    TResult? Function(int orderId, Order order, String commuteTime)?
        acceptOrder,
    TResult? Function(int orderId)? rejectOrder,
    TResult? Function(int orderId, Order order)? startOrder,
    TResult? Function(int orderId, Order order)? completeOrder,
  }) {
    return orderReceived?.call(order);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Order order)? orderReceived,
    TResult Function(int orderId, Order order, String commuteTime)? acceptOrder,
    TResult Function(int orderId)? rejectOrder,
    TResult Function(int orderId, Order order)? startOrder,
    TResult Function(int orderId, Order order)? completeOrder,
    required TResult orElse(),
  }) {
    if (orderReceived != null) {
      return orderReceived(order);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(OrderReceivedEvent value) orderReceived,
    required TResult Function(AcceptOrderEvent value) acceptOrder,
    required TResult Function(RejectOrderEvent value) rejectOrder,
    required TResult Function(StartOrderEvent value) startOrder,
    required TResult Function(CompleteOrderEvent value) completeOrder,
  }) {
    return orderReceived(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(OrderReceivedEvent value)? orderReceived,
    TResult? Function(AcceptOrderEvent value)? acceptOrder,
    TResult? Function(RejectOrderEvent value)? rejectOrder,
    TResult? Function(StartOrderEvent value)? startOrder,
    TResult? Function(CompleteOrderEvent value)? completeOrder,
  }) {
    return orderReceived?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(OrderReceivedEvent value)? orderReceived,
    TResult Function(AcceptOrderEvent value)? acceptOrder,
    TResult Function(RejectOrderEvent value)? rejectOrder,
    TResult Function(StartOrderEvent value)? startOrder,
    TResult Function(CompleteOrderEvent value)? completeOrder,
    required TResult orElse(),
  }) {
    if (orderReceived != null) {
      return orderReceived(this);
    }
    return orElse();
  }
}

abstract class OrderReceivedEvent implements OrderEvent {
  const factory OrderReceivedEvent(final Order order) =
      _$OrderReceivedEventImpl;

  Order get order;

  /// Create a copy of OrderEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderReceivedEventImplCopyWith<_$OrderReceivedEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AcceptOrderEventImplCopyWith<$Res> {
  factory _$$AcceptOrderEventImplCopyWith(_$AcceptOrderEventImpl value,
          $Res Function(_$AcceptOrderEventImpl) then) =
      __$$AcceptOrderEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int orderId, Order order, String commuteTime});

  $OrderCopyWith<$Res> get order;
}

/// @nodoc
class __$$AcceptOrderEventImplCopyWithImpl<$Res>
    extends _$OrderEventCopyWithImpl<$Res, _$AcceptOrderEventImpl>
    implements _$$AcceptOrderEventImplCopyWith<$Res> {
  __$$AcceptOrderEventImplCopyWithImpl(_$AcceptOrderEventImpl _value,
      $Res Function(_$AcceptOrderEventImpl) _then)
      : super(_value, _then);

  /// Create a copy of OrderEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? orderId = null,
    Object? order = null,
    Object? commuteTime = null,
  }) {
    return _then(_$AcceptOrderEventImpl(
      null == orderId
          ? _value.orderId
          : orderId // ignore: cast_nullable_to_non_nullable
              as int,
      null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as Order,
      commuteTime: null == commuteTime
          ? _value.commuteTime
          : commuteTime // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }

  /// Create a copy of OrderEvent
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

class _$AcceptOrderEventImpl implements AcceptOrderEvent {
  const _$AcceptOrderEventImpl(this.orderId, this.order,
      {required this.commuteTime});

  @override
  final int orderId;
  @override
  final Order order;
  @override
  final String commuteTime;

  @override
  String toString() {
    return 'OrderEvent.acceptOrder(orderId: $orderId, order: $order, commuteTime: $commuteTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AcceptOrderEventImpl &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.commuteTime, commuteTime) ||
                other.commuteTime == commuteTime));
  }

  @override
  int get hashCode => Object.hash(runtimeType, orderId, order, commuteTime);

  /// Create a copy of OrderEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AcceptOrderEventImplCopyWith<_$AcceptOrderEventImpl> get copyWith =>
      __$$AcceptOrderEventImplCopyWithImpl<_$AcceptOrderEventImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Order order) orderReceived,
    required TResult Function(int orderId, Order order, String commuteTime)
        acceptOrder,
    required TResult Function(int orderId) rejectOrder,
    required TResult Function(int orderId, Order order) startOrder,
    required TResult Function(int orderId, Order order) completeOrder,
  }) {
    return acceptOrder(orderId, order, commuteTime);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Order order)? orderReceived,
    TResult? Function(int orderId, Order order, String commuteTime)?
        acceptOrder,
    TResult? Function(int orderId)? rejectOrder,
    TResult? Function(int orderId, Order order)? startOrder,
    TResult? Function(int orderId, Order order)? completeOrder,
  }) {
    return acceptOrder?.call(orderId, order, commuteTime);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Order order)? orderReceived,
    TResult Function(int orderId, Order order, String commuteTime)? acceptOrder,
    TResult Function(int orderId)? rejectOrder,
    TResult Function(int orderId, Order order)? startOrder,
    TResult Function(int orderId, Order order)? completeOrder,
    required TResult orElse(),
  }) {
    if (acceptOrder != null) {
      return acceptOrder(orderId, order, commuteTime);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(OrderReceivedEvent value) orderReceived,
    required TResult Function(AcceptOrderEvent value) acceptOrder,
    required TResult Function(RejectOrderEvent value) rejectOrder,
    required TResult Function(StartOrderEvent value) startOrder,
    required TResult Function(CompleteOrderEvent value) completeOrder,
  }) {
    return acceptOrder(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(OrderReceivedEvent value)? orderReceived,
    TResult? Function(AcceptOrderEvent value)? acceptOrder,
    TResult? Function(RejectOrderEvent value)? rejectOrder,
    TResult? Function(StartOrderEvent value)? startOrder,
    TResult? Function(CompleteOrderEvent value)? completeOrder,
  }) {
    return acceptOrder?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(OrderReceivedEvent value)? orderReceived,
    TResult Function(AcceptOrderEvent value)? acceptOrder,
    TResult Function(RejectOrderEvent value)? rejectOrder,
    TResult Function(StartOrderEvent value)? startOrder,
    TResult Function(CompleteOrderEvent value)? completeOrder,
    required TResult orElse(),
  }) {
    if (acceptOrder != null) {
      return acceptOrder(this);
    }
    return orElse();
  }
}

abstract class AcceptOrderEvent implements OrderEvent {
  const factory AcceptOrderEvent(final int orderId, final Order order,
      {required final String commuteTime}) = _$AcceptOrderEventImpl;

  int get orderId;
  Order get order;
  String get commuteTime;

  /// Create a copy of OrderEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AcceptOrderEventImplCopyWith<_$AcceptOrderEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RejectOrderEventImplCopyWith<$Res> {
  factory _$$RejectOrderEventImplCopyWith(_$RejectOrderEventImpl value,
          $Res Function(_$RejectOrderEventImpl) then) =
      __$$RejectOrderEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int orderId});
}

/// @nodoc
class __$$RejectOrderEventImplCopyWithImpl<$Res>
    extends _$OrderEventCopyWithImpl<$Res, _$RejectOrderEventImpl>
    implements _$$RejectOrderEventImplCopyWith<$Res> {
  __$$RejectOrderEventImplCopyWithImpl(_$RejectOrderEventImpl _value,
      $Res Function(_$RejectOrderEventImpl) _then)
      : super(_value, _then);

  /// Create a copy of OrderEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? orderId = null,
  }) {
    return _then(_$RejectOrderEventImpl(
      null == orderId
          ? _value.orderId
          : orderId // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$RejectOrderEventImpl implements RejectOrderEvent {
  const _$RejectOrderEventImpl(this.orderId);

  @override
  final int orderId;

  @override
  String toString() {
    return 'OrderEvent.rejectOrder(orderId: $orderId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RejectOrderEventImpl &&
            (identical(other.orderId, orderId) || other.orderId == orderId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, orderId);

  /// Create a copy of OrderEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RejectOrderEventImplCopyWith<_$RejectOrderEventImpl> get copyWith =>
      __$$RejectOrderEventImplCopyWithImpl<_$RejectOrderEventImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Order order) orderReceived,
    required TResult Function(int orderId, Order order, String commuteTime)
        acceptOrder,
    required TResult Function(int orderId) rejectOrder,
    required TResult Function(int orderId, Order order) startOrder,
    required TResult Function(int orderId, Order order) completeOrder,
  }) {
    return rejectOrder(orderId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Order order)? orderReceived,
    TResult? Function(int orderId, Order order, String commuteTime)?
        acceptOrder,
    TResult? Function(int orderId)? rejectOrder,
    TResult? Function(int orderId, Order order)? startOrder,
    TResult? Function(int orderId, Order order)? completeOrder,
  }) {
    return rejectOrder?.call(orderId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Order order)? orderReceived,
    TResult Function(int orderId, Order order, String commuteTime)? acceptOrder,
    TResult Function(int orderId)? rejectOrder,
    TResult Function(int orderId, Order order)? startOrder,
    TResult Function(int orderId, Order order)? completeOrder,
    required TResult orElse(),
  }) {
    if (rejectOrder != null) {
      return rejectOrder(orderId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(OrderReceivedEvent value) orderReceived,
    required TResult Function(AcceptOrderEvent value) acceptOrder,
    required TResult Function(RejectOrderEvent value) rejectOrder,
    required TResult Function(StartOrderEvent value) startOrder,
    required TResult Function(CompleteOrderEvent value) completeOrder,
  }) {
    return rejectOrder(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(OrderReceivedEvent value)? orderReceived,
    TResult? Function(AcceptOrderEvent value)? acceptOrder,
    TResult? Function(RejectOrderEvent value)? rejectOrder,
    TResult? Function(StartOrderEvent value)? startOrder,
    TResult? Function(CompleteOrderEvent value)? completeOrder,
  }) {
    return rejectOrder?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(OrderReceivedEvent value)? orderReceived,
    TResult Function(AcceptOrderEvent value)? acceptOrder,
    TResult Function(RejectOrderEvent value)? rejectOrder,
    TResult Function(StartOrderEvent value)? startOrder,
    TResult Function(CompleteOrderEvent value)? completeOrder,
    required TResult orElse(),
  }) {
    if (rejectOrder != null) {
      return rejectOrder(this);
    }
    return orElse();
  }
}

abstract class RejectOrderEvent implements OrderEvent {
  const factory RejectOrderEvent(final int orderId) = _$RejectOrderEventImpl;

  int get orderId;

  /// Create a copy of OrderEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RejectOrderEventImplCopyWith<_$RejectOrderEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$StartOrderEventImplCopyWith<$Res> {
  factory _$$StartOrderEventImplCopyWith(_$StartOrderEventImpl value,
          $Res Function(_$StartOrderEventImpl) then) =
      __$$StartOrderEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int orderId, Order order});

  $OrderCopyWith<$Res> get order;
}

/// @nodoc
class __$$StartOrderEventImplCopyWithImpl<$Res>
    extends _$OrderEventCopyWithImpl<$Res, _$StartOrderEventImpl>
    implements _$$StartOrderEventImplCopyWith<$Res> {
  __$$StartOrderEventImplCopyWithImpl(
      _$StartOrderEventImpl _value, $Res Function(_$StartOrderEventImpl) _then)
      : super(_value, _then);

  /// Create a copy of OrderEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? orderId = null,
    Object? order = null,
  }) {
    return _then(_$StartOrderEventImpl(
      null == orderId
          ? _value.orderId
          : orderId // ignore: cast_nullable_to_non_nullable
              as int,
      null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as Order,
    ));
  }

  /// Create a copy of OrderEvent
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

class _$StartOrderEventImpl implements StartOrderEvent {
  const _$StartOrderEventImpl(this.orderId, this.order);

  @override
  final int orderId;
  @override
  final Order order;

  @override
  String toString() {
    return 'OrderEvent.startOrder(orderId: $orderId, order: $order)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StartOrderEventImpl &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.order, order) || other.order == order));
  }

  @override
  int get hashCode => Object.hash(runtimeType, orderId, order);

  /// Create a copy of OrderEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StartOrderEventImplCopyWith<_$StartOrderEventImpl> get copyWith =>
      __$$StartOrderEventImplCopyWithImpl<_$StartOrderEventImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Order order) orderReceived,
    required TResult Function(int orderId, Order order, String commuteTime)
        acceptOrder,
    required TResult Function(int orderId) rejectOrder,
    required TResult Function(int orderId, Order order) startOrder,
    required TResult Function(int orderId, Order order) completeOrder,
  }) {
    return startOrder(orderId, order);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Order order)? orderReceived,
    TResult? Function(int orderId, Order order, String commuteTime)?
        acceptOrder,
    TResult? Function(int orderId)? rejectOrder,
    TResult? Function(int orderId, Order order)? startOrder,
    TResult? Function(int orderId, Order order)? completeOrder,
  }) {
    return startOrder?.call(orderId, order);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Order order)? orderReceived,
    TResult Function(int orderId, Order order, String commuteTime)? acceptOrder,
    TResult Function(int orderId)? rejectOrder,
    TResult Function(int orderId, Order order)? startOrder,
    TResult Function(int orderId, Order order)? completeOrder,
    required TResult orElse(),
  }) {
    if (startOrder != null) {
      return startOrder(orderId, order);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(OrderReceivedEvent value) orderReceived,
    required TResult Function(AcceptOrderEvent value) acceptOrder,
    required TResult Function(RejectOrderEvent value) rejectOrder,
    required TResult Function(StartOrderEvent value) startOrder,
    required TResult Function(CompleteOrderEvent value) completeOrder,
  }) {
    return startOrder(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(OrderReceivedEvent value)? orderReceived,
    TResult? Function(AcceptOrderEvent value)? acceptOrder,
    TResult? Function(RejectOrderEvent value)? rejectOrder,
    TResult? Function(StartOrderEvent value)? startOrder,
    TResult? Function(CompleteOrderEvent value)? completeOrder,
  }) {
    return startOrder?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(OrderReceivedEvent value)? orderReceived,
    TResult Function(AcceptOrderEvent value)? acceptOrder,
    TResult Function(RejectOrderEvent value)? rejectOrder,
    TResult Function(StartOrderEvent value)? startOrder,
    TResult Function(CompleteOrderEvent value)? completeOrder,
    required TResult orElse(),
  }) {
    if (startOrder != null) {
      return startOrder(this);
    }
    return orElse();
  }
}

abstract class StartOrderEvent implements OrderEvent {
  const factory StartOrderEvent(final int orderId, final Order order) =
      _$StartOrderEventImpl;

  int get orderId;
  Order get order;

  /// Create a copy of OrderEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StartOrderEventImplCopyWith<_$StartOrderEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CompleteOrderEventImplCopyWith<$Res> {
  factory _$$CompleteOrderEventImplCopyWith(_$CompleteOrderEventImpl value,
          $Res Function(_$CompleteOrderEventImpl) then) =
      __$$CompleteOrderEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int orderId, Order order});

  $OrderCopyWith<$Res> get order;
}

/// @nodoc
class __$$CompleteOrderEventImplCopyWithImpl<$Res>
    extends _$OrderEventCopyWithImpl<$Res, _$CompleteOrderEventImpl>
    implements _$$CompleteOrderEventImplCopyWith<$Res> {
  __$$CompleteOrderEventImplCopyWithImpl(_$CompleteOrderEventImpl _value,
      $Res Function(_$CompleteOrderEventImpl) _then)
      : super(_value, _then);

  /// Create a copy of OrderEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? orderId = null,
    Object? order = null,
  }) {
    return _then(_$CompleteOrderEventImpl(
      null == orderId
          ? _value.orderId
          : orderId // ignore: cast_nullable_to_non_nullable
              as int,
      null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as Order,
    ));
  }

  /// Create a copy of OrderEvent
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

class _$CompleteOrderEventImpl implements CompleteOrderEvent {
  const _$CompleteOrderEventImpl(this.orderId, this.order);

  @override
  final int orderId;
  @override
  final Order order;

  @override
  String toString() {
    return 'OrderEvent.completeOrder(orderId: $orderId, order: $order)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CompleteOrderEventImpl &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.order, order) || other.order == order));
  }

  @override
  int get hashCode => Object.hash(runtimeType, orderId, order);

  /// Create a copy of OrderEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CompleteOrderEventImplCopyWith<_$CompleteOrderEventImpl> get copyWith =>
      __$$CompleteOrderEventImplCopyWithImpl<_$CompleteOrderEventImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(Order order) orderReceived,
    required TResult Function(int orderId, Order order, String commuteTime)
        acceptOrder,
    required TResult Function(int orderId) rejectOrder,
    required TResult Function(int orderId, Order order) startOrder,
    required TResult Function(int orderId, Order order) completeOrder,
  }) {
    return completeOrder(orderId, order);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(Order order)? orderReceived,
    TResult? Function(int orderId, Order order, String commuteTime)?
        acceptOrder,
    TResult? Function(int orderId)? rejectOrder,
    TResult? Function(int orderId, Order order)? startOrder,
    TResult? Function(int orderId, Order order)? completeOrder,
  }) {
    return completeOrder?.call(orderId, order);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(Order order)? orderReceived,
    TResult Function(int orderId, Order order, String commuteTime)? acceptOrder,
    TResult Function(int orderId)? rejectOrder,
    TResult Function(int orderId, Order order)? startOrder,
    TResult Function(int orderId, Order order)? completeOrder,
    required TResult orElse(),
  }) {
    if (completeOrder != null) {
      return completeOrder(orderId, order);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(OrderReceivedEvent value) orderReceived,
    required TResult Function(AcceptOrderEvent value) acceptOrder,
    required TResult Function(RejectOrderEvent value) rejectOrder,
    required TResult Function(StartOrderEvent value) startOrder,
    required TResult Function(CompleteOrderEvent value) completeOrder,
  }) {
    return completeOrder(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(OrderReceivedEvent value)? orderReceived,
    TResult? Function(AcceptOrderEvent value)? acceptOrder,
    TResult? Function(RejectOrderEvent value)? rejectOrder,
    TResult? Function(StartOrderEvent value)? startOrder,
    TResult? Function(CompleteOrderEvent value)? completeOrder,
  }) {
    return completeOrder?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(OrderReceivedEvent value)? orderReceived,
    TResult Function(AcceptOrderEvent value)? acceptOrder,
    TResult Function(RejectOrderEvent value)? rejectOrder,
    TResult Function(StartOrderEvent value)? startOrder,
    TResult Function(CompleteOrderEvent value)? completeOrder,
    required TResult orElse(),
  }) {
    if (completeOrder != null) {
      return completeOrder(this);
    }
    return orElse();
  }
}

abstract class CompleteOrderEvent implements OrderEvent {
  const factory CompleteOrderEvent(final int orderId, final Order order) =
      _$CompleteOrderEventImpl;

  int get orderId;
  Order get order;

  /// Create a copy of OrderEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CompleteOrderEventImplCopyWith<_$CompleteOrderEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

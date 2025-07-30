// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'messages_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$MessagesEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadMessages,
    required TResult Function(Message message) messageReceived,
    required TResult Function(int messageId) markAsRead,
    required TResult Function() clearAll,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadMessages,
    TResult? Function(Message message)? messageReceived,
    TResult? Function(int messageId)? markAsRead,
    TResult? Function()? clearAll,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadMessages,
    TResult Function(Message message)? messageReceived,
    TResult Function(int messageId)? markAsRead,
    TResult Function()? clearAll,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadMessages value) loadMessages,
    required TResult Function(MessageReceived value) messageReceived,
    required TResult Function(MarkAsRead value) markAsRead,
    required TResult Function(ClearAll value) clearAll,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadMessages value)? loadMessages,
    TResult? Function(MessageReceived value)? messageReceived,
    TResult? Function(MarkAsRead value)? markAsRead,
    TResult? Function(ClearAll value)? clearAll,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadMessages value)? loadMessages,
    TResult Function(MessageReceived value)? messageReceived,
    TResult Function(MarkAsRead value)? markAsRead,
    TResult Function(ClearAll value)? clearAll,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessagesEventCopyWith<$Res> {
  factory $MessagesEventCopyWith(
          MessagesEvent value, $Res Function(MessagesEvent) then) =
      _$MessagesEventCopyWithImpl<$Res, MessagesEvent>;
}

/// @nodoc
class _$MessagesEventCopyWithImpl<$Res, $Val extends MessagesEvent>
    implements $MessagesEventCopyWith<$Res> {
  _$MessagesEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MessagesEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$LoadMessagesImplCopyWith<$Res> {
  factory _$$LoadMessagesImplCopyWith(
          _$LoadMessagesImpl value, $Res Function(_$LoadMessagesImpl) then) =
      __$$LoadMessagesImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LoadMessagesImplCopyWithImpl<$Res>
    extends _$MessagesEventCopyWithImpl<$Res, _$LoadMessagesImpl>
    implements _$$LoadMessagesImplCopyWith<$Res> {
  __$$LoadMessagesImplCopyWithImpl(
      _$LoadMessagesImpl _value, $Res Function(_$LoadMessagesImpl) _then)
      : super(_value, _then);

  /// Create a copy of MessagesEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$LoadMessagesImpl implements LoadMessages {
  const _$LoadMessagesImpl();

  @override
  String toString() {
    return 'MessagesEvent.loadMessages()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LoadMessagesImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadMessages,
    required TResult Function(Message message) messageReceived,
    required TResult Function(int messageId) markAsRead,
    required TResult Function() clearAll,
  }) {
    return loadMessages();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadMessages,
    TResult? Function(Message message)? messageReceived,
    TResult? Function(int messageId)? markAsRead,
    TResult? Function()? clearAll,
  }) {
    return loadMessages?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadMessages,
    TResult Function(Message message)? messageReceived,
    TResult Function(int messageId)? markAsRead,
    TResult Function()? clearAll,
    required TResult orElse(),
  }) {
    if (loadMessages != null) {
      return loadMessages();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadMessages value) loadMessages,
    required TResult Function(MessageReceived value) messageReceived,
    required TResult Function(MarkAsRead value) markAsRead,
    required TResult Function(ClearAll value) clearAll,
  }) {
    return loadMessages(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadMessages value)? loadMessages,
    TResult? Function(MessageReceived value)? messageReceived,
    TResult? Function(MarkAsRead value)? markAsRead,
    TResult? Function(ClearAll value)? clearAll,
  }) {
    return loadMessages?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadMessages value)? loadMessages,
    TResult Function(MessageReceived value)? messageReceived,
    TResult Function(MarkAsRead value)? markAsRead,
    TResult Function(ClearAll value)? clearAll,
    required TResult orElse(),
  }) {
    if (loadMessages != null) {
      return loadMessages(this);
    }
    return orElse();
  }
}

abstract class LoadMessages implements MessagesEvent {
  const factory LoadMessages() = _$LoadMessagesImpl;
}

/// @nodoc
abstract class _$$MessageReceivedImplCopyWith<$Res> {
  factory _$$MessageReceivedImplCopyWith(_$MessageReceivedImpl value,
          $Res Function(_$MessageReceivedImpl) then) =
      __$$MessageReceivedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Message message});

  $MessageCopyWith<$Res> get message;
}

/// @nodoc
class __$$MessageReceivedImplCopyWithImpl<$Res>
    extends _$MessagesEventCopyWithImpl<$Res, _$MessageReceivedImpl>
    implements _$$MessageReceivedImplCopyWith<$Res> {
  __$$MessageReceivedImplCopyWithImpl(
      _$MessageReceivedImpl _value, $Res Function(_$MessageReceivedImpl) _then)
      : super(_value, _then);

  /// Create a copy of MessagesEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$MessageReceivedImpl(
      null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as Message,
    ));
  }

  /// Create a copy of MessagesEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MessageCopyWith<$Res> get message {
    return $MessageCopyWith<$Res>(_value.message, (value) {
      return _then(_value.copyWith(message: value));
    });
  }
}

/// @nodoc

class _$MessageReceivedImpl implements MessageReceived {
  const _$MessageReceivedImpl(this.message);

  @override
  final Message message;

  @override
  String toString() {
    return 'MessagesEvent.messageReceived(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageReceivedImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of MessagesEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageReceivedImplCopyWith<_$MessageReceivedImpl> get copyWith =>
      __$$MessageReceivedImplCopyWithImpl<_$MessageReceivedImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadMessages,
    required TResult Function(Message message) messageReceived,
    required TResult Function(int messageId) markAsRead,
    required TResult Function() clearAll,
  }) {
    return messageReceived(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadMessages,
    TResult? Function(Message message)? messageReceived,
    TResult? Function(int messageId)? markAsRead,
    TResult? Function()? clearAll,
  }) {
    return messageReceived?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadMessages,
    TResult Function(Message message)? messageReceived,
    TResult Function(int messageId)? markAsRead,
    TResult Function()? clearAll,
    required TResult orElse(),
  }) {
    if (messageReceived != null) {
      return messageReceived(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadMessages value) loadMessages,
    required TResult Function(MessageReceived value) messageReceived,
    required TResult Function(MarkAsRead value) markAsRead,
    required TResult Function(ClearAll value) clearAll,
  }) {
    return messageReceived(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadMessages value)? loadMessages,
    TResult? Function(MessageReceived value)? messageReceived,
    TResult? Function(MarkAsRead value)? markAsRead,
    TResult? Function(ClearAll value)? clearAll,
  }) {
    return messageReceived?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadMessages value)? loadMessages,
    TResult Function(MessageReceived value)? messageReceived,
    TResult Function(MarkAsRead value)? markAsRead,
    TResult Function(ClearAll value)? clearAll,
    required TResult orElse(),
  }) {
    if (messageReceived != null) {
      return messageReceived(this);
    }
    return orElse();
  }
}

abstract class MessageReceived implements MessagesEvent {
  const factory MessageReceived(final Message message) = _$MessageReceivedImpl;

  Message get message;

  /// Create a copy of MessagesEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MessageReceivedImplCopyWith<_$MessageReceivedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$MarkAsReadImplCopyWith<$Res> {
  factory _$$MarkAsReadImplCopyWith(
          _$MarkAsReadImpl value, $Res Function(_$MarkAsReadImpl) then) =
      __$$MarkAsReadImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int messageId});
}

/// @nodoc
class __$$MarkAsReadImplCopyWithImpl<$Res>
    extends _$MessagesEventCopyWithImpl<$Res, _$MarkAsReadImpl>
    implements _$$MarkAsReadImplCopyWith<$Res> {
  __$$MarkAsReadImplCopyWithImpl(
      _$MarkAsReadImpl _value, $Res Function(_$MarkAsReadImpl) _then)
      : super(_value, _then);

  /// Create a copy of MessagesEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? messageId = null,
  }) {
    return _then(_$MarkAsReadImpl(
      null == messageId
          ? _value.messageId
          : messageId // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$MarkAsReadImpl implements MarkAsRead {
  const _$MarkAsReadImpl(this.messageId);

  @override
  final int messageId;

  @override
  String toString() {
    return 'MessagesEvent.markAsRead(messageId: $messageId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MarkAsReadImpl &&
            (identical(other.messageId, messageId) ||
                other.messageId == messageId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, messageId);

  /// Create a copy of MessagesEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MarkAsReadImplCopyWith<_$MarkAsReadImpl> get copyWith =>
      __$$MarkAsReadImplCopyWithImpl<_$MarkAsReadImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadMessages,
    required TResult Function(Message message) messageReceived,
    required TResult Function(int messageId) markAsRead,
    required TResult Function() clearAll,
  }) {
    return markAsRead(messageId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadMessages,
    TResult? Function(Message message)? messageReceived,
    TResult? Function(int messageId)? markAsRead,
    TResult? Function()? clearAll,
  }) {
    return markAsRead?.call(messageId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadMessages,
    TResult Function(Message message)? messageReceived,
    TResult Function(int messageId)? markAsRead,
    TResult Function()? clearAll,
    required TResult orElse(),
  }) {
    if (markAsRead != null) {
      return markAsRead(messageId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadMessages value) loadMessages,
    required TResult Function(MessageReceived value) messageReceived,
    required TResult Function(MarkAsRead value) markAsRead,
    required TResult Function(ClearAll value) clearAll,
  }) {
    return markAsRead(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadMessages value)? loadMessages,
    TResult? Function(MessageReceived value)? messageReceived,
    TResult? Function(MarkAsRead value)? markAsRead,
    TResult? Function(ClearAll value)? clearAll,
  }) {
    return markAsRead?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadMessages value)? loadMessages,
    TResult Function(MessageReceived value)? messageReceived,
    TResult Function(MarkAsRead value)? markAsRead,
    TResult Function(ClearAll value)? clearAll,
    required TResult orElse(),
  }) {
    if (markAsRead != null) {
      return markAsRead(this);
    }
    return orElse();
  }
}

abstract class MarkAsRead implements MessagesEvent {
  const factory MarkAsRead(final int messageId) = _$MarkAsReadImpl;

  int get messageId;

  /// Create a copy of MessagesEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MarkAsReadImplCopyWith<_$MarkAsReadImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ClearAllImplCopyWith<$Res> {
  factory _$$ClearAllImplCopyWith(
          _$ClearAllImpl value, $Res Function(_$ClearAllImpl) then) =
      __$$ClearAllImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$ClearAllImplCopyWithImpl<$Res>
    extends _$MessagesEventCopyWithImpl<$Res, _$ClearAllImpl>
    implements _$$ClearAllImplCopyWith<$Res> {
  __$$ClearAllImplCopyWithImpl(
      _$ClearAllImpl _value, $Res Function(_$ClearAllImpl) _then)
      : super(_value, _then);

  /// Create a copy of MessagesEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$ClearAllImpl implements ClearAll {
  const _$ClearAllImpl();

  @override
  String toString() {
    return 'MessagesEvent.clearAll()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$ClearAllImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadMessages,
    required TResult Function(Message message) messageReceived,
    required TResult Function(int messageId) markAsRead,
    required TResult Function() clearAll,
  }) {
    return clearAll();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadMessages,
    TResult? Function(Message message)? messageReceived,
    TResult? Function(int messageId)? markAsRead,
    TResult? Function()? clearAll,
  }) {
    return clearAll?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadMessages,
    TResult Function(Message message)? messageReceived,
    TResult Function(int messageId)? markAsRead,
    TResult Function()? clearAll,
    required TResult orElse(),
  }) {
    if (clearAll != null) {
      return clearAll();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadMessages value) loadMessages,
    required TResult Function(MessageReceived value) messageReceived,
    required TResult Function(MarkAsRead value) markAsRead,
    required TResult Function(ClearAll value) clearAll,
  }) {
    return clearAll(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadMessages value)? loadMessages,
    TResult? Function(MessageReceived value)? messageReceived,
    TResult? Function(MarkAsRead value)? markAsRead,
    TResult? Function(ClearAll value)? clearAll,
  }) {
    return clearAll?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadMessages value)? loadMessages,
    TResult Function(MessageReceived value)? messageReceived,
    TResult Function(MarkAsRead value)? markAsRead,
    TResult Function(ClearAll value)? clearAll,
    required TResult orElse(),
  }) {
    if (clearAll != null) {
      return clearAll(this);
    }
    return orElse();
  }
}

abstract class ClearAll implements MessagesEvent {
  const factory ClearAll() = _$ClearAllImpl;
}

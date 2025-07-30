import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:taxi_service/domain/entities/message.dart';

part 'messages_state.freezed.dart';

@freezed
class MessagesState with _$MessagesState {
  const factory MessagesState.initial() = _Initial;
  const factory MessagesState.loading() = _Loading;
  const factory MessagesState.loaded(List<Message> messages) = _Loaded;
  const factory MessagesState.error(String message) = _Error;
}

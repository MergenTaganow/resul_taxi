import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:taxi_service/domain/entities/message.dart';

part 'messages_event.freezed.dart';

@freezed
class MessagesEvent with _$MessagesEvent {
  const factory MessagesEvent.loadMessages() = LoadMessages;
  const factory MessagesEvent.messageReceived(Message message) =
      MessageReceived;
  const factory MessagesEvent.markAsRead(int messageId) = MarkAsRead;
  const factory MessagesEvent.clearAll() = ClearAll;
}

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taxi_service/core/network/socket_client.dart';
import 'package:taxi_service/core/network/api_client.dart';
import 'package:taxi_service/domain/entities/message.dart';
import 'package:taxi_service/presentation/blocs/messages/messages_event.dart';
import 'package:taxi_service/presentation/blocs/messages/messages_state.dart';

class MessagesBloc extends Bloc<MessagesEvent, MessagesState> {
  final SocketClient _socketClient;
  final ApiClient _apiClient;
  StreamSubscription<Message>? _messageSubscription;
  final List<Message> _messages = [];

  MessagesBloc(this._socketClient, this._apiClient)
      : super(const MessagesState.initial()) {
    on<LoadMessages>(_onLoadMessages);
    on<MessageReceived>(_onMessageReceived);
    on<MarkAsRead>(_onMarkAsRead);
    on<ClearAll>(_onClearAll);

    // Listen to socket messages
    _messageSubscription = _socketClient.messageStream.listen(
      (message) {
        add(MessagesEvent.messageReceived(message));
      },
    );
  }

  Future<void> _onLoadMessages(
      LoadMessages event, Emitter<MessagesState> emit) async {
    try {
      emit(const MessagesState.loading());

      // Fetch messages from API
      final messagesData = await _apiClient.getMessages();

      // Clear existing messages and add new ones from API
      _messages.clear();

      for (final messageData in messagesData) {
        try {
          final message = Message(
            id: messageData['id'] as int,
            title: messageData['title'] as String? ?? 'System',
            message: messageData['message'] as String? ?? '',
            type: messageData['type'] as String? ?? 'info',
            userId: messageData['user_id'] as int? ?? 0,
            createdAt: messageData['created_at'] as String? ??
                DateTime.now().millisecondsSinceEpoch.toString(),
            isRead: false,
            metadata: messageData,
          );
          _messages.add(message);
        } catch (e) {
          print('Error parsing message: $e');
        }
      }

      // Sort messages by timestamp (newest first)
      _messages
          .sort((a, b) => b.createdAtDateTime.compareTo(a.createdAtDateTime));

      emit(MessagesState.loaded(_messages));
    } catch (e) {
      emit(MessagesState.error(e.toString()));
    }
  }

  Future<void> _onMessageReceived(
      MessageReceived event, Emitter<MessagesState> emit) async {
    try {
      // Add new message to the beginning of the list
      _messages.insert(0, event.message);
      emit(MessagesState.loaded(_messages));

      print('[MESSAGES_BLOC] Message received: ${event.message.sender}');
    } catch (e) {
      emit(MessagesState.error(e.toString()));
    }
  }

  Future<void> _onMarkAsRead(
      MarkAsRead event, Emitter<MessagesState> emit) async {
    try {
      final index = _messages.indexWhere((m) => m.id == event.messageId);
      if (index != -1) {
        final message = _messages[index];
        _messages[index] = message.copyWith(isRead: true);
        emit(MessagesState.loaded(_messages));
      }
    } catch (e) {
      emit(MessagesState.error(e.toString()));
    }
  }

  Future<void> _onClearAll(ClearAll event, Emitter<MessagesState> emit) async {
    try {
      _messages.clear();
      emit(MessagesState.loaded(_messages));
    } catch (e) {
      emit(MessagesState.error(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    return super.close();
  }
}

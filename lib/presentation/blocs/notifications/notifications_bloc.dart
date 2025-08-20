import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taxi_service/core/network/socket_client.dart';
import 'package:taxi_service/core/network/api_client.dart';
import 'package:taxi_service/core/services/notification_overlay_service.dart';
import 'package:taxi_service/domain/entities/notification.dart' as entity;
import 'package:taxi_service/presentation/blocs/notifications/notifications_event.dart';
import 'package:taxi_service/presentation/blocs/notifications/notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final SocketClient _socketClient;
  final ApiClient _apiClient;
  StreamSubscription<entity.Notification>? _notificationSubscription;
  final List<entity.Notification> _notifications = [];

  NotificationsBloc(this._socketClient, this._apiClient)
      : super(const NotificationsState.initial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<NotificationReceived>(_onNotificationReceived);
    on<MarkAsRead>(_onMarkAsRead);
    on<ClearAll>(_onClearAll);

    // Listen to socket notifications
    _notificationSubscription = _socketClient.notificationStream.listen(
      (notification) {
        add(NotificationsEvent.notificationReceived(notification));
      },
    );
  }

  Future<void> _onLoadNotifications(
      LoadNotifications event, Emitter<NotificationsState> emit) async {
    try {
      emit(const NotificationsState.loading());

      // Fetch notifications from API
      final notificationsData = await _apiClient.getNotifications();

      // Clear existing notifications and add new ones from API
      _notifications.clear();

      for (final notificationData in notificationsData) {
        try {
          final notification = entity.Notification(
            id: notificationData['id'] as int,
            title: notificationData['title'] as String? ?? 'Notification',
            message: notificationData['message'] as String? ?? '',
            type: notificationData['type'] as String? ?? 'info',
            userId: notificationData['user_id'] as int? ?? 0,
            createdAt: notificationData['created_at'] as String? ??
                DateTime.now().millisecondsSinceEpoch.toString(),
            isRead: false,
            metadata: notificationData,
          );
          _notifications.add(notification);
        } catch (e) {
          print('Error parsing notification: $e');
        }
      }

      // Sort notifications by timestamp (newest first)
      _notifications
          .sort((a, b) => b.createdAtDateTime.compareTo(a.createdAtDateTime));

      emit(NotificationsState.loaded(_notifications));
    } catch (e) {
      emit(NotificationsState.error(e.toString()));
    }
  }

  Future<void> _onNotificationReceived(
      NotificationReceived event, Emitter<NotificationsState> emit) async {
    try {
      // Add new notification to the beginning of the list
      _notifications.insert(0, event.notification);
      emit(NotificationsState.loaded(_notifications));

      print(
          '[NOTIFICATIONS_BLOC] Notification received: ${event.notification.title}');
    } catch (e) {
      emit(NotificationsState.error(e.toString()));
    }
  }

  /// Show notification overlay on top of screen - to be called from UI
  Future<void> showNotificationOverlay(
      BuildContext context, entity.Notification notification) async {
    try {
      await NotificationOverlayService.showFromNotification(
        context,
        notification,
        onDismissed: () {
          // Mark as read when dismissed
          add(NotificationsEvent.markAsRead(notification.id));
        },
      );
    } catch (e) {
      print('[NOTIFICATIONS_BLOC] Error showing overlay: $e');
    }
  }

  Future<void> _onMarkAsRead(
      MarkAsRead event, Emitter<NotificationsState> emit) async {
    try {
      final index =
          _notifications.indexWhere((n) => n.id == event.notificationId);
      if (index != -1) {
        final notification = _notifications[index];
        _notifications[index] = notification.copyWith(isRead: true);
        emit(NotificationsState.loaded(_notifications));
      }
    } catch (e) {
      emit(NotificationsState.error(e.toString()));
    }
  }

  Future<void> _onClearAll(
      ClearAll event, Emitter<NotificationsState> emit) async {
    try {
      _notifications.clear();
             emit(NotificationsState.loaded(_notifications));
    } catch (e) {
      emit(NotificationsState.error(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _notificationSubscription?.cancel();
    return super.close();
  }
}

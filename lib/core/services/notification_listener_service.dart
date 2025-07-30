import 'dart:async';
import 'package:flutter/material.dart';
import 'package:taxi_service/core/di/injection.dart';
import 'package:taxi_service/core/network/socket_client.dart';
import 'package:taxi_service/core/services/push_notification_service.dart';
import 'package:taxi_service/core/services/notification_overlay_service.dart';
import 'package:taxi_service/domain/entities/notification.dart' as entity;
import 'package:taxi_service/domain/entities/message.dart' as msg;

class NotificationListenerService {
  static StreamSubscription<entity.Notification>? _notificationSubscription;
  static StreamSubscription<msg.Message>? _messageSubscription;
  static BuildContext? _globalContext;
  static bool _isInitialized = false;

  /// Initialize the notification listener service
  static Future<void> initialize(BuildContext context) async {
    if (_isInitialized) {
      print('[NOTIFICATION_LISTENER] Already initialized');
      return;
    }

    _globalContext = context;
    final socketClient = getIt<SocketClient>();

    // Listen to socket notifications and show both push and overlay
    _notificationSubscription = socketClient.notificationStream.listen(
      (notification) async {
        print(
            '[NOTIFICATION_LISTENER] Received notification: ${notification.title}');

        try {
          // Show push notification
          await PushNotificationService.showNotification(
            id: notification.id,
            title: notification.title,
            body: notification.message,
            category: NotificationCategory.systemAlert,
            payload: 'notification_${notification.id}',
          );

          // Show overlay notification (only if context is available)
          if (_globalContext != null && _globalContext!.mounted) {
            await NotificationOverlayService.showNotificationOverlay(
              context: _globalContext!,
              title: notification.title,
              message: notification.message,
              type: notification.type,
              onDismissed: () {
                print('[NOTIFICATION_LISTENER] Notification overlay dismissed');
              },
            );
          }
        } catch (e) {
          print('[NOTIFICATION_LISTENER] Error handling notification: $e');
        }
      },
      onError: (error) {
        print('[NOTIFICATION_LISTENER] Notification stream error: $error');
      },
    );

    // Listen to socket messages and show push notifications only
    _messageSubscription = socketClient.messageStream.listen(
      (message) async {
        print('[NOTIFICATION_LISTENER] Received message: ${message.sender}');

        try {
          // Show push notification for messages
          await PushNotificationService.showNotification(
            id: message.id,
            title: '${message.sender}',
            body: message.content,
            category: NotificationCategory.message,
            payload: 'message_${message.id}',
          );
        } catch (e) {
          print('[NOTIFICATION_LISTENER] Error handling message: $e');
        }
      },
      onError: (error) {
        print('[NOTIFICATION_LISTENER] Message stream error: $error');
      },
    );

    _isInitialized = true;
    print('[NOTIFICATION_LISTENER] Service initialized successfully');
  }

  /// Update the global context (useful when navigating between screens)
  static void updateContext(BuildContext context) {
    _globalContext = context;
  }

  /// Dispose the service
  static void dispose() {
    _notificationSubscription?.cancel();
    _messageSubscription?.cancel();
    _notificationSubscription = null;
    _messageSubscription = null;
    _globalContext = null;
    _isInitialized = false;
    print('[NOTIFICATION_LISTENER] Service disposed');
  }

  /// Check if the service is initialized
  static bool get isInitialized => _isInitialized;
}

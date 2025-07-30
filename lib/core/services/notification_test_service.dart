import 'package:flutter/material.dart';
import 'package:taxi_service/core/services/push_notification_service.dart';
import 'package:taxi_service/core/services/notification_overlay_service.dart';
import 'package:taxi_service/domain/entities/notification.dart' as entity;

class NotificationTestService {
  /// Test push notification
  static Future<void> testPushNotification() async {
    await PushNotificationService.showNotification(
      id: 999,
      title: 'Тестовое уведомление',
      body: 'Это тестовое push-уведомление для проверки работы системы',
      category: NotificationCategory.systemAlert,
      payload: 'test_notification',
    );
    print('[NOTIFICATION_TEST] Push notification sent');
  }

  /// Test overlay notification
  static Future<void> testOverlayNotification(BuildContext context) async {
    await NotificationOverlayService.showNotificationOverlay(
      context: context,
      title: 'Тестовое системное уведомление',
      message:
          'Это тестовое overlay-уведомление которое можно закрыть только кнопкой OK',
      type: 'warning',
      onDismissed: () {
        print('[NOTIFICATION_TEST] Overlay dismissed');
      },
    );
  }

  /// Test with notification entity
  static Future<void> testNotificationEntity(BuildContext context) async {
    final testNotification = entity.Notification(
      id: 998,
      title: 'Важное уведомление',
      message: 'Тестовое сообщение с использованием entity модели',
      type: 'info',
      userId: 1,
      createdAt: DateTime.now().millisecondsSinceEpoch.toString(),
      isRead: false,
    );

    await NotificationOverlayService.showFromNotification(
      context,
      testNotification,
      onDismissed: () {
        print('[NOTIFICATION_TEST] Entity notification dismissed');
      },
    );
  }

  /// Check notification permissions
  static Future<bool> checkNotificationPermissions() async {
    final enabled = await PushNotificationService.areNotificationsEnabled();
    print('[NOTIFICATION_TEST] Notifications enabled: $enabled');
    return enabled;
  }
}

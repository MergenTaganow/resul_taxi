import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PushNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  /// Initialize the notification service
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Android initialization
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        requestCriticalPermission: true,
      );

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Request permissions on iOS
      if (Platform.isIOS) {
        await _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
              critical: true,
            );
      }

      // Request permissions on Android 13+
      if (Platform.isAndroid) {
        await _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
      }

      _isInitialized = true;
      print('[PUSH_NOTIFICATIONS] Service initialized successfully');
    } catch (e) {
      print('[PUSH_NOTIFICATIONS] Error initializing service: $e');
    }
  }

  /// Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    print('[PUSH_NOTIFICATIONS] Notification tapped: ${response.payload}');
    // Handle navigation based on notification type
    // This could be extended to navigate to specific screens
  }

  /// Show a notification
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    NotificationCategory category = NotificationCategory.general,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Configure notification details based on category
      AndroidNotificationDetails androidDetails;
      DarwinNotificationDetails iosDetails;

      switch (category) {
        case NotificationCategory.newOrder:
          androidDetails = const AndroidNotificationDetails(
            'orders_channel',
            'New Orders',
            channelDescription: 'Notifications for new taxi orders',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: true,
            enableVibration: true,
            playSound: true,
            sound: RawResourceAndroidNotificationSound('order_notification'),
            icon: '@mipmap/ic_launcher',
          );
          iosDetails = const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            sound: 'order_notification.aiff',
            interruptionLevel: InterruptionLevel.critical,
          );
          break;

        case NotificationCategory.message:
          androidDetails = const AndroidNotificationDetails(
            'messages_channel',
            'Messages',
            channelDescription: 'Chat messages from dispatch',
            importance: Importance.high,
            priority: Priority.high,
            showWhen: true,
            enableVibration: true,
            playSound: true,
            icon: '@mipmap/ic_launcher',
          );
          iosDetails = const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            interruptionLevel: InterruptionLevel.active,
          );
          break;

        case NotificationCategory.systemAlert:
          androidDetails = const AndroidNotificationDetails(
            'system_alerts_channel',
            'System Alerts',
            channelDescription: 'Important system notifications',
            importance: Importance.max,
            priority: Priority.max,
            showWhen: true,
            enableVibration: true,
            playSound: true,
            icon: '@mipmap/ic_launcher',
          );
          iosDetails = const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            interruptionLevel: InterruptionLevel.critical,
          );
          break;

        case NotificationCategory.general:
        default:
          androidDetails = const AndroidNotificationDetails(
            'general_channel',
            'General Notifications',
            channelDescription: 'General app notifications',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            showWhen: true,
            icon: '@mipmap/ic_launcher',
          );
          iosDetails = const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          );
          break;
      }

      final NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.show(
        id,
        title,
        body,
        notificationDetails,
        payload: payload,
      );

      print('[PUSH_NOTIFICATIONS] Showed notification: $title');
    } catch (e) {
      print('[PUSH_NOTIFICATIONS] Error showing notification: $e');
    }
  }

  /// Cancel a specific notification
  static Future<void> cancel(int id) async {
    try {
      await _notificationsPlugin.cancel(id);
      print('[PUSH_NOTIFICATIONS] Cancelled notification with id: $id');
    } catch (e) {
      print('[PUSH_NOTIFICATIONS] Error cancelling notification: $e');
    }
  }

  /// Cancel all notifications
  static Future<void> cancelAll() async {
    try {
      await _notificationsPlugin.cancelAll();
      print('[PUSH_NOTIFICATIONS] Cancelled all notifications');
    } catch (e) {
      print('[PUSH_NOTIFICATIONS] Error cancelling all notifications: $e');
    }
  }

  /// Check if notifications are enabled
  static Future<bool> areNotificationsEnabled() async {
    try {
      if (Platform.isAndroid) {
        final androidImplementation =
            _notificationsPlugin.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        return await androidImplementation?.areNotificationsEnabled() ?? false;
      } else if (Platform.isIOS) {
        final iosImplementation =
            _notificationsPlugin.resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();
        final permissions = await iosImplementation?.checkPermissions();
        return permissions?.isEnabled ?? false;
      }
      return false;
    } catch (e) {
      print('[PUSH_NOTIFICATIONS] Error checking notification permissions: $e');
      return false;
    }
  }
}

/// Notification categories for different types of notifications
enum NotificationCategory {
  newOrder,
  message,
  systemAlert,
  general,
}

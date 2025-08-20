import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import '../di/injection.dart';

Future<void> requestPermissions() async {
// Android 13+, you need to allow notification permission to display foreground service notification.
//
// iOS: If you need notification, ask for permission.
  final NotificationPermission notificationPermissionStatus =
      await FlutterForegroundTask.checkNotificationPermission();
  if (notificationPermissionStatus != NotificationPermission.granted) {
    await FlutterForegroundTask.requestNotificationPermission();
  }

  if (Platform.isAndroid) {
// "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted for
// onNotificationPressed function to be called.
//
// When the notification is pressed while permission is denied,
// the onNotificationPressed function is not called and the app opens.
//
// If you do not use the onNotificationPressed or launchApp function,
// you do not need to write this code.
/*      if (!await FlutterForegroundTask.canDrawOverlays) {
        // This function requires `android.permission.SYSTEM_ALERT_WINDOW` permission.
        await FlutterForegroundTask.openSystemAlertWindowSettings();
      }*/

// Android 12+, there are restrictions on starting a foreground service.
//
// To restart the service on device reboot or unexpected problem, you need to allow below permission.
    if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
// This function requires `android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` permission.
      await FlutterForegroundTask.requestIgnoreBatteryOptimization();
    }
  }
}

initBackgroundService() async {
  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: 'stop_watch_channel',
      channelName: 'Resul Taxi Service',
      channelDescription: 'This notification appears when the foreground service is running.',
      channelImportance: NotificationChannelImportance.LOW,
      priority: NotificationPriority.LOW,
    ),
    iosNotificationOptions: const IOSNotificationOptions(
      showNotification: true,
      playSound: false,
    ),
    foregroundTaskOptions: ForegroundTaskOptions(
      autoRunOnBoot: false,
      autoRunOnMyPackageReplaced: true,
      allowWakeLock: true,
      allowWifiLock: true,
      eventAction: ForegroundTaskEventAction.repeat(5000),
    ),
  );
  print("will init----will init----will init----will init----");
}

startBackgroundService() async {
  print("came to start----${await FlutterForegroundTask.isRunningService}");
  if (await FlutterForegroundTask.isRunningService) {
    return FlutterForegroundTask.restartService();
  } else {
    return FlutterForegroundTask.startService(
      serviceId: 256,
              notificationTitle: 'Resul Taxi',
      notificationText: 'Hasaplanylýar...',
      notificationIcon: null,
      callback: startCallback,
    ).then((onValue) {
      print(onValue);
    });
  }
}

Future<void> stopBackgroundService() async{
  await FlutterForegroundTask.stopService();
}

@pragma('vm:entry-point')
void startCallback() async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  FlutterForegroundTask.setTaskHandler(getIt<BackgroundService>());
  print('Task handler set ✅');
}

class BackgroundService extends TaskHandler {
  @override
  @pragma('vm:entry-point')
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {}

  @override
  @pragma('vm:entry-point')
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) {
    throw UnimplementedError();
  }

  @override
  @pragma('vm:entry-point')
  Future<void> onRepeatEvent(DateTime timestamp) async {}
}

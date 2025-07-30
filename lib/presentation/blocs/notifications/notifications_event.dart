import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:taxi_service/domain/entities/notification.dart';

part 'notifications_event.freezed.dart';

@freezed
class NotificationsEvent with _$NotificationsEvent {
  const factory NotificationsEvent.loadNotifications() = LoadNotifications;
  const factory NotificationsEvent.notificationReceived(
      Notification notification) = NotificationReceived;
  const factory NotificationsEvent.markAsRead(int notificationId) = MarkAsRead;
  const factory NotificationsEvent.clearAll() = ClearAll;
}

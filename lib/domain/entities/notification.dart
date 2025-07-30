import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification.freezed.dart';
part 'notification.g.dart';

@freezed
class Notification with _$Notification {
  const Notification._();

  const factory Notification({
    required int id,
    required String title,
    required String message,
    required String type,
    @JsonKey(name: 'user_id') required int userId,
    @JsonKey(name: 'created_at') required String createdAt,
    // Local fields not from API
    bool? isRead,
    Map<String, dynamic>? metadata,
  }) = _Notification;

  factory Notification.fromJson(Map<String, dynamic> json) =>
      _$NotificationFromJson(json);

  // Helper getter for DateTime
  DateTime get createdAtDateTime =>
      DateTime.fromMillisecondsSinceEpoch(int.parse(createdAt ?? '0'));
}

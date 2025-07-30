import 'package:freezed_annotation/freezed_annotation.dart';

part 'message.freezed.dart';
part 'message.g.dart';

@freezed
class Message with _$Message {
  const Message._();

  const factory Message({
    required int id,
    required String title,
    required String message,
    required String type,
    @JsonKey(name: 'user_id') required int userId,
    @JsonKey(name: 'created_at') required String createdAt,
    // Local fields not from API
    bool? isRead,
    Map<String, dynamic>? metadata,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);

  // Helper getters for backward compatibility and convenience
  DateTime get createdAtDateTime =>
      DateTime.fromMillisecondsSinceEpoch(int.parse(createdAt ?? '0'));
  String get sender => title; // Use title as sender name
  String get content => message; // Use message as content
  DateTime get timestamp => createdAtDateTime; // Alias for timestamp
}

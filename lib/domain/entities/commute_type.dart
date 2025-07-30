import 'package:freezed_annotation/freezed_annotation.dart';

part 'commute_type.freezed.dart';
part 'commute_type.g.dart';

@freezed
class CommuteType with _$CommuteType {
  const factory CommuteType({
    required int id,
    required String section,
    required String key,
    required String value,
    required String description,
    required String type,
  }) = _CommuteType;

  factory CommuteType.fromJson(Map<String, dynamic> json) =>
      _$CommuteTypeFromJson(json);
}

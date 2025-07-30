import 'package:json_annotation/json_annotation.dart';

class NumConverter implements JsonConverter<num?, Object?> {
  const NumConverter();

  @override
  num? fromJson(Object? json) {
    if (json == null) return null;
    if (json is num) return json;
    if (json is String) return num.tryParse(json);
    return null;
  }

  @override
  Object? toJson(num? object) => object;
}

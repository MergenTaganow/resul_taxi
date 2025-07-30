import 'package:json_annotation/json_annotation.dart';
import 'package:taxi_service/domain/entities/latlng.dart';

class LatLngConverter implements JsonConverter<LatLng, Map<String, dynamic>> {
  const LatLngConverter();

  @override
  LatLng fromJson(Map<String, dynamic> json) {
    return LatLng(json['latitude'] as double, json['longitude'] as double);
  }

  @override
  Map<String, dynamic> toJson(LatLng latLng) {
    return {'latitude': latLng.latitude, 'longitude': latLng.longitude};
  }
}

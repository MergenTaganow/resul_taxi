import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:taxi_service/core/utils/num_converter.dart';

part 'order.freezed.dart';
part 'order.g.dart';

enum OrderStatus {
  pending,
  accepted,
  in_progress,
  free_request,
  completed,
  cancelled
}

@freezed
class Order with _$Order {
  const factory Order({
    required int id,
    required OrderStatus status,
    // Extended fields from socket DTO
    @JsonKey(name: 'district_slug') String? districtSlug,
    @JsonKey(name: 'district_id') int? districtId,
    @JsonKey(name: 'tarrif_id') int? tarrifId,
    @JsonKey(name: 'tarrif_slug') String? tarrifSlug,
    String? phonenumber,
    @JsonKey(name: 'driver_notified_time') String? driverNotifiedTime,
    String? note,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'requested_address') String? requestedAddress,
    @JsonKey(name: 'requested_time') String? requestedTime,
    @NumConverter() @JsonKey(name: 'approx_price') num? approxPrice,
  }) = _Order;

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
}

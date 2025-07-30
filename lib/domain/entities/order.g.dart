// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OrderImpl _$$OrderImplFromJson(Map<String, dynamic> json) => _$OrderImpl(
      id: (json['id'] as num).toInt(),
      status: $enumDecode(_$OrderStatusEnumMap, json['status']),
      districtSlug: json['district_slug'] as String?,
      districtId: (json['district_id'] as num?)?.toInt(),
      tarrifId: (json['tarrif_id'] as num?)?.toInt(),
      tarrifSlug: json['tarrif_slug'] as String?,
      phonenumber: json['phonenumber'] as String?,
      driverNotifiedTime: json['driver_notified_time'] as String?,
      note: json['note'] as String?,
      createdAt: json['created_at'] as String?,
      requestedAddress: json['requested_address'] as String?,
      requestedTime: json['requested_time'] as String?,
      approxPrice: const NumConverter().fromJson(json['approx_price']),
    );

Map<String, dynamic> _$$OrderImplToJson(_$OrderImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': _$OrderStatusEnumMap[instance.status]!,
      'district_slug': instance.districtSlug,
      'district_id': instance.districtId,
      'tarrif_id': instance.tarrifId,
      'tarrif_slug': instance.tarrifSlug,
      'phonenumber': instance.phonenumber,
      'driver_notified_time': instance.driverNotifiedTime,
      'note': instance.note,
      'created_at': instance.createdAt,
      'requested_address': instance.requestedAddress,
      'requested_time': instance.requestedTime,
      'approx_price': const NumConverter().toJson(instance.approxPrice),
    };

const _$OrderStatusEnumMap = {
  OrderStatus.pending: 'pending',
  OrderStatus.accepted: 'accepted',
  OrderStatus.in_progress: 'in_progress',
  OrderStatus.free_request: 'free_request',
  OrderStatus.completed: 'completed',
  OrderStatus.cancelled: 'cancelled',
};

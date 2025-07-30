// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DriverImpl _$$DriverImplFromJson(Map<String, dynamic> json) => _$DriverImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      carModel: json['carModel'] as String,
      carNumber: json['carNumber'] as String,
      rating: (json['rating'] as num).toDouble(),
    );

Map<String, dynamic> _$$DriverImplToJson(_$DriverImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'phone': instance.phone,
      'carModel': instance.carModel,
      'carNumber': instance.carNumber,
      'rating': instance.rating,
    };

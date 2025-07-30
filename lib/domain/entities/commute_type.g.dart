// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commute_type.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CommuteTypeImpl _$$CommuteTypeImplFromJson(Map<String, dynamic> json) =>
    _$CommuteTypeImpl(
      id: (json['id'] as num).toInt(),
      section: json['section'] as String,
      key: json['key'] as String,
      value: json['value'] as String,
      description: json['description'] as String,
      type: json['type'] as String,
    );

Map<String, dynamic> _$$CommuteTypeImplToJson(_$CommuteTypeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'section': instance.section,
      'key': instance.key,
      'value': instance.value,
      'description': instance.description,
      'type': instance.type,
    };

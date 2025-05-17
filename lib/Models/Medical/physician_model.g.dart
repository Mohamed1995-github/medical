// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'physician_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PhysicianModel _$PhysicianModelFromJson(Map<String, dynamic> json) =>
    PhysicianModel(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      specialty: json['specialty'] as String?,
    );

Map<String, dynamic> _$PhysicianModelToJson(PhysicianModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'specialty': instance.specialty,
    };

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
      image: json['image'] as String?,
      mobile: json['mobile'] as String?,
      email: json['email'] as String?,
    );

Map<String, dynamic> _$PhysicianModelToJson(PhysicianModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'specialty': instance.specialty,
      'image': instance.image,
      'mobile': instance.mobile,
      'email': instance.email,
    };
PhysiciansResponse _$PhysiciansResponseFromJson(Map<String, dynamic> json) =>
    PhysiciansResponse(
      message: json['message'] as String?,
      success: json['success'] as bool?,
      status: (json['status'] as num?)?.toInt(),
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => PhysicianModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PhysiciansResponseToJson(PhysiciansResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'success': instance.success,
      'status': instance.status,
      'data': instance.data,
    };

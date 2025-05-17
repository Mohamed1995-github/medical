// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'physicians_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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

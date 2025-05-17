// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'specialties_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SpecialtiesResponse _$SpecialtiesResponseFromJson(Map<String, dynamic> json) =>
    SpecialtiesResponse(
      message: json['message'] as String?,
      success: json['success'] as bool?,
      status: (json['status'] as num?)?.toInt(),
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => SpecialtyModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SpecialtiesResponseToJson(
        SpecialtiesResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'success': instance.success,
      'status': instance.status,
      'data': instance.data,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cliniques_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CliniquesResponse _$CliniquesResponseFromJson(Map<String, dynamic> json) =>
    CliniquesResponse(
      message: json['message'] as String?,
      success: json['success'] as bool?,
      status: (json['status'] as num?)?.toInt(),
      cliniques: (json['cliniques'] as List<dynamic>?)
          ?.map((e) => CliniqueModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CliniquesResponseToJson(CliniquesResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'success': instance.success,
      'status': instance.status,
      'cliniques': instance.cliniques,
    };

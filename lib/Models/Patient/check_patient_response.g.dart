// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_patient_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CheckPatientResponse _$CheckPatientResponseFromJson(
        Map<String, dynamic> json) =>
    CheckPatientResponse(
      message: json['message'] as String?,
      success: json['success'] as bool?,
      status: (json['status'] as num?)?.toInt(),
      exists: json['exists'] as bool?,
      id: (json['id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$CheckPatientResponseToJson(
        CheckPatientResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'success': instance.success,
      'status': instance.status,
      'exists': instance.exists,
      'id': instance.id,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_patient_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreatePatientResponse _$CreatePatientResponseFromJson(
        Map<String, dynamic> json) =>
    CreatePatientResponse(
      message: json['message'] as String?,
      success: json['success'] as bool?,
      status: (json['status'] as num?)?.toInt(),
      patientId: (json['patient_id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$CreatePatientResponseToJson(
        CreatePatientResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'success': instance.success,
      'status': instance.status,
      'patient_id': instance.patientId,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_appointment_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateAppointmentResponse _$CreateAppointmentResponseFromJson(
        Map<String, dynamic> json) =>
    CreateAppointmentResponse(
      message: json['message'] as String?,
      success: json['success'] as bool?,
      status: (json['status'] as num?)?.toInt(),
      appointmentId: (json['appointment_id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$CreateAppointmentResponseToJson(
        CreateAppointmentResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'success': instance.success,
      'status': instance.status,
      'appointment_id': instance.appointmentId,
    };

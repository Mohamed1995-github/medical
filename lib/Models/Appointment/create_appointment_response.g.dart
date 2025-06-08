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



    AppointmentHistoryItem _$AppointmentHistoryItemFromJson(
        Map<String, dynamic> json) =>
    AppointmentHistoryItem(
      patient_id: json['patient_id'] as int,
      patient_name: json['patient_name'] as String?,
      appointments: (json['appointments'] as List<dynamic>?)
          ?.map((e) => Appointment.fromJson(e as Map<String, dynamic>))
          .toList(),
      count: json['count'] as String?,
      message: json['message'] as String?,
      success: json['success'] as bool?,
      status: (json['status'] as num?)?.toInt(),
    
    );

Map<String, dynamic> _$AppointmentHistoryItemToJson(
        AppointmentHistoryItem instance) =>
    <String, dynamic>{
      'patient_id': instance.patient_id,
      'patient_name': instance.patient_name,
      'appointments': instance.appointments,
      'count': instance.count,  
      'message': instance.message,
      'success': instance.success,
      'status': instance.status,
    };

Appointment _$AppointmentFromJson(Map<String, dynamic> json) => Appointment(
      id: (json['id'] as num).toInt(),
      date: json['date'] as String,
      status: json['status'] as String,
      physician: json['physician'] as String,
      consultation_type: json['consultation_type'] as String,
      product_id: (json['product_id'] as num?)!.toInt(),
    );

Map<String, dynamic> _$AppointmentToJson(Appointment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date,
      'status': instance.status,
      'physician': instance.physician,
      'consultation_type': instance.consultation_type,
      'product_id': instance.product_id,
    };

// create_appointment_response.dart
import 'package:json_annotation/json_annotation.dart';
import '../base_response.dart';

part 'create_appointment_response.g.dart';

@JsonSerializable()
class CreateAppointmentResponse extends BaseModel {
  @JsonKey(name: "appointment_id")
  int? appointmentId;

  CreateAppointmentResponse({
    super.message,
    super.success,
    super.status,
    this.appointmentId,
  });

  factory CreateAppointmentResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateAppointmentResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CreateAppointmentResponseToJson(this);
}
// historiqu_appointment.dart
class AppointmentHistoryItem extends BaseModel {
  @JsonKey(name: 'patient_id')
  final int patient_id;
  @JsonKey(name: 'patient_name')
  final String? patient_name;
  @JsonKey(name: 'appointments')
  final List<Appointment>? appointments;
  @JsonKey(name: 'count')
  final String? count;

  AppointmentHistoryItem({
    required this.patient_id,
    this.patient_name,
    this.appointments,
    this.count,
    super.message,
    super.success,
    super.status,
  });

  factory AppointmentHistoryItem.fromJson(Map<String, dynamic> json) =>
      _$AppointmentHistoryItemFromJson(json);
  
  
  @override
  Map<String, dynamic> toJson() => _$AppointmentHistoryItemToJson(this);

}
class Appointment{

  @JsonKey(name: 'id')
  final int id;
  @JsonKey(name: 'date')
  final String date;
  @JsonKey(name: 'status')
  final String status;
  @JsonKey(name: 'physician')
  final String physician;
  @JsonKey(name: 'consultation_type')
  final String consultation_type;
  @JsonKey(name: 'product_id')
  final int product_id;

  Appointment({
    required this.id,
    required this.date,
    required this.status,
    required this.physician,
    required this.consultation_type,
    required this.product_id,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) =>
      _$AppointmentFromJson(json);

  Map<String, dynamic> toJson() => _$AppointmentToJson(this);
}

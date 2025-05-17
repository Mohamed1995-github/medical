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

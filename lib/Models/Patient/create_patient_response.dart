// create_patient_response.dart
import 'package:json_annotation/json_annotation.dart';
import '../base_response.dart';

part 'create_patient_response.g.dart';

@JsonSerializable()
class CreatePatientResponse extends BaseModel {
  @JsonKey(name: "patient_id")
  int? patientId;

  CreatePatientResponse({
    super.message,
    super.success,
    super.status,
    this.patientId,
  });

  factory CreatePatientResponse.fromJson(Map<String, dynamic> json) =>
      _$CreatePatientResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CreatePatientResponseToJson(this);
}

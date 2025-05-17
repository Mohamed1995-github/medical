// check_patient_response.dart
import 'package:json_annotation/json_annotation.dart';
import '../base_response.dart';

part 'check_patient_response.g.dart';

@JsonSerializable()
class CheckPatientResponse extends BaseModel {
  @JsonKey(name: "exists")
  bool? exists;

  @JsonKey(name: "id")
  int? id;

  CheckPatientResponse({
    super.message,
    super.success,
    super.status,
    this.exists,
    this.id,
  });

  factory CheckPatientResponse.fromJson(Map<String, dynamic> json) =>
      _$CheckPatientResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CheckPatientResponseToJson(this);
}

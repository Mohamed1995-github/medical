// specialties_response.dart
import 'package:json_annotation/json_annotation.dart';
import '../base_response.dart';
import 'specialty_model.dart';

part 'specialties_response.g.dart';

@JsonSerializable()
class SpecialtiesResponse extends BaseModel {
  @JsonKey(name: "data")
  List<SpecialtyModel>? data;

  SpecialtiesResponse({super.message, super.success, super.status, this.data});

  factory SpecialtiesResponse.fromJson(Map<String, dynamic> json) =>
      _$SpecialtiesResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SpecialtiesResponseToJson(this);
}

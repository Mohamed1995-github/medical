// specialty_model.dart
import 'package:json_annotation/json_annotation.dart';
import '../base_response.dart';

part 'specialty_model.g.dart';

@JsonSerializable()
class SpecialtyModel {
  @JsonKey(name: "id")
  int? id;
  
  @JsonKey(name: "name")
  String? name;

  SpecialtyModel({this.id, this.name});

  factory SpecialtyModel.fromJson(Map<String, dynamic> json) =>
      _$SpecialtyModelFromJson(json);

  Map<String, dynamic> toJson() => _$SpecialtyModelToJson(this);
}

class SpecialtiesResponse extends BaseModel {
  @JsonKey(name: "data")
  List<SpecialtyModel>? data;

  SpecialtiesResponse({super.message, super.success, super.status, this.data});

  factory SpecialtiesResponse.fromJson(Map<String, dynamic> json) =>
      _$SpecialtiesResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SpecialtiesResponseToJson(this);
}
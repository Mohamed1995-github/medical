// specialty_model.dart
import 'package:json_annotation/json_annotation.dart';

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
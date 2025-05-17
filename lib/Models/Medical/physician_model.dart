// physician_model.dart
import 'package:json_annotation/json_annotation.dart';

part 'physician_model.g.dart';

@JsonSerializable()
class PhysicianModel {
  @JsonKey(name: "id")
  int? id;
  
  @JsonKey(name: "name")
  String? name;
  
  @JsonKey(name: "specialty")
  String? specialty;

  PhysicianModel({this.id, this.name, this.specialty});

  factory PhysicianModel.fromJson(Map<String, dynamic> json) =>
      _$PhysicianModelFromJson(json);

  Map<String, dynamic> toJson() => _$PhysicianModelToJson(this);
}
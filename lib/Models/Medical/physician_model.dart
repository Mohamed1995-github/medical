// physician_model.dart
import 'package:json_annotation/json_annotation.dart';
import '../base_response.dart';

part 'physician_model.g.dart';

@JsonSerializable()
class PhysicianModel {
  @JsonKey(name: "id")
  int? id;
  
  @JsonKey(name: "name")
  String? name;
  
  @JsonKey(name: "specialty")
  String? specialty;

@JsonKey(name: "image")
  String? image;
  @JsonKey(name: "mobile")
  String? mobile;
  @JsonKey(name: "email")
  String? email;
  PhysicianModel({this.id, this.name, this.specialty, this.image, this.mobile, this.email});

  factory PhysicianModel.fromJson(Map<String, dynamic> json) =>
      _$PhysicianModelFromJson(json);

  Map<String, dynamic> toJson() => _$PhysicianModelToJson(this);
}
class PhysiciansResponse extends BaseModel {
  @JsonKey(name: "data")
  List<PhysicianModel>? data;

  PhysiciansResponse({super.message, super.success, super.status, this.data});

  factory PhysiciansResponse.fromJson(Map<String, dynamic> json) =>
      _$PhysiciansResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PhysiciansResponseToJson(this);
}

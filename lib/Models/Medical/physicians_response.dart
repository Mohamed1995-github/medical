// physicians_response.dart
import 'package:json_annotation/json_annotation.dart';
import '../base_response.dart';
import 'physician_model.dart';

part 'physicians_response.g.dart';

@JsonSerializable()
class PhysiciansResponse extends BaseModel {
  @JsonKey(name: "data")
  List<PhysicianModel>? data;

  PhysiciansResponse({super.message, super.success, super.status, this.data});

  factory PhysiciansResponse.fromJson(Map<String, dynamic> json) =>
      _$PhysiciansResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PhysiciansResponseToJson(this);
}

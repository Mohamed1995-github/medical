// base_model.dart
import 'package:json_annotation/json_annotation.dart';

part 'base_response.g.dart';

@JsonSerializable()
class BaseModel {
  @JsonKey(name: "message")
  String? message;

  @JsonKey(name: "success")
  bool? success;

  @JsonKey(name: "status")
  int? status;

  BaseModel({this.message, this.success, this.status});

  factory BaseModel.fromJson(Map<String, dynamic> json) =>
      _$BaseModelFromJson(json);

  Map<String, dynamic> toJson() => _$BaseModelToJson(this);
}
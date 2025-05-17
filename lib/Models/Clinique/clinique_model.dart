// clinique_model.dart
import 'package:json_annotation/json_annotation.dart';

part 'clinique_model.g.dart';

@JsonSerializable()
class CliniqueModel {
  @JsonKey(name: "id")
  int? id;
  
  @JsonKey(name: "name")
  String? name;
  
  @JsonKey(name: "url")
  String? url;
  
  @JsonKey(name: "image")
  String? image;
  
  @JsonKey(name: "description")
  String? description;
  
  @JsonKey(name: "location")
  String? location;

  CliniqueModel({
    this.id,
    this.name,
    this.url,
    this.image,
    this.description,
    this.location,
  });

  factory CliniqueModel.fromJson(Map<String, dynamic> json) =>
      _$CliniqueModelFromJson(json);

  Map<String, dynamic> toJson() => _$CliniqueModelToJson(this);
}
// cliniques_response.dart
import 'package:json_annotation/json_annotation.dart';
import '../base_response.dart';
import 'clinique_model.dart';

part 'cliniques_response.g.dart';

@JsonSerializable()
class CliniquesResponse extends BaseModel {
  @JsonKey(name: "cliniques")
  List<CliniqueModel>? cliniques;

  CliniquesResponse({
    super.message,
    super.success,
    super.status,
    this.cliniques,
  });

  factory CliniquesResponse.fromJson(Map<String, dynamic> json) =>
      _$CliniquesResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CliniquesResponseToJson(this);
}

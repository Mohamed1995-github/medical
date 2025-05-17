// register_response.dart
import 'package:json_annotation/json_annotation.dart';
import '../base_response.dart';

part 'register_response.g.dart';

@JsonSerializable()
class RegisterResponse extends BaseModel {
  @JsonKey(name: "user_id")
  int? userId;

  @JsonKey(name: "partner_id")
  int? partnerId;

  RegisterResponse({
    super.message,
    super.success,
    super.status,
    this.userId,
    this.partnerId,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) =>
      _$RegisterResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$RegisterResponseToJson(this);
}

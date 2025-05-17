// login_response.dart
import 'package:json_annotation/json_annotation.dart';
import '../base_response.dart';

part 'login_response.g.dart';

@JsonSerializable()
class LoginResponse extends BaseModel {
  @JsonKey(name: "user_id")
  int? userId;

  @JsonKey(name: "partner_id")
  int? partnerId;

  @JsonKey(name: "name")
  String? name;

  @JsonKey(name: "email")
  String? email;

  @JsonKey(name: "phone")
  String? phone;

  LoginResponse({
    super.message,
    super.success,
    super.status,
    this.userId,
    this.partnerId,
    this.name,
    this.email,
    this.phone,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}

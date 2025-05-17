// reset_password_response.dart
import 'package:json_annotation/json_annotation.dart';
import '../base_response.dart';

part 'reset_password_response.g.dart';

@JsonSerializable()
class ResetPasswordResponse extends BaseModel {
  ResetPasswordResponse({super.message, super.success, super.status});

  factory ResetPasswordResponse.fromJson(Map<String, dynamic> json) =>
      _$ResetPasswordResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ResetPasswordResponseToJson(this);
}

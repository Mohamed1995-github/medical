// send_sms_code_response.dart
import 'package:json_annotation/json_annotation.dart';
import '../base_response.dart';

part 'send_sms_code_response.g.dart';

@JsonSerializable()
class SendSmsCodeResponse extends BaseModel {
  @JsonKey(name: "code")
  String? code;

  SendSmsCodeResponse({super.message, super.success, super.status, this.code});

  factory SendSmsCodeResponse.fromJson(Map<String, dynamic> json) =>
      _$SendSmsCodeResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SendSmsCodeResponseToJson(this);
}

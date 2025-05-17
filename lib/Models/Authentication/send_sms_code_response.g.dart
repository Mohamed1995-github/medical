// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'send_sms_code_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SendSmsCodeResponse _$SendSmsCodeResponseFromJson(Map<String, dynamic> json) =>
    SendSmsCodeResponse(
      message: json['message'] as String?,
      success: json['success'] as bool?,
      status: (json['status'] as num?)?.toInt(),
      code: json['code'] as String?,
    );

Map<String, dynamic> _$SendSmsCodeResponseToJson(
        SendSmsCodeResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'success': instance.success,
      'status': instance.status,
      'code': instance.code,
    };

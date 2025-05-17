// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) =>
    LoginResponse(
      message: json['message'] as String?,
      success: json['success'] as bool?,
      status: (json['status'] as num?)?.toInt(),
      userId: (json['user_id'] as num?)?.toInt(),
      partnerId: (json['partner_id'] as num?)?.toInt(),
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
    );

Map<String, dynamic> _$LoginResponseToJson(LoginResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'success': instance.success,
      'status': instance.status,
      'user_id': instance.userId,
      'partner_id': instance.partnerId,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
    };

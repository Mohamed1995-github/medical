// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BaseModel _$BaseModelFromJson(Map<String, dynamic> json) => BaseModel(
      message: json['message'] as String?,
      success: json['success'] as bool?,
      status: (json['status'] as num?)?.toInt(),
    );

Map<String, dynamic> _$BaseModelToJson(BaseModel instance) => <String, dynamic>{
      'message': instance.message,
      'success': instance.success,
      'status': instance.status,
    };

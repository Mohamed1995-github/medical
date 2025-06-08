// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clinique_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CliniqueModel _$CliniqueModelFromJson(Map<String, dynamic> json) =>
    CliniqueModel(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      url: json['url'] as String?,
      image: json['image'] as String?,
      description: json['description'] as String?,
      location: json['location'] as String?,
    );

Map<String, dynamic> _$CliniqueModelToJson(CliniqueModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'url': instance.url,
      'image': instance.image,
      'description': instance.description,
      'location': instance.location,
    };
CliniquesResponse _$CliniquesResponseFromJson(Map<String, dynamic> json) =>
    CliniquesResponse(
      message: json['message'] as String?,
      success: json['success'] as bool?,
      status: (json['status'] as num?)?.toInt(),
      cliniques: (json['cliniques'] as List<dynamic>?)
          ?.map((e) => CliniqueModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CliniquesResponseToJson(CliniquesResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'success': instance.success,
      'status': instance.status,
      'cliniques': instance.cliniques,
    };

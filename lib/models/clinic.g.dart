// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clinic.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Clinic _$ClinicFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['id', 'name', 'address'],
  );
  return Clinic(
    id: json['id'] as String,
    name: json['name'] as String,
    address: json['address'] as String,
    phoneNumber: json['phoneNumber'] as String? ?? '',
    emailAddress: json['emailAddress'] as String? ?? '',
    isVerified: json['isVerified'] as bool? ?? false,
    specialties: (json['specialties'] as List<dynamic>?)
            ?.map((e) => ClinicSpecialty.values.firstWhere(
                (specialty) => specialty.toString() == 'ClinicSpecialty.$e'))
            .toList() ??
        [],
    operatingHours: json['operatingHours'] as Map<String, dynamic>? ?? {},
  );
}

Map<String, dynamic> _$ClinicToJson(Clinic instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'address': instance.address,
      'phoneNumber': instance.phoneNumber,
      'emailAddress': instance.emailAddress,
      'isVerified': instance.isVerified,
      'specialties': instance.specialties,
      'operatingHours': instance.operatingHours,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'doctor.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Doctor _$DoctorFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['id', 'name', 'specialty'],
  );
  return Doctor(
    id: json['id'] as String,
    name: json['name'] as String,
    specialty: $enumDecode(_$DoctorSpecialtyEnumMap, json['specialty']),
    email: json['email'] as String? ?? '',
    phoneNumber: json['phoneNumber'] as String? ?? '',
    qualifications: json['qualifications'] as String? ?? '',
    bio: json['bio'] as String? ?? '',
    isVerified: json['isVerified'] as bool? ?? false,
    associatedClinics: (json['associatedClinics'] as List<dynamic>?)
            ?.map((e) => Clinic.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    availabilitySchedule:
        json['availabilitySchedule'] as Map<String, dynamic>? ?? {},
  );
}

Map<String, dynamic> _$DoctorToJson(Doctor instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'specialty': _$DoctorSpecialtyEnumMap[instance.specialty]!,
      'email': instance.email,
      'phoneNumber': instance.phoneNumber,
      'qualifications': instance.qualifications,
      'bio': instance.bio,
      'isVerified': instance.isVerified,
      'associatedClinics':
          instance.associatedClinics.map((e) => e.toJson()).toList(),
      'availabilitySchedule': instance.availabilitySchedule,
    };

const _$DoctorSpecialtyEnumMap = {
  DoctorSpecialty.generalPractice: 'general_practice',
  DoctorSpecialty.cardiology: 'cardiology',
  DoctorSpecialty.dermatology: 'dermatology',
  DoctorSpecialty.pediatrics: 'pediatrics',
  DoctorSpecialty.neurology: 'neurology',
  DoctorSpecialty.orthopedics: 'orthopedics',
};

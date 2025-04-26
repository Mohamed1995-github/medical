import 'package:json_annotation/json_annotation.dart';
import 'clinic.dart';

part 'doctor.g.dart';

enum DoctorSpecialty {
  @JsonValue('general_practice')
  generalPractice,
  @JsonValue('cardiology')
  cardiology,
  @JsonValue('dermatology')
  dermatology,
  @JsonValue('pediatrics')
  pediatrics,
  @JsonValue('neurology')
  neurology,
  @JsonValue('orthopedics')
  orthopedics,
}

@JsonSerializable(explicitToJson: true)
class Doctor {
  @JsonKey(required: true)
  final String id;

  @JsonKey(required: true)
  final String name;

  @JsonKey(required: true)
  final DoctorSpecialty specialty;

  @JsonKey(defaultValue: '')
  final String email;

  @JsonKey(defaultValue: '')
  final String phoneNumber;

  @JsonKey(defaultValue: '')
  final String qualifications;

  @JsonKey(defaultValue: '')
  final String bio;

  @JsonKey(defaultValue: false)
  final bool isVerified;

  @JsonKey(defaultValue: [])
  final List<Clinic> associatedClinics;

  @JsonKey(defaultValue: {})
  final Map<String, dynamic> availabilitySchedule;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    this.email = '',
    this.phoneNumber = '',
    this.qualifications = '',
    this.bio = '',
    this.isVerified = false,
    this.associatedClinics = const [],
    this.availabilitySchedule = const {},
  });

  // Validation methods
  bool get isValidDoctor {
    return id.isNotEmpty && name.isNotEmpty && specialty != null;
  }

  // Check doctor's availability at a specific time
  bool isAvailableAt(DateTime dateTime) {
    final day = _getDayName(dateTime.weekday);
    final time = dateTime.hour * 60 + dateTime.minute;

    final daySchedule = availabilitySchedule[day];
    if (daySchedule == null) return false;

    final startTime = _timeToMinutes(daySchedule['start']);
    final endTime = _timeToMinutes(daySchedule['end']);

    return time >= startTime && time <= endTime;
  }

  // Helper method to convert day number to name
  String _getDayName(int day) {
    const days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday'
    ];
    return days[day - 1];
  }

  // Helper method to convert time string to minutes
  int _timeToMinutes(String timeStr) {
    final parts = timeStr.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  // JSON serialization methods
  factory Doctor.fromJson(Map<String, dynamic> json) => _$DoctorFromJson(json);
  Map<String, dynamic> toJson() => _$DoctorToJson(this);

  // Copywrite method for easy modification
  Doctor copyWith({
    String? id,
    String? name,
    DoctorSpecialty? specialty,
    String? email,
    String? phoneNumber,
    String? qualifications,
    String? bio,
    bool? isVerified,
    List<Clinic>? associatedClinics,
    Map<String, dynamic>? availabilitySchedule,
  }) {
    return Doctor(
      id: id ?? this.id,
      name: name ?? this.name,
      specialty: specialty ?? this.specialty,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      qualifications: qualifications ?? this.qualifications,
      bio: bio ?? this.bio,
      isVerified: isVerified ?? this.isVerified,
      associatedClinics: associatedClinics ?? this.associatedClinics,
      availabilitySchedule: availabilitySchedule ?? this.availabilitySchedule,
    );
  }

  @override
  String toString() {
    return 'Doctor(id: $id, name: $name, specialty: ${specialty.toString().split('.').last})';
  }
}

// Doctor-specific exceptions
class DoctorException implements Exception {
  final String message;

  DoctorException(this.message);

  @override
  String toString() => 'DoctorException: $message';
}

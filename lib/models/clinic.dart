import 'package:json_annotation/json_annotation.dart';

part 'clinic.g.dart';

// Enum for clinic specialties
enum ClinicSpecialty {
  @JsonValue('general')
  general,
  @JsonValue('pediatric')
  pediatric,
  @JsonValue('cardiology')
  cardiology,
  @JsonValue('orthopedic')
  orthopedic,
  @JsonValue('dermatology')
  dermatology,
  @JsonValue('neurology')
  neurology,
}

@JsonSerializable(explicitToJson: true)
class Clinic {
  @JsonKey(required: true)
  final String id;

  @JsonKey(required: true)
  final String name;

  @JsonKey(required: true)
  final String address;

  @JsonKey(defaultValue: '')
  final String phoneNumber;

  @JsonKey(defaultValue: '')
  final String emailAddress;

  @JsonKey(defaultValue: false)
  final bool isVerified;

  @JsonKey(defaultValue: [])
  final List<ClinicSpecialty> specialties;

  @JsonKey(defaultValue: {})
  final Map<String, dynamic> operatingHours;

  @JsonKey(defaultValue: 0.0)
  final double latitude;

  @JsonKey(defaultValue: 0.0)
  final double longitude;

  @JsonKey(defaultValue: '')
  final String websiteUrl;

  @JsonKey(defaultValue: [])
  final List<String> availableServices;

  @JsonKey(defaultValue: false)
  final bool acceptsEmergencies;

  @JsonKey(defaultValue: 0)
  final int totalDoctors;

  Clinic({
    required this.id,
    required this.name,
    required this.address,
    this.phoneNumber = '',
    this.emailAddress = '',
    this.isVerified = false,
    this.specialties = const [],
    this.operatingHours = const {},
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.websiteUrl = '',
    this.availableServices = const [],
    this.acceptsEmergencies = false,
    this.totalDoctors = 0,
  });

  // Validation methods
  bool get isValidClinic {
    return id.isNotEmpty && name.isNotEmpty && address.isNotEmpty;
  }

  // Check if clinic is open at a specific time
  bool isOpenAt(DateTime dateTime) {
    final day = _getDayName(dateTime.weekday);
    final time = dateTime.hour * 60 + dateTime.minute;

    final dayHours = operatingHours[day];
    if (dayHours == null) return false;

    final openTime = _timeToMinutes(dayHours['open']);
    final closeTime = _timeToMinutes(dayHours['close']);

    return time >= openTime && time <= closeTime;
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
  factory Clinic.fromJson(Map<String, dynamic> json) => _$ClinicFromJson(json);
  Map<String, dynamic> toJson() => _$ClinicToJson(this);

  // Copywrite method for easy modification
  Clinic copyWith({
    String? id,
    String? name,
    String? address,
    String? phoneNumber,
    String? emailAddress,
    bool? isVerified,
    List<ClinicSpecialty>? specialties,
    Map<String, dynamic>? operatingHours,
    double? latitude,
    double? longitude,
    String? websiteUrl,
    List<String>? availableServices,
    bool? acceptsEmergencies,
    int? totalDoctors,
  }) {
    return Clinic(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      emailAddress: emailAddress ?? this.emailAddress,
      isVerified: isVerified ?? this.isVerified,
      specialties: specialties ?? this.specialties,
      operatingHours: operatingHours ?? this.operatingHours,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      availableServices: availableServices ?? this.availableServices,
      acceptsEmergencies: acceptsEmergencies ?? this.acceptsEmergencies,
      totalDoctors: totalDoctors ?? this.totalDoctors,
    );
  }

  @override
  String toString() {
    return 'Clinic(id: $id, name: $name, address: $address)';
  }
}

// Clinic-specific exceptions
class ClinicException implements Exception {
  final String message;

  ClinicException(this.message);

  @override
  String toString() => 'ClinicException: $message';
}

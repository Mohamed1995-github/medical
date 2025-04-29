import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/doctor.dart';
import '../models/clinic.dart';
import '../utils/error_handler.dart';

class AppointmentException implements Exception {
  final String message;
  AppointmentException(this.message);
}

enum AppointmentStatus { pending, confirmed, cancelled, completed }

class Appointment {
  final String id;
  final String patientId;
  final String doctorId;
  final String clinicId;
  final DateTime scheduledTime;
  final String notes;
  final AppointmentStatus status;

  Appointment({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.clinicId,
    required this.scheduledTime,
    required this.notes,
    required this.status,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      patientId: json['patientId'],
      doctorId: json['doctorId'],
      clinicId: json['clinicId'],
      scheduledTime: DateTime.parse(json['scheduledTime']),
      notes: json['notes'],
      status: AppointmentStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
    );
  }
}

class AppointmentService {
  // Validate appointment details
  bool _validateAppointment(
      Doctor doctor, Clinic clinic, DateTime scheduledTime) {
    if (doctor.id.isEmpty || clinic.id.isEmpty) {
      return false;
    }

    // Check if scheduled time is in the future
    if (scheduledTime.isBefore(DateTime.now())) {
      return false;
    }

    return true;
  }

  // Create a new appointment
  Future<Appointment> createAppointment({
    required String patientId,
    required Doctor doctor,
    required Clinic clinic,
    required DateTime scheduledTime,
    String? notes,
  }) async {
    try {
      // Validate appointment before sending
      if (!_validateAppointment(doctor, clinic, scheduledTime)) {
        throw AppointmentException('Invalid appointment details');
      }

      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // In a real app, this would be a network request to create the appointment
      // For now, we'll mock a successful response

      return Appointment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        patientId: patientId,
        doctorId: doctor.id,
        clinicId: clinic.id,
        scheduledTime: scheduledTime,
        notes: notes ?? '',
        status: AppointmentStatus.pending,
      );
    } catch (e) {
      ErrorHandler.handleError(e);
      throw AppointmentException(
          'Unable to create appointment. Please try again.');
    }
  }

  // Get appointments for a specific patient
  Future<List<Appointment>> getPatientAppointments(String patientId) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Mock appointment data instead of making a real HTTP request
      final now = DateTime.now();

      return [
        Appointment(
          id: '1',
          patientId: patientId,
          doctorId: 'dr1',
          clinicId: 'clinic1',
          scheduledTime: now.add(const Duration(days: 2, hours: 3)),
          notes: 'Regular checkup',
          status: AppointmentStatus.confirmed,
        ),
        Appointment(
          id: '2',
          patientId: patientId,
          doctorId: 'dr2',
          clinicId: 'clinic2',
          scheduledTime: now.subtract(const Duration(days: 5)),
          notes: 'Flu symptoms',
          status: AppointmentStatus.completed,
        ),
        Appointment(
          id: '3',
          patientId: patientId,
          doctorId: 'dr3',
          clinicId: 'clinic1',
          scheduledTime: now.add(const Duration(days: 7)),
          notes: 'Follow-up appointment',
          status: AppointmentStatus.pending,
        ),
        Appointment(
          id: '4',
          patientId: patientId,
          doctorId: 'dr2',
          clinicId: 'clinic2',
          scheduledTime: now.subtract(const Duration(days: 10)),
          notes: 'Cancelled due to emergency',
          status: AppointmentStatus.cancelled,
        ),
      ];
    } catch (e) {
      ErrorHandler.handleError(e);
      throw AppointmentException(
          'Unable to fetch appointments. Please try again.');
    }
  }
}

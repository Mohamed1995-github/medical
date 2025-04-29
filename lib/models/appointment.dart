import 'dart:async';
import '../utils/error_handler.dart';

class AppointmentException implements Exception {
  final String message;
  AppointmentException(this.message);

  @override
  String toString() => message;
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
}

class AppointmentService {
  // Mock appointments data
  List<Appointment> _mockAppointments(String patientId) {
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
  }

  // Get appointments for a specific patient
  Future<List<Appointment>> getPatientAppointments(String patientId) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));
      return _mockAppointments(patientId);
    } catch (e) {
      // No HTTP request to handle errors from, but keep for consistency
      ErrorHandler.handleError(e);
      throw AppointmentException(
          'Unable to fetch appointments. Please try again.');
    }
  }

  // Validate appointment details (simplified)
  bool _validateAppointment(
      String doctorId, String clinicId, DateTime scheduledTime) {
    if (doctorId.isEmpty || clinicId.isEmpty) {
      return false;
    }
    if (scheduledTime.isBefore(DateTime.now())) {
      return false;
    }
    return true;
  }

  // Create a new appointment (simplified)
  Future<Appointment> createAppointment({
    required String patientId,
    required String doctorId,
    required String clinicId,
    required DateTime scheduledTime,
    String? notes,
  }) async {
    try {
      // Validate appointment
      if (!_validateAppointment(doctorId, clinicId, scheduledTime)) {
        throw AppointmentException('Invalid appointment details');
      }

      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Return a new appointment
      return Appointment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        patientId: patientId,
        doctorId: doctorId,
        clinicId: clinicId,
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
}

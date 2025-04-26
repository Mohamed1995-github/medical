import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/appointment.dart';
import '../models/doctor.dart';
import '../models/clinic.dart';
import '../utils/error_handler.dart';

class AppointmentService {
  static const String _baseUrl = 'https://your-backend-api.com/api/appointments';

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

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer $token', // Add authentication token
        },
        body: jsonEncode({
          'patientId': patientId,
          'doctorId': doctor.id,
          'clinicId': clinic.id,
          'scheduledTime': scheduledTime.toIso8601String(),
          'notes': notes ?? '',
          'status': AppointmentStatus.pending.toString().split('.').last,
        }),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> appointmentData = jsonDecode(response.body);
        return Appointment.fromJson(appointmentData);
      } else {
        final errorData = jsonDecode(response.body);
        throw AppointmentException(
          errorData['message'] ?? 'Failed to create appointment',
        );
      }
    } catch (e) {
      ErrorHandler.handleError(e);
      throw AppointmentException('Unable to create appointment. Please try again.');
    }
  }

  // Get appointments for a specific patient
  Future<List<Appointment>> getPatientAppointments(String patientId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/patient/$patientId'),
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer $token', // Add authentication token
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> appointmentsData = jsonDecode(response.body);
        return appointmentsData
            .map((appointmentJson) => Appointment.fromJson(appointmentJson))
            .toList();
      } else {
        final errorData = jsonDecode(response.body);
        throw AppointmentException(
          errorData['message'] ?? 'Failed to fetch appointments',
        );
      }
    } catch (e) {
      ErrorHandler.handleError(e);
      throw AppointmentException('Unable to fetch appointments. Please try again.');
    }
  }
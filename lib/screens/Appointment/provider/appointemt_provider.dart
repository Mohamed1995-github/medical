import 'package:flutter/material.dart';
import '/Models/Appointment/create_appointment_response.dart';
import '/NetworkManager/odoo_api_client.dart';

class AppointmentProvider with ChangeNotifier {
  final OdooApiClient _apiClient;

  // Loading states
  bool _isCreatingAppointment = false;
  bool _isLoadingHistory = false;

  // Error messages
  String? _createAppointmentError;
  String? _historyError;

  // Data
  CreateAppointmentResponse? _createAppointmentResponse;
  AppointmentHistoryItem? _appointmentHistory;

  AppointmentProvider(this._apiClient);

  // Getters
  bool get isCreatingAppointment => _isCreatingAppointment;
  bool get isLoadingHistory => _isLoadingHistory;
  String? get createAppointmentError => _createAppointmentError;
  String? get historyError => _historyError;
  CreateAppointmentResponse? get createAppointmentResponse =>
      _createAppointmentResponse;
  AppointmentHistoryItem? get appointmentHistory => _appointmentHistory;

  /// Create a new appointment
  Future<bool> createAppointment({
    required int patientId,
    required String date,
    required String consultationType,
    required int productId,
    String? physicianId,
    Map<String, dynamic>? additionalData,
  }) async {
    _isCreatingAppointment = true;
    _createAppointmentError = null;
    notifyListeners();

    try {
      // Prepare appointment data
      Map<String, dynamic> appointmentData = {
        'patient_id': patientId,
        'date': date,
        'consultation_type': consultationType,
        'product_id': productId,
        if (physicianId != null) 'physician_id': physicianId,
        ...?additionalData,
      };

      CreateAppointmentResponse response =
          await _apiClient.createAppointment(appointmentData);

      if (response.success == true) {
        _createAppointmentResponse = response;
        return true;
      } else {
        _createAppointmentError =
            response.message ?? 'Échec de la création du rendez-vous';
        return false;
      }
    } catch (e) {
      _createAppointmentError = 'Erreur de connexion. Veuillez réessayer.';
      print('Create appointment error: $e');
      return false;
    } finally {
      _isCreatingAppointment = false;
      notifyListeners();
    }
  }

  /// Get appointment history for a specific patient
  Future<void> getAppointmentHistory({int? patientId}) async {
    _isLoadingHistory = true;
    _historyError = null;
    notifyListeners();

    try {
      AppointmentHistoryItem response =
          await _apiClient.getAppointmentHistory();
      if (response.success == true) {
        _appointmentHistory = response;
        if (patientId != null) {
          _appointmentHistory = AppointmentHistoryItem(
            patient_id: response.patient_id,
            patient_name: response.patient_name,
            appointments: response.appointments
                ?.where((appointment) => appointment.id == patientId)
                .toList(),
            count: response.count,
            message: response.message,
            success: response.success,
            status: response.status,
          );
        }
      } else {
        _historyError =
            response.message ?? 'Échec du chargement de l\'historique';
      }
    } catch (e) {
      _historyError =
          'Erreur lors du chargement de l\'historique. Veuillez réessayer.';
      print('Get appointment history error: $e');
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  /// Clear all errors
  void clearErrors() {
    _createAppointmentError = null;
    _historyError = null;
    notifyListeners();
  }

  /// Clear appointment data
  void clearAppointmentData() {
    _createAppointmentResponse = null;
    _appointmentHistory = null;
    notifyListeners();
  }

  /// Reset provider state
  void reset() {
    _isCreatingAppointment = false;
    _isLoadingHistory = false;
    _createAppointmentError = null;
    _historyError = null;
    _createAppointmentResponse = null;
    _appointmentHistory = null;
    notifyListeners();
  }
}

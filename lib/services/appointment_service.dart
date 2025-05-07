import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../api/odoo_api_client.dart';
import '../api/endpoints.dart';
import '../models/appointment.dart';
import '../services/auth_service.dart';

class AppointmentService {
  final OdooApiClient _apiClient;
  final AuthService _authService;

  AppointmentService({
    required OdooApiClient apiClient,
    required AuthService authService,
  })  : _apiClient = apiClient,
        _authService = authService;

  /// Créer un nouveau rendez-vous
  Future<Appointment> createAppointment({
    required String clinicId,
    required DateTime date,
    required String time,
    required String service,
  }) async {
    try {
      // Vérifier si l'utilisateur est authentifié
      if (!_authService.isAuthenticated || _authService.currentUser == null) {
        throw Exception('Utilisateur non authentifié');
      }

      final Map<String, dynamic> params = {
        'partner_id': _authService.currentUser!.id,
        'clinic_id': clinicId,
        'date': date.toIso8601String().split('T')[0], // Format YYYY-MM-DD
        'time': time,
        'service': service,
      };

      final result =
          await _apiClient.jsonRpcCall('/si7a/create_appointment', params);

      if (result != null && result.containsKey('appointment')) {
        return Appointment.fromJson(result['appointment']);
      }

      throw Exception('Erreur lors de la création du rendez-vous');
    } catch (e) {
      if (kDebugMode) {
        print('Exception lors de la création du rendez-vous: $e');
      }
      rethrow;
    }
  }

  /// Récupérer les rendez-vous d'un utilisateur
  Future<List<Appointment>> fetchUserAppointments() async {
    try {
      // Vérifier si l'utilisateur est authentifié
      if (!_authService.isAuthenticated || _authService.currentUser == null) {
        throw Exception('Utilisateur non authentifié');
      }

      final params = {
        'partner_id': _authService.currentUser!.id,
      };

      final result =
          await _apiClient.jsonRpcCall('/si7a/user_appointments', params);

      if (result != null && result.containsKey('appointments')) {
        final List<dynamic> appointmentsData = result['appointments'];
        return appointmentsData
            .map((data) => Appointment.fromJson(data))
            .toList();
      }

      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Exception lors de la récupération des rendez-vous: $e');
      }
      rethrow;
    }
  }

  /// Récupérer les détails d'un rendez-vous spécifique
  Future<Appointment> fetchAppointmentDetails(String appointmentId) async {
    try {
      final params = {
        'appointment_id': appointmentId,
      };

      final result =
          await _apiClient.jsonRpcCall('/si7a/appointment_details', params);

      if (result != null && result.containsKey('appointment')) {
        return Appointment.fromJson(result['appointment']);
      }

      throw Exception('Rendez-vous non trouvé');
    } catch (e) {
      if (kDebugMode) {
        print(
            'Exception lors de la récupération des détails du rendez-vous: $e');
      }
      rethrow;
    }
  }

  /// Annuler un rendez-vous
  Future<bool> cancelAppointment(String appointmentId, {String? reason}) async {
    try {
      final params = {
        'appointment_id': appointmentId,
        if (reason != null) 'reason': reason,
      };

      final result =
          await _apiClient.jsonRpcCall('/si7a/cancel_appointment', params);

      if (result != null && result.containsKey('success')) {
        return result['success'] == true;
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Exception lors de l\'annulation du rendez-vous: $e');
      }
      rethrow;
    }
  }

  /// Mettre à jour un rendez-vous
  Future<Appointment> updateAppointment({
    required String appointmentId,
    String? clinicId,
    DateTime? date,
    String? time,
    String? service,
  }) async {
    try {
      final params = {
        'appointment_id': appointmentId,
        if (clinicId != null) 'clinic_id': clinicId,
        if (date != null) 'date': date.toIso8601String().split('T')[0],
        if (time != null) 'time': time,
        if (service != null) 'service': service,
      };

      final result =
          await _apiClient.jsonRpcCall('/si7a/update_appointment', params);

      if (result != null && result.containsKey('appointment')) {
        return Appointment.fromJson(result['appointment']);
      }

      throw Exception('Erreur lors de la mise à jour du rendez-vous');
    } catch (e) {
      if (kDebugMode) {
        print('Exception lors de la mise à jour du rendez-vous: $e');
      }
      rethrow;
    }
  }

  /// Effectuer un paiement pour un rendez-vous
  Future<bool> payAppointment(
    String appointmentId, {
    required String paymentMethod,
    required Map<String, dynamic> paymentDetails,
  }) async {
    try {
      final params = {
        'appointment_id': appointmentId,
        'payment_method': paymentMethod,
        'payment_details': paymentDetails,
      };

      final result =
          await _apiClient.jsonRpcCall('/si7a/pay_appointment', params);

      if (result != null && result.containsKey('success')) {
        return result['success'] == true;
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Exception lors du paiement du rendez-vous: $e');
      }
      rethrow;
    }
  }

  /// Récupérer l'historique des rendez-vous (complétés et annulés)
  Future<List<Appointment>> fetchAppointmentHistory() async {
    try {
      // Vérifier si l'utilisateur est authentifié
      if (!_authService.isAuthenticated || _authService.currentUser == null) {
        throw Exception('Utilisateur non authentifié');
      }

      final params = {
        'partner_id': _authService.currentUser!.id,
        'include_completed': true,
        'include_cancelled': true,
      };

      final result =
          await _apiClient.jsonRpcCall('/si7a/appointment_history', params);

      if (result != null && result.containsKey('appointments')) {
        final List<dynamic> appointmentsData = result['appointments'];
        return appointmentsData
            .map((data) => Appointment.fromJson(data))
            .toList();
      }

      return [];
    } catch (e) {
      if (kDebugMode) {
        print(
            'Exception lors de la récupération de l\'historique des rendez-vous: $e');
      }
      rethrow;
    }
  }

  /// Vérifier les conflits de rendez-vous pour une date et heure données
  Future<bool> checkAppointmentConflict({
    required String clinicId,
    required DateTime date,
    required String time,
  }) async {
    try {
      final params = {
        'clinic_id': clinicId,
        'date': date.toIso8601String().split('T')[0],
        'time': time,
      };

      final result = await _apiClient.jsonRpcCall(
          '/si7a/check_appointment_conflict', params);

      if (result != null && result.containsKey('conflict')) {
        return result['conflict'] == true;
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Exception lors de la vérification des conflits: $e');
      }
      rethrow;
    }
  }
}

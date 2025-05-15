/// lib/services/appointment_service.dart
import 'package:flutter/foundation.dart';
import '../api/odoo_api_client.dart';
import '../api/endpoints.dart';
import '../models/appointment.dart';
import 'auth_service.dart';

class AppointmentService {
  final OdooApiClient _api;
  final AuthService _auth;

  AppointmentService({
    required OdooApiClient apiClient,
    required AuthService authService,
  })  : _api = apiClient,
        _auth = authService;

  /// Créer un nouveau rendez-vous via JSON-RPC existant
  Future<Appointment> createAppointment({
    required String clinicId,
    required DateTime date,
    required String time,
    required String service,
  }) async {
    if (!_auth.isAuthenticated || _auth.currentUser == null) {
      throw Exception('Utilisateur non authentifié');
    }
    final params = {
      'partner_id': _auth.currentUser!.id,
      'clinic_id': clinicId,
      'date': date.toIso8601String().split('T')[0],
      'time': time,
      'service': service,
    };
    final result = await _api.jsonRpcCall(Endpoints.createAppointment, params);
    if (result != null && result.containsKey('appointment')) {
      return Appointment.fromJson(result['appointment']);
    }
    throw Exception('Erreur création RDV');
  }

  // … autres méthodes (fetchUserAppointments, cancel, etc.) inchangées
}

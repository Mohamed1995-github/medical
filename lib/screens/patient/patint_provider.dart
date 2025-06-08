import 'package:flutter/material.dart';
import 'package:medicall_app/NetworkManager/odoo_api_client.dart';
import 'package:medicall_app/helper/shared_pref.dart';
import 'package:medicall_app/models/Patient/create_patient_response.dart';

/// Provider pour gérer la création ou la récupération d'un profil patient.
class PatientProvider extends ChangeNotifier {
  final OdooApiClient _apiClient;

  bool _isLoading = false;
  int? _patientId;
  String? _error;

  /// Injection de l'API client
  PatientProvider({required OdooApiClient apiClient}) : _apiClient = apiClient;

  bool get isLoading => _isLoading;
  int? get patientId => _patientId;
  String? get error => _error;

  /// Crée un nouveau patient pour l'utilisateur connecté
  Future<void> createOrFetchPatient() async {
    print('Création ou récupération du patient.............');
    _setLoading(true);
    try {
      print('Création ou récupération du patient.............');

      // Récupération des infos utilisateur depuis les SharedPrefs
      final user = await SessionManager.getUserDetails();
      final createResp = await _apiClient.createPatient({
        'name': user.name,
        'gender': 'male',
        'gov_code': "123456789",
        'phone': user.phone,
      });

      if (createResp.success == true && createResp.patientId != null) {
        _patientId = createResp.patientId;
        // Sauvegarde en local
        await SessionManager.setpatientkey(_patientId!);
        await SessionManager.setExpirationFlag(true);
      } else {
        _error = createResp.message ?? 'Erreur lors de la création du patient.';
      }
    } catch (e) {
      _error = e.toString();
      print('Erreur lors de la création du patient: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Crée un patient tiers avec les informations fournies
  Future<void> createParentPatient(
      {required String name,
      required String nni,
      required String phone,
      String gender = 'male'}) async {
    _setLoading(true);
    try {
      final createResp = await _apiClient.createPatient({
        'name': name,
        'gender': gender,
        // 'nni': nni,
        'phone': phone,
      });

      if (createResp.success == true && createResp.patientId != null) {
        _patientId = createResp.patientId;
        await SessionManager.setpatientkey(_patientId!);
        await SessionManager.setExpirationFlag(true);
      } else {
        _error = createResp.message ??
            'Erreur lors de la création du patient tiers.';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import 'package:medical_app/Models/Clinique/cliniques_response.dart';
import 'package:medical_app/NetworkManager/odoo_api_client.dart';

class CliniqueProvider with ChangeNotifier {
  final OdooApiClient _apiClient;
  bool _isLoading = false;
  String? _errorMessage;
  CliniquesResponse? cliniquesResponse;
  CliniqueProvider(this._apiClient);
  CliniquesResponse? get code => cliniquesResponse;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> Clinique() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      CliniquesResponse response = await _apiClient.getCliniques();

      if (response.success == true) {
        cliniquesResponse = response;
      } else {
        _errorMessage = response.message ?? 'Échec de la connexion';
      }
    } catch (e) {
      _errorMessage = 'Erreur de connexion. Veuillez réessayer.';
      print('Login error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

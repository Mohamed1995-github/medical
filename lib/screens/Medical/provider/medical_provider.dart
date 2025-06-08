import 'package:flutter/foundation.dart';
import 'package:medicall_app/Models/Medical/physician_model.dart';
import 'package:medicall_app/Models/Medical/specialty_model.dart';

import '/NetworkManager/odoo_api_client.dart';
class MedicalProvider extends ChangeNotifier {
  final OdooApiClient _apiClient;

  bool _isLoadingSpecialties = false;
  bool _isLoadingPhysicians = false;
  SpecialtiesResponse? _specialties;
  PhysiciansResponse? _physicians;
  String? _error;

  MedicalProvider({required OdooApiClient apiClient}) : _apiClient = apiClient;

  bool get isLoadingSpecialties => _isLoadingSpecialties;
  bool get isLoadingPhysicians => _isLoadingPhysicians;
  SpecialtiesResponse? get specialties => _specialties;
  PhysiciansResponse? get physicians => _physicians;
  String? get error => _error;

  Future<void> fetchSpecialties() async {
    _isLoadingSpecialties = true;
    _error = null;
    notifyListeners();
    try {
      SpecialtiesResponse resp = await _apiClient.getSpecialties();
      if (resp.success == true && resp.data != null) {
        _specialties = resp;
      } else {
        _error = resp.message ?? 'Erreur lors du chargement des spécialités.';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingSpecialties = false;
      notifyListeners();
    }
  }

  Future<void> fetchPhysiciansBySpecialty(int specialtyId) async {
    _isLoadingPhysicians = true;
    _error = null;
    notifyListeners();
    try {
      PhysiciansResponse resp = await _apiClient
          .getPhysiciansBySpecialty({'specialty_id': specialtyId});
      if (resp.success == true && resp.data != null) {
        _physicians = resp;
      } else {
        _error = resp.message ?? 'Erreur lors du chargement des médecins.';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingPhysicians = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllPhysicians() async {
    _isLoadingPhysicians = true;
    _error = null;
    notifyListeners();
    try {
      PhysiciansResponse resp = await _apiClient.getPhysicianDetails();
      if (resp.success == true && resp.data != null) {
        _physicians = resp;
      } else {
        _error =
            resp.message ?? 'Erreur lors du chargement de tous les médecins.';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingPhysicians = false;
      notifyListeners();
    }
  }

  void clear() {
    _specialties = null;
    _physicians = null;
    _error = null;
    notifyListeners();
  }
}

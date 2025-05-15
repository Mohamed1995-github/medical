import 'package:flutter/foundation.dart';
import '../api/odoo_api_client.dart';
import '../api/endpoints.dart';
import '../models/clinic.dart';

class ClinicService extends ChangeNotifier {
  final OdooApiClient _apiClient;

  List<Clinic> _allClinics = [];
  List<Clinic> _filteredClinics = [];
  bool _isLoading = false;
  String? _errorMessage;

  ClinicService({OdooApiClient? apiClient})
      : _apiClient = apiClient ?? OdooApiClient();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Clinic> get clinics => _filteredClinics;

  Future<void> fetchClinics() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // ⚠️ Modification : on passe de Endpoints.clinics à Endpoints.getClinics
      final rpc = await _apiClient.jsonRpcCall(Endpoints.getClinics, {});
      final raw = rpc['cliniques'] as List<dynamic>? ?? [];
      _allClinics = raw
          .map((e) => Clinic.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      _filteredClinics = List.from(_allClinics);
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement : $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchClinics(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      _filteredClinics = List.from(_allClinics);
    } else {
      _filteredClinics = _allClinics.where((c) {
        return c.name.toLowerCase().contains(q) ||
            c.address.toLowerCase().contains(q);
      }).toList();
    }
    notifyListeners();
  }

  void clear() {
    _allClinics = [];
    _filteredClinics = [];
    _errorMessage = null;
    notifyListeners();
  }
}

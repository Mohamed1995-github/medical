// lib/services/odoo_service.dart

import '../api/odoo_api_client.dart';
import '../api/endpoints.dart';
import '../models/specialty.dart';
import '../models/physician.dart';

class OdooService {
  final OdooApiClient _apiClient;

  OdooService({required OdooApiClient apiClient}) : _apiClient = apiClient;

  /// 1) Récupère la liste des spécialités
  Future<List<Specialty>> getSpecialties() async {
    final resp = await _apiClient.jsonRpcCall(Endpoints.getSpecialties, {});
    final List data = resp['data'] as List;
    return data
        .map((m) => Specialty.fromJson(Map<String, dynamic>.from(m)))
        .toList();
  }

  /// 2) Récupère les praticiens pour une spécialité donnée
  Future<List<Physician>> getPhysiciansBySpecialty(int specialtyId) async {
    final resp = await _apiClient.jsonRpcCall(
      Endpoints.getPhysiciansBySpecialty,
      {'specialty_id': specialtyId},
    );
    final List data = resp['data'] as List;
    return data
        .map((m) => Physician.fromJson(Map<String, dynamic>.from(m)))
        .toList();
  }

  /// 3) Vérifie si un patient existe (via son numéro de CNI ou govCode)
  Future<bool> checkPatientExists(String govCode) async {
    final resp = await _apiClient.jsonRpcCall(
      Endpoints.checkPatientExists,
      {'gov_code': govCode},
    );
    return resp['exists'] as bool;
  }

  /// 4) Crée un patient et retourne son ID
  Future<int> createPatient({
    required String name,
    required String gender,
    required String govCode,
  }) async {
    final resp = await _apiClient.jsonRpcCall(
      Endpoints.createPatient,
      {
        'name': name,
        'gender': gender,
        'gov_code': govCode,
      },
    );
    return resp['patient_id'] as int;
  }

  /// 5) Crée un rendez-vous et retourne son ID
  Future<int> createAppointment({
    required int patientId,
    required int physicianId,
    required int productId,
  }) async {
    final resp = await _apiClient.jsonRpcCall(
      Endpoints.createAppointment,
      {
        'patient_id': patientId,
        'physician_id': physicianId,
        'product_id': productId,
      },
    );
    return resp['appointment_id'] as int;
  }
}

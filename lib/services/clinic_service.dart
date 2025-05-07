import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../api/odoo_api_client.dart';
import '../api/endpoints.dart';
import '../models/clinic.dart';
import '../services/auth_service.dart';

class ClinicService {
  final OdooApiClient _apiClient;
  final AuthService _authService;

  ClinicService({
    required OdooApiClient apiClient,
    required AuthService authService,
  })  : _apiClient = apiClient,
        _authService = authService;

  /// Récupérer la liste des cliniques depuis l'API
  Future<List<Clinic>> fetchClinics() async {
    try {
      // Vérifier si l'utilisateur est authentifié
      final isAuth = await _authService.checkAuthStatus();
      if (!isAuth) {
        throw OdooApiException('Utilisateur non authentifié');
      }

      // Préparer les paramètres de la requête
      final Map<String, dynamic> params = <String, dynamic>{};

      // Utiliser le client API pour faire la requête
      final result = await _apiClient.jsonRpcCall('/si7a/cliniques', params);

      // Traiter les résultats
      if (result != null && result.containsKey('data')) {
        final List<dynamic> clinicsData = result['data'];
        return clinicsData.map((data) => Clinic.fromJson(data)).toList();
      }

      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Exception lors de la récupération des cliniques: $e');
      }
      rethrow;
    }
  }

  /// Récupérer les détails d'une clinique spécifique
  Future<Clinic> fetchClinicDetails(String clinicId) async {
    try {
      final Map<String, dynamic> params = {'clinic_id': clinicId};

      final result =
          await _apiClient.jsonRpcCall('/si7a/clinique_details', params);

      if (result != null) {
        return Clinic.fromJson(result);
      }

      throw OdooApiException('Clinique non trouvée');
    } catch (e) {
      if (kDebugMode) {
        print(
            'Exception lors de la récupération des détails de la clinique: $e');
      }
      rethrow;
    }
  }

  /// Rechercher des cliniques par nom ou service
  Future<List<Clinic>> searchClinics(String query) async {
    try {
      final Map<String, dynamic> params = {'search_query': query};

      final result =
          await _apiClient.jsonRpcCall('/si7a/search_cliniques', params);

      if (result != null && result.containsKey('data')) {
        final List<dynamic> clinicsData = result['data'];
        return clinicsData.map((data) => Clinic.fromJson(data)).toList();
      }

      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Exception lors de la recherche de cliniques: $e');
      }
      rethrow;
    }
  }

  /// Récupérer les services disponibles pour une clinique
  Future<List<String>> fetchClinicServices(String clinicId) async {
    try {
      final Map<String, dynamic> params = {'clinic_id': clinicId};

      final result =
          await _apiClient.jsonRpcCall('/si7a/clinic_services', params);

      if (result != null && result.containsKey('services')) {
        final List<dynamic> servicesData = result['services'];
        return servicesData.map((service) => service.toString()).toList();
      }

      return [];
    } catch (e) {
      if (kDebugMode) {
        print(
            'Exception lors de la récupération des services de la clinique: $e');
      }
      rethrow;
    }
  }

  /// Récupérer les disponibilités d'une clinique pour une date donnée
  Future<Map<String, List<String>>> fetchClinicAvailability(
      String clinicId, DateTime date) async {
    try {
      final Map<String, dynamic> params = {
        'clinic_id': clinicId,
        'date': date.toIso8601String().split('T')[0], // Format YYYY-MM-DD
      };

      final result =
          await _apiClient.jsonRpcCall('/si7a/clinic_availability', params);

      if (result != null && result.containsKey('availability')) {
        final Map<String, dynamic> availabilityData = result['availability'];

        // Convertir la structure de données en Map<String, List<String>>
        final Map<String, List<String>> availability = {};
        availabilityData.forEach((service, times) {
          if (times is List) {
            availability[service] =
                times.map((time) => time.toString()).toList();
          }
        });

        return availability;
      }

      return {};
    } catch (e) {
      if (kDebugMode) {
        print('Exception lors de la récupération des disponibilités: $e');
      }
      rethrow;
    }
  }
}

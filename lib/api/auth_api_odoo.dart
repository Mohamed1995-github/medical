import 'odoo_api_client.dart';
import 'endpoints.dart';
import '../models/user.dart';

/// Service API pour l'authentification avec Odoo
class AuthApiOdoo {
  final OdooApiClient _apiClient;

  AuthApiOdoo({OdooApiClient? apiClient})
      : _apiClient = apiClient ?? OdooApiClient();

  /// Enregistrer un nouvel utilisateur
  ///
  /// Exemple de payload:
  /// {
  ///   "jsonrpc": "2.0",
  ///   "method": "call",
  ///   "params": {
  ///     "partner_name": "Moussa Si7a",

  ///     "partner_email": "moussa@example.com",
  ///     "nni": "1234567890",
  ///     "partner_password":"123"
  ///   }
  /// }
  Future<Map<String, dynamic>> register({
    required String partnerName,
    required String partnerPhone,
    String? partnerEmail,
    required String nni,
    required String partnerPassword,
  }) async {
    final params = {
      'partner_name': partnerName,
      'partner_phone': partnerPhone,
      if (partnerEmail != null) 'partner_email': partnerEmail,
      'nni': nni,
      'partner_password': partnerPassword,
    };

    final response = await _apiClient.jsonRpcCall(Endpoints.register, params);
    return response;
  }

  /// Connecter un utilisateur
  Future<Map<String, dynamic>> login({
    required String phoneNumber,
    required String password,
  }) async {
    final params = {
      'partner_phone': phoneNumber,
      'partner_password': password,
    };

    final response = await _apiClient.jsonRpcCall(Endpoints.login, params);
    return response;
  }

  /// Convertir la réponse d'API en modèle utilisateur
  User parseUserResponse(Map<String, dynamic> response) {
    // Adapter cette méthode selon la structure réelle de votre réponse API
    return User(
      id: response['partner_id'].toString(),
      username: response['partner_name'],
      phoneNumber: response['partner_phone'],
      cni: response['nni'],
      profileImage: response['partner_image'],
    );
  }
}

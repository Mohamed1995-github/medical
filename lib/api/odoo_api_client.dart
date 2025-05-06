import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import 'endpoints.dart';
import 'interceptors/logging_interceptor.dart';

/// Exception personnalisée pour les erreurs d'API Odoo
class OdooApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? body;

  OdooApiException(this.message, {this.statusCode, this.body});

  @override
  String toString() {
    return 'OdooApiException: $message ${statusCode != null ? '($statusCode)' : ''}';
  }
}

/// Client API pour les requêtes vers Odoo
class OdooApiClient {
  // Client HTTP
  final http.Client _httpClient;
  
  // Intercepteur de logging
  final LoggingInterceptor _loggingInterceptor;

  OdooApiClient({
    http.Client? httpClient,
    LoggingInterceptor? loggingInterceptor,
  }) : 
    _httpClient = httpClient ?? http.Client(),
    _loggingInterceptor = loggingInterceptor ?? LoggingInterceptor();

  /// Méthode pour les requêtes Odoo JSON-RPC
  Future<dynamic> jsonRpcCall(String endpoint, Map<String, dynamic> params) async {
    try {
      final uri = Uri.parse('${Endpoints.baseUrl}$endpoint');
      
      // Construire le payload JSON-RPC
      final payload = {
        'jsonrpc': '2.0',
        'method': 'call',
        'params': params,
      };
      
      // Headers de base pour JSON-RPC
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      
      // Logging de la requête
      _loggingInterceptor.onRequest('POST (JSON-RPC)', uri, body: jsonEncode(payload), headers: headers);
      
      // Exécuter la requête
      final response = await _httpClient.post(
        uri, 
        body: jsonEncode(payload),
        headers: headers,
      );
      
      // Logging de la réponse
      _loggingInterceptor.onResponse(response);
      
      // Vérifier les erreurs HTTP
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw OdooApiException(
          'Erreur HTTP: ${response.statusCode} ${response.reasonPhrase}',
          statusCode: response.statusCode,
          body: response.body,
        );
      }
      
      // Décoder la réponse JSON
      final jsonResponse = json.decode(response.body);
      
      // Vérifier les erreurs JSON-RPC
      if (jsonResponse.containsKey('error')) {
        final error = jsonResponse['error'];
        throw OdooApiException(
          error['message'] ?? 'Erreur JSON-RPC',
          body: response.body,
        );
      }
      
      // Retourner le résultat
      return jsonResponse['result'];
    } catch (e) {
      if (kDebugMode) {
        print('OdooApiClient Exception: $e');
      }
      
      // Convertir les exceptions standard en OdooApiException
      if (e is! OdooApiException) {
        throw OdooApiException('Erreur de connexion : ${e.toString()}');
      }
      rethrow;
    }
  }

  /// Fermer le client HTTP
  void close() {
    _httpClient.close();
  }
}
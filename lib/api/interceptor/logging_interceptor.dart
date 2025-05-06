import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Intercepteur pour journaliser les requêtes et réponses API
class LoggingInterceptor {
  final bool _enableLogging;

  LoggingInterceptor({bool enableLogging = kDebugMode})
      : _enableLogging = enableLogging;

  /// Journaliser une requête sortante
  void onRequest(String method, Uri uri,
      {Object? body, Map<String, String>? headers}) {
    if (!_enableLogging) return;

    print('┌───────────────────────────────────────────────');
    print('│ 🚀 REQUÊTE $method: ${uri.toString()}');

    if (headers != null) {
      print('│ 📋 HEADERS:');
      headers.forEach((key, value) {
        // Masquer les informations sensibles comme les tokens d'authentification
        if (key.toLowerCase() == 'authorization') {
          print('│   $key: ${_maskAuthToken(value)}');
        } else {
          print('│   $key: $value');
        }
      });
    }

    if (body != null) {
      print('│ 📦 BODY:');

      // Limiter la taille du corps pour éviter de surcharger les logs
      final truncatedBody = body.toString().length > 1000
          ? body.toString().substring(0, 1000) + '... (tronqué)'
          : body.toString();

      print('│ $truncatedBody');
    }

    print('└───────────────────────────────────────────────');
  }

  /// Journaliser une réponse entrante
  void onResponse(http.Response response) {
    if (!_enableLogging) return;

    print('┌───────────────────────────────────────────────');
    print(
        '│ ✅ RÉPONSE ${response.statusCode} ${response.reasonPhrase}: ${response.request?.url.toString()}');

    if (response.headers.isNotEmpty) {
      print('│ 📋 HEADERS:');
      response.headers.forEach((key, value) {
        print('│   $key: $value');
      });
    }

    if (response.body.isNotEmpty) {
      print('│ 📦 BODY:');

      // Limiter la taille du corps pour éviter de surcharger les logs
      final truncatedBody = response.body.length > 1000
          ? response.body.substring(0, 1000) + '... (tronqué)'
          : response.body;

      print('│ $truncatedBody');
    }

    print('└───────────────────────────────────────────────');
  }

  /// Journaliser une erreur
  void onError(dynamic error) {
    if (!_enableLogging) return;

    print('┌───────────────────────────────────────────────');
    print('│ ❌ ERREUR: ${error.toString()}');
    print('└───────────────────────────────────────────────');
  }

  /// Masquer le token d'authentification dans les logs
  String _maskAuthToken(String authHeader) {
    if (authHeader.startsWith('Bearer ') && authHeader.length > 15) {
      return 'Bearer ${authHeader.substring(7, 11)}...${authHeader.substring(authHeader.length - 4)}';
    }
    return authHeader;
  }
}

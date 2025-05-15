/// lib/api/odoo_api_client.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'endpoints.dart';
import 'interceptor/logging_interceptor.dart';

class OdooApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? body;
  OdooApiException(this.message, {this.statusCode, this.body});
  @override
  String toString() =>
      'OdooApiException: $message${statusCode != null ? ' ($statusCode)' : ''}';
}

class OdooApiClient {
  final http.Client _http;
  final LoggingInterceptor _log;

  OdooApiClient(
      {http.Client? httpClient, LoggingInterceptor? loggingInterceptor})
      : _http = httpClient ?? http.Client(),
        _log = loggingInterceptor ?? LoggingInterceptor();

  /// Appel JSON-RPC (votre usage existant)
  Future<dynamic> jsonRpcCall(
      String endpoint, Map<String, dynamic> params) async {
    final uri = Uri.parse('${Endpoints.baseUrl}$endpoint');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    };
    final payload = jsonEncode(params);
    _log.onRequest('POST (JSON-RPC)', uri, body: payload, headers: headers);
    final resp = await _http.post(uri, headers: headers, body: payload);
    _log.onResponse(resp);
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw OdooApiException('HTTP ${resp.statusCode}',
          statusCode: resp.statusCode, body: resp.body);
    }
    final jsonResp = json.decode(resp.body) as Map<String, dynamic>;
    if (jsonResp.containsKey('error')) {
      final err = jsonResp['error'] as Map<String, dynamic>;
      throw OdooApiException(err['message'] ?? 'Erreur JSON-RPC',
          body: resp.body);
    }
    return jsonResp['result'];
  }

  /// Appel POST JSON « standard » pour vos routes @type=json
  Future<Map<String, dynamic>> postJson(
      String endpoint, Map<String, dynamic> body) async {
    final uri = Uri.parse('${Endpoints.baseUrl}$endpoint');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    };
    final payload = jsonEncode(body);
    _log.onRequest('POST (JSON)', uri, body: payload, headers: headers);
    final resp = await _http.post(uri, headers: headers, body: payload);
    _log.onResponse(resp);
    if (resp.statusCode != 200) {
      throw OdooApiException('HTTP ${resp.statusCode}',
          statusCode: resp.statusCode, body: resp.body);
    }
    return jsonDecode(resp.body) as Map<String, dynamic>;
  }

  void close() => _http.close();
}

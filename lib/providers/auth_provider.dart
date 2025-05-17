import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:medical_app/Models/Authentication/register_response.dart';
import 'package:medical_app/Models/Authentication/send_sms_code_response.dart';
import 'package:medical_app/NetworkManager/odoo_api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medical_app/Models/Authentication/login_response.dart';

class AuthProvider with ChangeNotifier {
  final OdooApiClient _apiClient;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider(this._apiClient);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> login(String phone, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      LoginResponse response = await _apiClient.loginUser({
        'phone': phone,
        'password': password,
      });

      if (response.success == true) {
        await _saveUserData(response);
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

  Future<void> _saveUserData(LoginResponse response) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'userData',
      jsonEncode({
        'userId': response.userId,
        'partnerId': response.partnerId,
        'name': response.name,
        'email': response.email,
        'phone': response.phone,
      }),
    );
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }


  Future<void> sendVerificationCode(String phone) async {
    try {
      SendSmsCodeResponse response = await _apiClient.sendVerificationCode({
        "partner_phone": phone,
        "type": "account_creation" // Match your Odoo API requirements
      });

      if (response.success == false) {
        throw Exception(response.message ?? 'Failed to send verification code');
      }
    } catch (e) {
      throw Exception('Failed to send code: ${e.toString()}');
    }
  }

  Future<void> register({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String code,
  }) async {
    try {
       RegisterResponse response = await _apiClient.registerUser({
        "partner_name": name,
        "partner_phone": phone,
        "partner_email": email,
        "partner_password": password,
        "code": code,
        "type": "account_creation"
      });

      if (response.success == false) {
        throw Exception(response.message ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception('Registration error: ${e.toString()}');
    }
  }
}

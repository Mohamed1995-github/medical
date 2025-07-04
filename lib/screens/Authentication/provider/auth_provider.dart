import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:medicall_app/helper/shared_pref.dart';
import '/Models/Authentication/register_response.dart';
import '/Models/Authentication/send_sms_code_response.dart';
import '/Models/base_response.dart';
import '/NetworkManager/odoo_api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/Models/Authentication/login_response.dart';

class AuthProvider with ChangeNotifier {
  final OdooApiClient _apiClient;
  bool _isLoading = false;
  String? _errorMessage;
  String? code_sms;
  AuthProvider(this._apiClient);
  String? get code => code_sms;
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
        await SessionManager.saveUserData(response);
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
    code_sms = null;
    notifyListeners();
  }

  Future<void> sendVerificationCode(String phone, String type) async {
    try {
      SendSmsCodeResponse response = await _apiClient.sendVerificationCode({
        "partner_phone": phone,
        "type": type, // Match your Odoo API requirements
      });

      if (response.success == false) {
        _errorMessage = response.message ?? 'Échec de la connexion';
      } else {
        code_sms = response.code;
        _errorMessage = null; // Clear error message if successful
      }
    } catch (e) {
      _errorMessage = 'Erreur de connexion. Veuillez réessayer.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String code,
    required String nni,
  }) async {
    try {
      RegisterResponse response = await _apiClient.registerUser({
        "partner_name": name,
        "partner_phone": phone,
        "partner_email": email,
        "partner_password": password,
        "code": code,
        "type": "account_creation",
      });

      if (response.success == false) {
        _errorMessage = response.message ?? 'Échec de la connexion';
      }
    } catch (e) {
      _errorMessage = 'Erreur de connexion. Veuillez réessayer.';
    } finally {
      _isLoading = false;
      SessionManager.saveGoveCode(nni);
      notifyListeners();
    }
  }

  Future<void> resetPassword({
    required String phone,
    required String password,
    required String code,
  }) async {
    try {
      BaseModel response = await _apiClient.resetPassword({
        "phone": phone,
        "new_password": password,
        "code": code,
        "type": "reset_password",
      });

      if (response.success == false) {
        _errorMessage = response.message ?? 'Échec de la connexion';
      }
    } catch (e) {
      _errorMessage = 'Erreur de connexion. Veuillez réessayer.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

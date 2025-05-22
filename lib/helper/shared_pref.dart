import 'dart:convert';

import 'package:medicall_app/Models/Authentication/login_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service pour gérer les préférences locales (SharedPreferences).
class SessionManager {
  SessionManager._();

  static const _govecodeKey = 'govecode';
  static const _userDataKey = 'userData';
  static const _expirationKey = 'expiration';

  /// Enregistre le code gouvernemental.
  static Future<void> saveGoveCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_govecodeKey, code);
  }

  /// Récupère le code gouvernemental.
  static Future<String?> getGoveCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_govecodeKey);
  }

  /// Enregistre les données utilisateur issues de la réponse de login.
  static Future<void> saveUserData(LoginResponse response) async {
    final prefs = await SharedPreferences.getInstance();
    final userMap = {
      'userId': response.userId,
      'partnerId': response.partnerId,
      'name': response.name,
      'email': response.email,
      'phone': response.phone,
    };
    await prefs.setString(_userDataKey, jsonEncode(userMap));
  }

  /// Récupère les données utilisateur sous forme de Map.
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_userDataKey);
    if (jsonString == null) return null;
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  /// Supprime les données utilisateur enregistrées.
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userDataKey);
  }

  /// Enregistre le flag d'expiration.
  static Future<void> setExpirationFlag(bool expired) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_expirationKey, expired);
  }

  /// Récupère le flag d'expiration.
  /// Retourne `false` si aucune valeur n'est trouvée.
  static Future<bool> getcheckpatient() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_expirationKey) ?? false;
  }

  static getUserId() {}

  static getUserDetails() {}

  static savePatientId(int i) {}
}

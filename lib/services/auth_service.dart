import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService with ChangeNotifier {
  static const String _baseUrl = 'https://votre-api.com/api';

  User? _currentUser;
  String? _token;
  DateTime? _expiryDate;
  bool _isLoading = false;
  String? _error;

  // Getters
  User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isAuthenticated =>
      _token != null &&
      _expiryDate != null &&
      _expiryDate!.isAfter(DateTime.now());
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialiser le service au démarrage de l'application
  Future<bool> initializeService() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString('auth_token');
      final savedExpiryDate = prefs.getString('auth_expiry_date');
      final savedUserData = prefs.getString('user_data');

      if (savedToken != null &&
          savedExpiryDate != null &&
          savedUserData != null) {
        final expiryDate = DateTime.parse(savedExpiryDate);

        // Vérifier si le token est encore valide
        if (expiryDate.isAfter(DateTime.now())) {
          _token = savedToken;
          _expiryDate = expiryDate;
          _currentUser = User.fromJson(json.decode(savedUserData));
          _isLoading = false;
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      debugPrint(
          'Erreur lors de l\'initialisation du service d\'authentification: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Inscription
  Future<bool> register({
    required String username,
    required String phoneNumber,
    required String cni,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'phoneNumber': phoneNumber,
          'cni': cni,
          'password': password,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 201) {
        // Succès de l'inscription
        _token = responseData['token'];
        _expiryDate = DateTime.now()
            .add(Duration(hours: responseData['expiresIn'] ?? 24));
        _currentUser = User.fromJson(responseData['user']);

        // Sauvegarder les données dans SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('auth_token', _token!);
        prefs.setString('auth_expiry_date', _expiryDate!.toIso8601String());
        prefs.setString('user_data', json.encode(responseData['user']));

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // Erreur de l'inscription
        _error = responseData['message'] ??
            'Une erreur est survenue lors de l\'inscription';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Impossible de se connecter au serveur';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Connexion
  Future<bool> login({
    required String phoneNumber,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'phoneNumber': phoneNumber,
          'password': password,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        _token = responseData['token'];
        _expiryDate = DateTime.now()
            .add(Duration(hours: responseData['expiresIn'] ?? 24));
        _currentUser = User.fromJson(responseData['user']);

        // Sauvegarder les données dans SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('auth_token', _token!);
        prefs.setString('auth_expiry_date', _expiryDate!.toIso8601String());
        prefs.setString('user_data', json.encode(responseData['user']));

        _isLoading = false;
        notifyListeners();

        // Démarrer l'auto-déconnexion
        _autoLogout();

        return true;
      } else {
        // Erreur de connexion
        _error = responseData['message'] ?? 'Identifiants incorrects';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Impossible de se connecter au serveur';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Déconnexion
  Future<void> logout() async {
    _token = null;
    _expiryDate = null;
    _currentUser = null;

    final prefs = await SharedPreferences.getInstance();
    prefs.remove('auth_token');
    prefs.remove('auth_expiry_date');
    prefs.remove('user_data');

    notifyListeners();
  }

  // Auto-déconnexion lorsque le token expire
  void _autoLogout() {
    if (_expiryDate == null) {
      return;
    }

    final timeToExpiry = _expiryDate!.difference(DateTime.now()).inSeconds;

    Future.delayed(Duration(seconds: timeToExpiry), () {
      if (isAuthenticated) {
        logout();
      }
    });
  }

  // Mise à jour du profil
  Future<bool> updateProfile({
    required String username,
    required String phoneNumber,
    String? cni,
    String? profileImage,
  }) async {
    if (!isAuthenticated || _currentUser == null) {
      _error = 'Vous devez être connecté pour mettre à jour votre profil';
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/users/${_currentUser!.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: json.encode({
          'username': username,
          'phoneNumber': phoneNumber,
          'cni': cni,
          'profileImage': profileImage,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        _currentUser = User.fromJson(responseData);

        // Mettre à jour les données stockées
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('user_data', json.encode(responseData));

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = responseData['message'] ??
            'Erreur lors de la mise à jour du profil';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Impossible de se connecter au serveur';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Changement de mot de passe
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (!isAuthenticated || _currentUser == null) {
      _error = 'Vous devez être connecté pour changer votre mot de passe';
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/auth/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: json.encode({
          'userId': _currentUser!.id,
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = responseData['message'] ??
            'Erreur lors du changement de mot de passe';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Impossible de se connecter au serveur';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Réinitialisation du mot de passe
  Future<bool> requestPasswordReset({
    required String phoneNumber,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/request-reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'phoneNumber': phoneNumber,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = responseData['message'] ??
            'Erreur lors de la demande de réinitialisation du mot de passe';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Impossible de se connecter au serveur';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Confirmer la réinitialisation du mot de passe avec un code SMS
  Future<bool> confirmPasswordReset({
    required String phoneNumber,
    required String code,
    required String newPassword,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'phoneNumber': phoneNumber,
          'code': code,
          'newPassword': newPassword,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = responseData['message'] ??
            'Erreur lors de la réinitialisation du mot de passe';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Impossible de se connecter au serveur';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Vérifier si le token est encore valide
  Future<bool> checkAuthStatus() async {
    if (!isAuthenticated) {
      return false;
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/auth/check-status'),
        headers: {
          'Authorization': 'Bearer $_token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Actualiser le token
  Future<bool> refreshToken() async {
    if (_token == null) {
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/refresh-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        _token = responseData['token'];
        _expiryDate = DateTime.now()
            .add(Duration(hours: responseData['expiresIn'] ?? 24));

        // Sauvegarder les données dans SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('auth_token', _token!);
        prefs.setString('auth_expiry_date', _expiryDate!.toIso8601String());

        _autoLogout();
        notifyListeners();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../api/odoo_api_client.dart';
import '../config/routes.dart';
import '../config/theme.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  String _formatPhoneNumber(String phoneNumber) {
    phoneNumber = phoneNumber.replaceAll(RegExp(r'\s+'), '');
    phoneNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    if (phoneNumber.startsWith('+')) {
      phoneNumber = phoneNumber.substring(1);
    }
    if (phoneNumber.startsWith('222')) {
      phoneNumber = phoneNumber.substring(3);
    }
    return phoneNumber;
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final phone = _formatPhoneNumber(_phoneController.text.trim());
      final password = _passwordController.text;

      final client = Provider.of<OdooApiClient>(context, listen: false);
      final params = {
        'phone': phone,
        'password': password,
      };

      final response = await client.jsonRpcCall('/si7a/login', params);

      setState(() {
        _isLoading = false;
      });

      if (response is Map<String, dynamic> && response['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        // Sauvegarde des données utilisateur
        await prefs.setInt('user_id', response['user_id'] as int);
        await prefs.setInt('partner_id', response['partner_id'] as int);
        await prefs.setString('name', response['name'] as String);
        final email = response['email'];
        await prefs.setString('email', email is String ? email : '');
        await prefs.setString('phone', response['phone'] as String);

        // Initialise le service d'authentification
        final authService = Provider.of<AuthService>(context, listen: false);
        await authService.initializeService();

        // Navigation vers l'accueil
        NavigationHelper.navigateToHome(context);
      } else {
        setState(() {
          _errorMessage =
              response['message']?.toString() ?? 'Identifiants incorrects';
        });
      }
    } catch (e) {
      print("Exception lors de la connexion: $e");
      setState(() {
        _isLoading = false;
        if (e is OdooApiException) {
          _errorMessage = 'Erreur: ${e.message}';
        } else {
          _errorMessage = 'Une erreur est survenue: ${e.toString()}';
        }
      });
    }
  }

  void _navigateToForgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonction de récupération de mot de passe à venir'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  _buildHeader(),
                  const SizedBox(height: 40),
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade300),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade800),
                      ),
                    ),
                  CustomTextField.phoneNumber(
                    controller: _phoneController,
                    label: 'Numéro de téléphone',
                    hint: 'Entrez votre numéro de téléphone',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre numéro de téléphone';
                      }
                      if (value.length < 8) {
                        return 'Numéro de téléphone invalide';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  CustomTextField.password(
                    controller: _passwordController,
                    label: 'Mot de passe',
                    hint: 'Entrez votre mot de passe',
                    obscureText: _obscurePassword,
                    toggleVisibility: _togglePasswordVisibility,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre mot de passe';
                      }
                      if (value.length < 3) {
                        return 'Le mot de passe doit contenir au moins 3 caractères';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _navigateToForgotPassword,
                      child: const Text('Mot de passe oublié ?'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Se connecter',
                    onPressed: _login,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 24),
                  _buildRegisterOption(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            color: primaryColor,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.local_hospital,
            size: 60,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Bienvenue',
          style: Theme.of(context).textTheme.displayLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Connectez-vous pour accéder à vos rendez-vous',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: lightTextColor,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRegisterOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Vous n\'avez pas de compte ?',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        TextButton(
          onPressed: () {
            NavigationHelper.navigateToRegister(context);
          },
          child: const Text('S\'inscrire'),
        ),
      ],
    );
  }
}

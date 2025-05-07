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
    // Supprimer les espaces et autres caractères non numériques
    phoneNumber = phoneNumber.replaceAll(RegExp(r'\s+'), '');
    phoneNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');

    // Retirer le préfixe "+" si présent
    if (phoneNumber.startsWith('+')) {
      phoneNumber = phoneNumber.substring(1);
    }

    // Retirer le préfixe "222" (Mauritanie) si présent
    if (phoneNumber.startsWith('222')) {
      phoneNumber = phoneNumber.substring(3);
    }

    return phoneNumber;
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final phone = _formatPhoneNumber(_phoneController.text.trim());
        final password = _passwordController.text;

        // Appel direct à l'API Odoo en utilisant OdooApiClient
        final client = Provider.of<OdooApiClient>(context, listen: false);

        // Construire les paramètres pour l'API login
        final Map<String, dynamic> params = {
          "partner_phone": phone,
          "partner_password": password
        };

        // Appel à l'API login
        final response = await client.jsonRpcCall('/si7a/login', params);

        setState(() {
          _isLoading = false;
        });

        // Traiter la réponse
        if (response != null && response is Map<String, dynamic>) {
          if (response.containsKey('success') && response['success'] == true) {
            // Connexion réussie
            print("Connexion réussie: $response");

            // Extraire les données de l'utilisateur
            final userData = {
              'id': response['partner_id']?.toString() ?? '',
              'username': response['partner_name'] ?? '',
              'phoneNumber': phone,
              'cni': response['nni'] ?? '',
              'profileImage': response['partner_image'] ?? '',
            };

            // Créer l'objet utilisateur
            final user = User.fromJson(userData);

            // Accéder au service d'authentification
            final authService =
                Provider.of<AuthService>(context, listen: false);

            // Sauvegarder les données de session
            final prefs = await SharedPreferences.getInstance();

            // Générer un token simple si aucun n'est fourni par l'API
            final token = response['token'] ??
                'default_token_${DateTime.now().millisecondsSinceEpoch}';
            final expiryDate = DateTime.now().add(const Duration(days: 30));

            // Enregistrer les données dans les préférences partagées
            prefs.setString('auth_token', token);
            prefs.setString('auth_expiry_date', expiryDate.toIso8601String());
            prefs.setString('user_data', json.encode(userData));

            // Mettre à jour manuellement l'état du service d'authentification
            await authService.initializeService();

            // Naviguer vers la page d'accueil
            NavigationHelper.navigateToHome(context);
          } else {
            // Erreur de connexion
            setState(() {
              _errorMessage = response.containsKey('message')
                  ? response['message']
                  : 'Identifiants incorrects';
            });
          }
        } else {
          setState(() {
            _errorMessage = 'Réponse invalide du serveur';
          });
        }
      } catch (e) {
        print("Exception lors de la connexion: $e");
        setState(() {
          _isLoading = false;
          if (e is OdooApiException) {
            _errorMessage = "Erreur: ${e.message}";
          } else {
            _errorMessage = 'Une erreur est survenue: ${e.toString()}';
          }
        });
      }
    }
  }

  void _navigateToForgotPassword() {
    // Afficher un message temporaire
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

                  // Afficher le message d'erreur s'il y en a un
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
        // Logo de l'application
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api/auth_api_odoo.dart';
import '../api/odoo_api_client.dart';
import '../services/auth_service.dart';
import '../config/routes.dart';
import '../config/theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class RegisterPageOdoo extends StatefulWidget {
  const RegisterPageOdoo({Key? key}) : super(key: key);

  @override
  _RegisterPageOdooState createState() => _RegisterPageOdooState();
}

class _RegisterPageOdooState extends State<RegisterPageOdoo> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _nniController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  // Instance de l'API d'authentification
  late final AuthApiOdoo _authApi;

  @override
  void initState() {
    super.initState();
    _authApi = AuthApiOdoo();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _nniController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  Future<void> _register() async {
    // Valider le formulaire
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Appel à l'API d'enregistrement
      final response = await _authApi.register(
        partnerName: _nameController.text.trim(),
        partnerPhone: _phoneController.text.trim(),
        partnerEmail: _emailController.text.trim().isNotEmpty
            ? _emailController.text.trim()
            : null,
        nni: _nniController.text.trim(),
        partnerPassword: _passwordController.text,
      );

      setState(() {
        _isLoading = false;
      });

      // Vérifier la réponse
      if (response.containsKey('success') && response['success'] == true) {
        // Convertir la réponse en modèle utilisateur
        if (response.containsKey('data')) {
          final user = _authApi.parseUserResponse(response['data']);

          // Mettre à jour le service d'authentification avec les données de l'utilisateur
          final authService = Provider.of<AuthService>(context, listen: false);
          // Pour intégrer avec votre AuthService existant, vous pourriez avoir besoin d'adapter cette partie
          // ou d'étendre votre AuthService pour accepter les données Odoo

          // Afficher un message de succès
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Inscription réussie !'),
              backgroundColor: successColor,
            ),
          );

          // Rediriger vers la page d'accueil
          NavigationHelper.navigateToHome(context);
        } else {
          setState(() {
            _errorMessage = 'Données utilisateur manquantes dans la réponse';
          });
        }
      } else {
        // Gérer les erreurs spécifiques
        setState(() {
          _errorMessage = response.containsKey('message')
              ? response['message']
              : 'Erreur lors de l\'inscription';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        if (e is OdooApiException) {
          _errorMessage = e.message;
        } else {
          _errorMessage = 'Une erreur est survenue lors de l\'inscription';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Créer un compte')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Inscription',
                    style: Theme.of(context).textTheme.displayMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Créez votre compte pour commencer',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: lightTextColor,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Afficher les erreurs s'il y en a
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

                  // Champ Nom
                  CustomTextField(
                    label: 'Nom complet',
                    hint: 'Entrez votre nom complet',
                    controller: _nameController,
                    prefixIcon: Icons.person,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre nom';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Champ Téléphone
                  CustomTextField.phoneNumber(
                    controller: _phoneController,
                    label: 'Numéro de téléphone',
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

                  // Champ Email (optionnel)
                  CustomTextField(
                    label: 'Email (optionnel)',
                    hint: 'Entrez votre adresse email',
                    controller: _emailController,
                    prefixIcon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        // Vérification simple du format email
                        if (!value.contains('@') || !value.contains('.')) {
                          return 'Format d\'email invalide';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Champ NNI (CNI)
                  CustomTextField(
                    label: 'Numéro NNI',
                    hint: 'Entrez votre numéro NNI',
                    controller: _nniController,
                    prefixIcon: Icons.credit_card,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre numéro NNI';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Champ Mot de passe
                  CustomTextField.password(
                    controller: _passwordController,
                    label: 'Mot de passe',
                    obscureText: _obscurePassword,
                    toggleVisibility: _togglePasswordVisibility,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un mot de passe';
                      }
                      if (value.length < 6) {
                        return 'Le mot de passe doit contenir au moins 6 caractères';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Champ Confirmation de mot de passe
                  CustomTextField.password(
                    controller: _confirmPasswordController,
                    label: 'Confirmer le mot de passe',
                    obscureText: _obscureConfirmPassword,
                    toggleVisibility: _toggleConfirmPasswordVisibility,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez confirmer votre mot de passe';
                      }
                      if (value != _passwordController.text) {
                        return 'Les mots de passe ne correspondent pas';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Bouton d'inscription
                  CustomButton(
                    text: 'S\'inscrire',
                    onPressed: _register,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 24),

                  // Option de connexion
                  _buildLoginOption(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Vous avez déjà un compte ?',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Se connecter'),
        ),
      ],
    );
  }
}

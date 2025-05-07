import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api/auth_api_odoo.dart';
import '../api/odoo_api_client.dart';
import '../config/routes.dart';
import '../config/theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'dart:convert';

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
  final _codeController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  bool _acceptTerms = false;

  // États pour le flux d'inscription
  bool _smsCodeSent = false;
  String? _smsCode; // Pour stocker le code reçu du serveur

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _nniController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _codeController.dispose();
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

  // Méthode pour envoyer un code SMS
  Future<void> _sendVerificationCode() async {
    // Valider le formulaire pour les champs nécessaires
    if (_nameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _nniController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Veuillez remplir tous les champs obligatoires';
      });
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Les mots de passe ne correspondent pas';
      });
      return;
    }

    if (!_acceptTerms) {
      setState(() {
        _errorMessage = 'Vous devez accepter les conditions d\'utilisation';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final phone = _formatPhoneNumber(_phoneController.text.trim());

      // Préparer les paramètres pour l'envoi du code
      final Map<String, dynamic> params = {
        "partner_phone": phone,
        "type": "account_creation"
      };

      // Faire l'appel API directement avec le client Odoo
      final client = Provider.of<OdooApiClient>(context, listen: false);
      final response = await client.jsonRpcCall('/si7a/send_code', params);

      setState(() {
        _isLoading = false;
      });

      // Vérifier la réponse
      if (response != null && response is Map<String, dynamic>) {
        if (response.containsKey('success') && response['success'] == true) {
          // Stocker le code pour le développement/test
          if (response.containsKey('code')) {
            _smsCode = response['code'];
            // En production, ne pas remplir automatiquement
            if (_smsCode != null) {
              _codeController.text = _smsCode!;
            }
          }

          setState(() {
            _smsCodeSent = true;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Code de vérification envoyé avec succès!'),
              backgroundColor: successColor,
            ),
          );
        } else {
          setState(() {
            _errorMessage = response.containsKey('message')
                ? response['message']
                : 'Erreur lors de l\'envoi du code';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Réponse invalide du serveur';
        });
      }
    } catch (e) {
      print("Exception pendant l'envoi du code: $e");
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

  // Méthode pour finaliser l'inscription
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_codeController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Veuillez entrer le code de vérification';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final name = _nameController.text.trim();
      final phone = _formatPhoneNumber(_phoneController.text.trim());
      final email = _emailController.text.trim().isNotEmpty
          ? _emailController.text.trim()
          : null;
      final nni = _nniController.text.trim();
      final password = _passwordController.text;
      final code = _codeController.text.trim();

      // Préparer les paramètres pour l'inscription
      final Map<String, dynamic> params = {
        "partner_name": name,
        "partner_phone": phone,
        if (email != null) "partner_email": email,
        "type": "account_creation",
        "nni": nni,
        "partner_password": password,
        "code": code
      };

      // Faire l'appel API directement
      final client = Provider.of<OdooApiClient>(context, listen: false);
      final response = await client.jsonRpcCall('/si7a/register', params);

      setState(() {
        _isLoading = false;
      });

      // Traiter la réponse
      if (response != null && response is Map<String, dynamic>) {
        if (response.containsKey('success') && response['success'] == true) {
          // Inscription réussie
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Compte créé avec succès!'),
              backgroundColor: successColor,
            ),
          );

          // Naviguer vers la page de connexion
          Future.delayed(Duration(seconds: 1), () {
            NavigationHelper.navigateToLogin(context);
          });
        } else {
          // Afficher le message d'erreur
          setState(() {
            _errorMessage = response.containsKey('message')
                ? response['message']
                : 'Erreur lors de l\'inscription';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Réponse invalide du serveur';
        });
      }
    } catch (e) {
      print("Exception pendant l'inscription: $e");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_smsCodeSent ? 'Vérification' : 'Créer un compte'),
      ),
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
                  _buildHeader(),
                  const SizedBox(height: 32),

                  // Afficher les erreurs
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

                  // Afficher le formulaire approprié
                  _smsCodeSent
                      ? _buildVerificationForm()
                      : _buildRegistrationForm(),

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

  Widget _buildHeader() {
    if (_smsCodeSent) {
      return Column(
        children: [
          Icon(
            Icons.sms,
            size: 80,
            color: primaryColor,
          ),
          const SizedBox(height: 24),
          Text(
            'Vérification par SMS',
            style: Theme.of(context).textTheme.displayMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Nous avons envoyé un code de vérification à',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _phoneController.text,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    } else {
      return Column(
        children: [
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
        ],
      );
    }
  }

  Widget _buildRegistrationForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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

        CustomTextField(
          label: 'Email (optionnel)',
          hint: 'Entrez votre adresse email',
          controller: _emailController,
          prefixIcon: Icons.email,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              if (!value.contains('@') || !value.contains('.')) {
                return 'Format d\'email invalide';
              }
            }
            return null;
          },
        ),
        const SizedBox(height: 20),

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
        const SizedBox(height: 20),

        // Acceptation des termes et conditions
        Row(
          children: [
            Checkbox(
              value: _acceptTerms,
              onChanged: (value) {
                setState(() {
                  _acceptTerms = value ?? false;
                });
              },
              activeColor: primaryColor,
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _acceptTerms = !_acceptTerms;
                  });
                },
                child: Text(
                  'J\'accepte les conditions d\'utilisation et la politique de confidentialité',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),

        // Bouton pour envoyer le code de vérification
        CustomButton(
          text: 'Envoyer le code de vérification',
          onPressed: _sendVerificationCode,
          isLoading: _isLoading,
        ),
      ],
    );
  }

  Widget _buildVerificationForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomTextField(
          label: 'Code de vérification',
          hint: 'Entrez le code reçu par SMS',
          controller: _codeController,
          prefixIcon: Icons.lock_outline,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer le code de vérification';
            }
            return null;
          },
        ),
        const SizedBox(height: 32),

        // Bouton pour finaliser l'inscription
        CustomButton(
          text: 'Finaliser l\'inscription',
          onPressed: _register,
          isLoading: _isLoading,
        ),
        const SizedBox(height: 16),

        // Option pour renvoyer le code
        Center(
          child: TextButton(
            onPressed: _isLoading ? null : _sendVerificationCode,
            child: const Text('Renvoyer le code'),
          ),
        ),
      ],
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/routes.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
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
  bool _codeSent = false;

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

  Future<void> _sendVerificationCode() async {
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

      await Provider.of<AuthProvider>(
        context,
        listen: false,
      ).sendVerificationCode(phone);
      setState(() => _codeSent = true);
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptTerms) {
      setState(() => _errorMessage = 'You must accept terms & conditions');
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = 'Passwords do not match');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Provider.of<AuthProvider>(context, listen: false).register(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        code: _codeController.text.trim(),
      );

      // Navigate after successful registration
      NavigationHelper.navigateToLogin(context);
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(_codeSent ? 'Vérification' : 'Créer un compte'),
      // ),
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
                  _codeSent
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
    if (_codeSent) {
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
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      );
    } else {
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
            'Inscription',
            style: Theme.of(context).textTheme.displayMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Créez votre compte pour commencer',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: lightTextColor),
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
          onPressed: () {
            if (_codeSent) {
              _submitForm();
            } else {
              setState(
                () => _errorMessage = 'Veuillez d\'abord envoyer le code',
              );
            }
          },
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

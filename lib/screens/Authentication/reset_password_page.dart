import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import 'auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _codeSent = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  String? code_sms;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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

  void _togglePasswordVisibility() {
    setState(() => _obscurePassword = !_obscurePassword);
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
  }

  Future<void> _sendCode() async {
    if (_phoneController.text.isEmpty) {
      setState(
        () => _errorMessage = 'Veuillez entrer votre numéro de téléphone',
      );
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final phone = _formatPhoneNumber(_phoneController.text.trim());
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.clearError();
    await authProvider.sendVerificationCode(phone, "reset_password");

    setState(() => _isLoading = false);
    if (authProvider.errorMessage == null) {
      setState(() {
        _codeSent = true;
        code_sms = authProvider.code_sms;
      });
    } else {
      setState(() => _errorMessage = authProvider.errorMessage);
    }
  }

  Future<void> _submitReset() async {
    if (!_formKey.currentState!.validate()) return;

    if (_codeController.text != code_sms) {
      setState(() => _errorMessage = 'Code de vérification incorrect');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.clearError();
    await authProvider.resetPassword(
      phone: _phoneController.text.trim(),
      password: _passwordController.text.trim(),
      code: _codeController.text.trim(),
    );

    setState(() => _isLoading = false);
    if (authProvider.errorMessage == null) {
      NavigationHelper.navigateToLogin(context);
    } else {
      setState(() => _errorMessage = authProvider.errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                _buildHeader(),
                const SizedBox(height: 32),

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

                _codeSent ? _buildResetForm() : _buildPhoneForm(),

                const SizedBox(height: 24),
                _buildLoginOption(),
              ],
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
          child: const Icon(Icons.lock_reset, size: 60, color: Colors.white),
        ),
        const SizedBox(height: 24),
        Text(
          _codeSent ? 'Réinitialiser le mot de passe' : 'Mot de passe oublié ?',
          style: Theme.of(context).textTheme.displayMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          _codeSent
              ? 'Entrez le code reçu et créez un nouveau mot de passe'
              : 'Entrez votre numéro pour recevoir un code de réinitialisation',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPhoneForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomTextField.phoneNumber(
          controller: _phoneController,
          label: 'Numéro de téléphone',
          hint: 'Entrez votre numéro de téléphone',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer votre numéro';
            }
            if (value.length < 8) {
              return 'Numéro de téléphone invalide';
            }
            return null;
          },
        ),
        const SizedBox(height: 32),
        CustomButton(
          text: 'Envoyer le code',
          onPressed: _sendCode,
          isLoading: _isLoading,
        ),
      ],
    );
  }

  Widget _buildResetForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomTextField(
          label: 'Code de vérification',
          hint: 'Entrez le code reçu par SMS',
          controller: _codeController,
          prefixIcon: Icons.lock_outline,
          keyboardType: TextInputType.number,
          validator:
              (value) =>
                  value == null || value.isEmpty
                      ? 'Veuillez entrer le code'
                      : null,
        ),
        const SizedBox(height: 20),

        CustomTextField.password(
          controller: _passwordController,
          label: 'Nouveau mot de passe',
          obscureText: _obscurePassword,
          toggleVisibility: _togglePasswordVisibility,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer un mot de passe';
            }
            if (value.length < 6) {
              return 'Mot de passe trop court';
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
            if (value != _passwordController.text) {
              return 'Les mots de passe ne correspondent pas';
            }
            return null;
          },
        ),
        const SizedBox(height: 32),

        CustomButton(
          text: 'Changer le mot de passe',
          onPressed: _submitReset,
          isLoading: _isLoading,
        ),
        const SizedBox(height: 16),

        Center(
          child: TextButton(
            onPressed: _isLoading ? null : _sendCode,
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
          'Vous vous souvenez de votre mot de passe ?',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Se connecter'),
        ),
      ],
    );
  }
}

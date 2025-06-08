import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/routes.dart';
import '../../config/theme.dart';
import 'provider/auth_provider.dart';

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
  String? codeSms;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String _formatPhoneNumber(String phoneNumber) {
    phoneNumber = phoneNumber.replaceAll(RegExp(r'\s+|[^0-9+]'), '');
    if (phoneNumber.startsWith('+')) phoneNumber = phoneNumber.substring(1);
    if (phoneNumber.startsWith('222')) phoneNumber = phoneNumber.substring(3);
    return phoneNumber;
  }

  void _togglePasswordVisibility() =>
      setState(() => _obscurePassword = !_obscurePassword);
  void _toggleConfirmPasswordVisibility() =>
      setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);

  Future<void> _sendCode() async {
    if (_phoneController.text.isEmpty) {
      setState(
          () => _errorMessage = 'Veuillez entrer votre numéro de téléphone');
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

    setState(() {
      _isLoading = false;
      if (authProvider.errorMessage == null) {
        _codeSent = true;
        codeSms = authProvider.code_sms;
      } else {
        _errorMessage = authProvider.errorMessage;
      }
    });
  }

  Future<void> _submitReset() async {
    if (!_formKey.currentState!.validate()) return;
    if (_codeController.text != codeSms) {
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

    setState(() {
      _isLoading = false;
      if (authProvider.errorMessage == null) {
        NavigationHelper.navigateToLogin(context);
      } else {
        _errorMessage = authProvider.errorMessage;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.lightBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Card(
                elevation: 12,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 20),
                        if (_errorMessage != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade300),
                            ),
                            child: Text(_errorMessage!,
                                style: TextStyle(color: Colors.red.shade800)),
                          ),
                        _codeSent ? _buildResetForm() : _buildPhoneForm(),
                        const SizedBox(height: 16),
                        _buildLoginOption(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          height: 100,
          width: 100,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient:
                LinearGradient(colors: [Colors.blueAccent, Colors.lightBlue]),
          ),
          child: const Icon(Icons.lock_reset, size: 60, color: Colors.white),
        ),
        const SizedBox(height: 16),
        Text(
          _codeSent ? 'Réinitialisation' : 'Mot de passe oublié ?',
          style: Theme.of(context)
              .textTheme
              .headlineLarge
              ?.copyWith(fontWeight: FontWeight.bold, color: Colors.blueAccent),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          _codeSent
              ? 'Entrez le code et créez un nouveau mot de passe'
              : 'Entrez votre numéro pour recevoir le code',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPhoneForm() {
    return Column(
      children: [
        _buildTextField(_phoneController, 'Numéro de téléphone',
            'Entrez votre numéro', Icons.phone, false, TextInputType.phone),
        const SizedBox(height: 32),
        _buildButton('Envoyer le code', _sendCode, Icons.send),
      ],
    );
  }

  Widget _buildResetForm() {
    return Column(
      children: [
        _buildTextField(_codeController, 'Code de vérification',
            'Entrez le code', Icons.lock, false, TextInputType.number),
        const SizedBox(height: 20),
        _buildPasswordField(_passwordController, 'Nouveau mot de passe',
            _obscurePassword, _togglePasswordVisibility),
        const SizedBox(height: 20),
        _buildPasswordField(
            _confirmPasswordController,
            'Confirmer le mot de passe',
            _obscureConfirmPassword,
            _toggleConfirmPasswordVisibility),
        const SizedBox(height: 32),
        _buildButton('Changer le mot de passe', _submitReset, Icons.lock_open),
        const SizedBox(height: 16),
        TextButton(
          onPressed: _isLoading ? null : _sendCode,
          child: const Text('Renvoyer le code',
              style: TextStyle(color: Colors.blueAccent)),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      String hint, IconData icon, bool obscure,
      [TextInputType type = TextInputType.text]) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Colors.blueAccent, width: 2)),
      ),
      validator: (value) =>
          (value == null || value.isEmpty) ? 'Veuillez entrer $label' : null,
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String label,
      bool obscure, VoidCallback toggle) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        hintText: 'Entrez $label',
        prefixIcon: const Icon(Icons.lock, color: Colors.blueAccent),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility : Icons.visibility_off,
              color: Colors.blueAccent),
          onPressed: toggle,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Colors.blueAccent, width: 2)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Veuillez entrer $label';
        if (label.contains('Confirmer') && value != _passwordController.text)
          return 'Les mots de passe ne correspondent pas';
        if (label.contains('Nouveau') && value.length < 6)
          return 'Mot de passe trop court';
        return null;
      },
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed, IconData icon) {
    return SizedBox(
      height: 60,
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Colors.white),
        label: Text(text, style: const TextStyle(fontSize: 18)),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildLoginOption() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text('Vous vous souvenez de votre mot de passe ?',
              style: Theme.of(context).textTheme.bodyMedium),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Se connecter',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

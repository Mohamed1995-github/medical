import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/routes.dart';
import '../../config/theme.dart';
import 'provider/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _codeController = TextEditingController();

  String? _selectedSex;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  bool _acceptTerms = false;
  bool _codeSent = false;
  String? codeSms;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() => _obscurePassword = !_obscurePassword);
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
  }

  String _formatPhoneNumber(String phoneNumber) {
    phoneNumber = phoneNumber.replaceAll(RegExp(r'\s+|[^0-9+]'), '');
    if (phoneNumber.startsWith('+')) phoneNumber = phoneNumber.substring(1);
    if (phoneNumber.startsWith('222')) phoneNumber = phoneNumber.substring(3);
    return phoneNumber;
  }

  Future<void> _sendVerificationCode() async {
    if (_nameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _selectedSex == null) {
      setState(() => _errorMessage = 'Veuillez remplir tous les champs obligatoires');
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = 'Les mots de passe ne correspondent pas');
      return;
    }
    if (!_acceptTerms) {
      setState(() => _errorMessage = 'Veuillez accepter les conditions');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final phone = _formatPhoneNumber(_phoneController.text.trim());
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.clearError();
    await authProvider.sendVerificationCode(phone, "account_creation");
    setState(() => _isLoading = false);

    if (authProvider.errorMessage == null) {
      setState(() {
        _codeSent = true;
        codeSms = authProvider.code_sms;
      });
    } else {
      setState(() => _errorMessage = authProvider.errorMessage);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_codeController.text.isEmpty || _codeController.text != codeSms) {
      setState(() => _errorMessage = 'Veuillez entrer le code de vérification');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.clearError();
    await authProvider.register(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      code: _codeController.text.trim(),
      nni: '', // Removed NNI
      // sexe: _selectedSex ?? '',
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.lightBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Card(
                elevation: 12,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
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
                            child: Text(_errorMessage!, style: TextStyle(color: Colors.red.shade800)),
                          ),
                        _codeSent ? _buildVerificationForm() : _buildRegistrationForm(),
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
            gradient: LinearGradient(colors: [Colors.blueAccent, Colors.lightBlue]),
          ),
          child: const Icon(Icons.person_add, size: 60, color: Colors.white),
        ),
        const SizedBox(height: 16),
        Text(
          _codeSent ? 'Vérification par SMS' : 'Inscription',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.blueAccent),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          _codeSent
              ? 'Nous avons envoyé un code à ${_phoneController.text}'
              : 'Créez votre compte pour commencer',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRegistrationForm() {
    return Column(
      children: [
        _buildTextField(_nameController, 'Nom complet', 'Entrez votre nom complet', Icons.person, false),
        const SizedBox(height: 20),
        CustomTextField.phoneNumber(
          controller: _phoneController,
          label: 'Numéro de téléphone',
          hint: 'Entrez votre numéro',
          validator: (value) => (value == null || value.isEmpty) ? 'Entrez votre numéro' : null,
        ),
        const SizedBox(height: 20),
        _buildTextField(_emailController, 'Email (optionnel)', 'Entrez votre email', Icons.email, false, TextInputType.emailAddress),
        const SizedBox(height: 20),
        _buildSexField(),
        const SizedBox(height: 20),
        _buildPasswordField(_passwordController, 'Mot de passe', _obscurePassword, _togglePasswordVisibility),
        const SizedBox(height: 20),
        _buildPasswordField(_confirmPasswordController, 'Confirmer le mot de passe', _obscureConfirmPassword, _toggleConfirmPasswordVisibility),
        const SizedBox(height: 20),
        Row(
          children: [
            Checkbox(
              value: _acceptTerms,
              onChanged: (val) => setState(() => _acceptTerms = val ?? false),
              activeColor: Colors.blueAccent,
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _acceptTerms = !_acceptTerms),
                child: Text('J\'accepte les conditions d\'utilisation', style: Theme.of(context).textTheme.bodySmall),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildButton('Envoyer le code de vérification', _sendVerificationCode),
      ],
    );
  }

  Widget _buildVerificationForm() {
    return Column(
      children: [
        _buildTextField(_codeController, 'Code de vérification', 'Entrez le code', Icons.lock, false, TextInputType.number),
        const SizedBox(height: 20),
        _buildButton('Finaliser l\'inscription', _submitForm),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: _isLoading ? null : _sendVerificationCode,
            child: const Text('Renvoyer le code'),
          ),
        ),
      ],
    );
  }

  Widget _buildSexField() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Sexe',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        prefixIcon: const Icon(Icons.wc, color: Colors.blueAccent),
      ),
      items: ['Homme', 'Femme'].map((sex) => DropdownMenuItem(value: sex, child: Text(sex))).toList(),
      value: _selectedSex,
      onChanged: (value) => setState(() => _selectedSex = value),
      validator: (value) => value == null ? 'Veuillez sélectionner le sexe' : null,
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint, IconData icon,
      bool obscure, [TextInputType keyboardType = TextInputType.text]) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
        ),
      ),
      validator: (value) => (value == null || value.isEmpty) ? 'Veuillez entrer $label' : null,
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String label, bool obscure, VoidCallback toggle) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        hintText: 'Entrez $label',
        prefixIcon: Icon(Icons.lock, color: Colors.blueAccent),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility : Icons.visibility_off, color: Colors.blueAccent),
          onPressed: toggle,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
        ),
      ),
      validator: (value) => (value == null || value.isEmpty) ? 'Veuillez entrer $label' : null,
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return SizedBox(
      height: 60,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.check_circle, color: Colors.white),
        label: Text(text, style: const TextStyle(fontSize: 18)),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildLoginOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Vous avez déjà un compte ?', style: Theme.of(context).textTheme.bodyMedium),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Se connecter', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

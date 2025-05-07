import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../api/auth_api_odoo.dart';
import '../config/routes.dart';
import '../config/theme.dart';
import '../widgets/custom_button.dart';

class VerifySmsCodePage extends StatefulWidget {
  final String phoneNumber;
  final String userId;
  final bool isRegistration;

  const VerifySmsCodePage({
    Key? key,
    required this.phoneNumber,
    required this.userId,
    this.isRegistration = true,
  }) : super(key: key);

  @override
  _VerifySmsCodePageState createState() => _VerifySmsCodePageState();
}

class _VerifySmsCodePageState extends State<VerifySmsCodePage> {
  final List<TextEditingController> _codeControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );

  bool _isLoading = false;
  int _countdown = 60;
  bool _enableResend = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    startCountdown();
  }

  @override
  void dispose() {
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  // Démarrer le compte à rebours pour le renvoi du code
  void startCountdown() {
    setState(() {
      _countdown = 60;
      _enableResend = false;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _countdown--;
        });
        if (_countdown > 0) {
          startCountdown();
        } else {
          setState(() {
            _enableResend = true;
          });
        }
      }
    });
  }

  // Obtenir le code complet à partir des contrôleurs
  String getCompleteCode() {
    return _codeControllers.map((controller) => controller.text).join();
  }

  // Vérifier le code SMS
  Future<void> verifyCode() async {
    final code = getCompleteCode();

    if (code.length != 6) {
      setState(() {
        _errorMessage = 'Veuillez entrer le code complet à 6 chiffres';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authApi = Provider.of<AuthApiOdoo>(context, listen: false);

      final response = await authApi.verifyPhoneCode(
        phoneNumber: widget.phoneNumber,
        code: code,
        userId: widget.userId,
      );

      setState(() {
        _isLoading = false;
      });

      if (response.containsKey('success') && response['success'] == true) {
        // Vérification réussie
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Numéro vérifié avec succès !'),
            backgroundColor: successColor,
          ),
        );

        // Naviguer vers la page de connexion ou la page d'accueil
        if (widget.isRegistration) {
          NavigationHelper.navigateToLogin(context);
        } else {
          NavigationHelper.navigateToHome(context);
        }
      } else {
        // Erreur de vérification
        setState(() {
          _errorMessage = response.containsKey('message')
              ? response['message']
              : 'Code de vérification incorrect';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Une erreur est survenue: ${e.toString()}';
      });
    }
  }

  // Renvoyer le code de vérification
  Future<void> resendCode() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authApi = Provider.of<AuthApiOdoo>(context, listen: false);

      final response = await authApi.resendVerificationCode(
        phoneNumber: widget.phoneNumber,
        userId: widget.userId,
      );

      setState(() {
        _isLoading = false;
      });

      if (response.containsKey('success') && response['success'] == true) {
        // Renvoi réussi, redémarrer le compte à rebours
        startCountdown();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nouveau code envoyé avec succès !'),
            backgroundColor: successColor,
          ),
        );
      } else {
        // Erreur de renvoi
        setState(() {
          _errorMessage = response.containsKey('message')
              ? response['message']
              : 'Erreur lors de l\'envoi du code';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Une erreur est survenue: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vérification'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                _buildHeader(),
                const SizedBox(height: 40),
                _buildVerificationCodeFields(),
                const SizedBox(height: 20),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: errorColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                CustomButton(
                  text: 'Vérifier',
                  onPressed: verifyCode,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 24),
                _buildResendOption(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
          widget.phoneNumber,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildVerificationCodeFields() {
    return Column(
      children: [
        Text(
          'Entrez le code à 6 chiffres',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            6,
            (index) => SizedBox(
              width: 40,
              child: TextField(
                controller: _codeControllers[index],
                focusNode: _focusNodes[index],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                decoration: InputDecoration(
                  counterText: '',
                  contentPadding: EdgeInsets.zero,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: lightTextColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: primaryColor, width: 2),
                  ),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    // Passer au champ suivant
                    if (index < 5) {
                      _focusNodes[index + 1].requestFocus();
                    } else {
                      // Dernier champ, masquer le clavier
                      FocusManager.instance.primaryFocus?.unfocus();
                    }
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResendOption() {
    return Column(
      children: [
        Text(
          'Vous n\'avez pas reçu de code ?',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        _enableResend
            ? TextButton(
                onPressed: resendCode,
                child: const Text('Renvoyer le code'),
              )
            : Text(
                'Renvoyer le code dans $_countdown secondes',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: lightTextColor,
                    ),
              ),
      ],
    );
  }
}

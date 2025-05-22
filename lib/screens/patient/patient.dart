import 'package:flutter/material.dart';
import 'package:medicall_app/config/theme.dart';
import 'package:medicall_app/helper/shared_pref.dart';
import 'package:medicall_app/widgets/custom_button.dart';
import 'package:provider/provider.dart';
import 'package:medicall_app/screens/patient/patint_provider.dart';

/// Écran pour choisir si le patient est soi-même ou une autre personne.
class PatientChoicePage extends StatelessWidget {
  const PatientChoicePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choix du patient'),
        backgroundColor: primaryColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Pour qui prenez-vous rendez-vous ?',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              CustomButton(
                text: 'Pour moi',
                onPressed: () {
                  print(
                      'Patient existant, redirection vers la page d\'accueil');
                  SessionManager.getcheckpatient().then((hasPatient) {
                    print('Patient existant: \$hasPatient');
                    if (hasPatient == true) {
                      print(
                          'Patient existant, redirection vers la page d\'accueil');
                      Navigator.pushNamed(context, '/home');
                    } else {
                      print(
                          'Pas de patient existant, création d\'un nouveau patient');
                      context.read<PatientProvider>().createOrFetchPatient();
                    }
                  }).catchError((error) {
                    // Gestion d'erreur
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur: \$error')),
                    );
                  });
                },
                backgroundColor: primaryColor,
                textColor: Colors.white,
                borderColor: primaryColor,
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Pour un autre',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ThirdPartyPatientFormPage(),
                    ),
                  );
                },
                backgroundColor: Colors.white,
                textColor: primaryColor,
                borderColor: primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Écran de saisie des informations pour un patient tiers.
class ThirdPartyPatientFormPage extends StatefulWidget {
  const ThirdPartyPatientFormPage({Key? key}) : super(key: key);

  @override
  State<ThirdPartyPatientFormPage> createState() =>
      _ThirdPartyPatientFormPageState();
}

class _ThirdPartyPatientFormPageState extends State<ThirdPartyPatientFormPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nniController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _nniController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() == true) {
      final name = _nameController.text.trim();
      final gov_code = _nniController.text.trim();
      final phone = _phoneController.text.trim();
      // TODO: traiter les données du patient tiers
      // APRÈS
      context.read<PatientProvider>().createParentPatient(
            name: name,
            nni: gov_code,
            phone: phone,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informations du patient'),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom complet',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Veuillez entrer un nom.'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nniController,
                decoration: const InputDecoration(
                  labelText: 'NNI',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty
                    ? 'Veuillez entrer le NNI.'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Téléphone',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) => value == null || value.isEmpty
                    ? 'Veuillez entrer un numéro de téléphone.'
                    : null,
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Continuer',
                onPressed: _submit,
                backgroundColor: primaryColor,
                textColor: Colors.white,
                borderColor: primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

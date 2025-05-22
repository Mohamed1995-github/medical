import 'package:flutter/material.dart';
import 'package:medicall_app/config/theme.dart';
import 'package:medicall_app/helper/shared_pref.dart';
import 'package:medicall_app/screens/home/home_provider.dart';
import 'package:medicall_app/widgets/custom_button.dart';
import 'package:provider/provider.dart';
import 'package:medicall_app/config/routes.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _patientIdController = TextEditingController();
  final _newPatientNameController = TextEditingController();

  @override
  void dispose() {
    _patientIdController.dispose();
    _newPatientNameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // On lance l’appel asynchrone sans modifier la signature initState
    Future.microtask(() async {
      final nni = await SessionManager.getGoveCode();
      Provider.of<HomeProvider>(context, listen: false).checkPatient(nni ?? '');
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil'),
        backgroundColor: primaryColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CustomButton(
          text: 'Créer un rendez-vous',
          backgroundColor: primaryColor,
          textColor: Colors.white,
          borderColor: Colors.white,
          onPressed: () {
            Navigator.pushNamed(context, '/patient-choice');
          },
        ),
      ),
    );
  }
}

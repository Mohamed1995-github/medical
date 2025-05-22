import 'package:flutter/material.dart';
import 'package:medicall_app/Models/Medical/specialty_model.dart';
import 'package:provider/provider.dart';
import 'package:medicall_app/config/theme.dart';
import 'package:medicall_app/screens/Medical/medical_provider.dart';
import 'package:medicall_app/screens/Medical/physisian.dart';

/// Écran affichant la liste des spécialités médicales
class SpecialtyScreen extends StatefulWidget {
  const SpecialtyScreen({Key? key}) : super(key: key);

  @override
  _SpecialtyScreenState createState() => _SpecialtyScreenState();
}

class _SpecialtyScreenState extends State<SpecialtyScreen> {
  @override
  void initState() {
    super.initState();
    // Charger les spécialités au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MedicalProvider>().fetchSpecialties();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MedicalProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spécialités'),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: provider.isLoadingSpecialties
            ? const Center(child: CircularProgressIndicator())
            : provider.error != null
                ? Center(child: Text(provider.error!))
                : ListView.builder(
                    itemCount: provider.specialties?.data?.length,
                    itemBuilder: (context, index) {
                      SpecialtyModel? spec = provider.specialties?.data![index];
                      return Card(
                        child: ListTile(
                          title: Text(spec?.name ?? 'Nom non disponible'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PhysicianScreen(
                                  specialtyId: spec?.id ?? 0,
                                  specialtyName:
                                      spec?.name ?? 'Nom non disponible',
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}

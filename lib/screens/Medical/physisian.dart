import 'package:flutter/material.dart';
import 'package:medicall_app/Models/Medical/physician_model.dart';
import 'package:provider/provider.dart';
import 'package:medicall_app/config/theme.dart';
import 'package:medicall_app/screens/Medical/provider/medical_provider.dart';

import '../../config/routes.dart';

class PhysicianScreen extends StatefulWidget {
  final int specialtyId;
  final String specialtyName;

  const PhysicianScreen({
    Key? key,
    required this.specialtyId,
    required this.specialtyName,
  }) : super(key: key);

  @override
  _PhysicianScreenState createState() => _PhysicianScreenState();
}

class _PhysicianScreenState extends State<PhysicianScreen> {
  @override
  void initState() {
    super.initState();
    // Charger les médecins de la spécialité
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<MedicalProvider>()
          .fetchPhysiciansBySpecialty(widget.specialtyId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MedicalProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.specialtyName),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: provider.isLoadingPhysicians
            ? const Center(child: CircularProgressIndicator())
            : provider.error != null
                ? Center(child: Text(provider.error!))
                : ListView.builder(
                    itemCount: provider.physicians!.data?.length ?? 0,
                    itemBuilder: (context, index) {
                      PhysicianModel? doc = provider.physicians?.data![index];
                      return Card(
                        child: ListTile(
                          title: Text(doc?.name ?? 'Nom non disponible'),
                          subtitle: Text(
                              doc?.specialty ?? 'Spécialité non disponible'),
                          onTap: () {
                            NavigationHelper.navigateToPayment(context);
                          },
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}

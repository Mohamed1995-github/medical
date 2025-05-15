// lib/screens/clinic_list_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:medicall_app/models/clinic.dart';
import 'package:medicall_app/services/clinic_service.dart';
import 'package:medicall_app/services/auth_service.dart';
import 'package:medicall_app/screens/create_appointment_page.dart';

class ClinicListPage extends StatefulWidget {
  const ClinicListPage({Key? key}) : super(key: key);

  @override
  _ClinicListPageState createState() => _ClinicListPageState();
}

class _ClinicListPageState extends State<ClinicListPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Charger les cliniques après build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClinicService>().fetchClinics();
    });
    _searchController.addListener(() {
      context.read<ClinicService>().searchClinics(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAppointmentPage(Clinic clinic) {
    final user = context.read<AuthService>().currentUser;
    if (user == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }
    final govCode = user.cni; // Assurez-vous que cni est bien votre gov_code

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateAppointmentPage(
          clinic: clinic,
          govCode: govCode,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<ClinicService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cliniques'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => service.fetchClinics(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Recherche
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher une clinique…',
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),

          // Liste
          Expanded(
            child: service.isLoading
                ? const Center(child: CircularProgressIndicator())
                : service.errorMessage != null
                    ? Center(child: Text(service.errorMessage!))
                    : service.clinics.isEmpty
                        ? const Center(child: Text('Aucune clinique trouvée'))
                        : ListView.builder(
                            itemCount: service.clinics.length,
                            itemBuilder: (context, idx) {
                              final clinic = service.clinics[idx];
                              Widget leading;
                              if (clinic.imageBytes != null) {
                                leading = ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.memory(
                                    clinic.imageBytes!,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              } else {
                                leading = const Icon(Icons.local_hospital,
                                    size: 60, color: Colors.grey);
                              }

                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                elevation: 3,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () => _openAppointmentPage(clinic),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        leading,
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(clinic.name,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium),
                                              const SizedBox(height: 4),
                                              // Utilisation de `address`, pas `location`
                                              Text(clinic.address,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium),
                                            ],
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () =>
                                              _openAppointmentPage(clinic),
                                          child: const Text('Réserver'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

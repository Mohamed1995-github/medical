// lib/screens/clinic_list_page.dart

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:medicall_app/models/clinic.dart';
import 'package:medicall_app/services/clinic_service.dart';
import 'package:medicall_app/services/auth_service.dart';
// **Ajout** de cet import pour NavigationHelper
import 'package:medicall_app/config/routes.dart';

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

  void _goToAppointment(Clinic clinic) {
    final user = context.read<AuthService>().currentUser;
    if (user == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }
    final govCode = user.cni; // Votre numéro de CNI

    // On utilise NavigationHelper défini dans routes.dart
    NavigationHelper.navigateToCreateAppointment(
      context,
      clinic: clinic,
      govCode: govCode,
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher une clinique…',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Expanded(
            child: service.isLoading
                ? const Center(child: CircularProgressIndicator())
                : service.errorMessage != null
                    ? Center(child: Text(service.errorMessage!))
                    : service.clinics.isEmpty
                        ? const Center(child: Text('Aucune clinique trouvée'))
                        : ListView.builder(
                            itemCount: service.clinics.length,
                            itemBuilder: (_, idx) {
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
                                leading = const Icon(
                                  Icons.local_hospital,
                                  size: 60,
                                  color: Colors.grey,
                                );
                              }

                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 3,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () => _goToAppointment(clinic),
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
                                              Text(
                                                clinic.name,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                clinic.address,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium,
                                              ),
                                            ],
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () =>
                                              _goToAppointment(clinic),
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

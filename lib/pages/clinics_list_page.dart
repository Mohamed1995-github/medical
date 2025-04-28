import 'package:flutter/material.dart';
import '../models/clinic.dart';
import '../widgets/clinic_card.dart';
import '../pages/create_appointment_page.dart';

class ClinicsListPage extends StatefulWidget {
  const ClinicsListPage({super.key});

  @override
  State<ClinicsListPage> createState() => _ClinicsListPageState();
}

class _ClinicsListPageState extends State<ClinicsListPage> {
  bool _isLoading = true;
  String? _errorMessage;
  List<Clinic> _clinics = [];
  String _searchQuery = '';
  String _selectedSpecialty = 'All';

  final List<String> _specialties = [
    'All',
    ClinicSpecialty.cardiology.name,
    ClinicSpecialty.dermatology.name,
    ClinicSpecialty.neurology.name,
  ];

  @override
  void initState() {
    super.initState();
    _fetchClinics();
  }

  Future<void> _fetchClinics() async {
    // This would be replaced with a real API call
    await Future.delayed(const Duration(seconds: 1));

    // Simulated clinic data
    final clinics = [
      Clinic(
        id: '1',
        name: 'Central Medical Clinic',
        address: '123 Health St, Medical City',
        phoneNumber: '+123456789',
        emailAddress: 'info@centralmedical.com',
        isVerified: true,
        specialties: [ClinicSpecialty.cardiology],
        operatingHours: {
          'monday': {'open': '09:00', 'close': '17:00'},
          'tuesday': {'open': '09:00', 'close': '17:00'},
          'wednesday': {'open': '09:00', 'close': '17:00'},
          'thursday': {'open': '09:00', 'close': '17:00'},
          'friday': {'open': '09:00', 'close': '17:00'},
          'saturday': {'open': '10:00', 'close': '15:00'},
          'sunday': {'open': '', 'close': ''},
        },
      ),
      Clinic(
        id: '2',
        name: 'Specialist Care Center',
        address: '789 Expert Blvd, Medical City',
        phoneNumber: '+345678901',
        emailAddress: 'info@specialistcare.com',
        isVerified: true,
        specialties: [
          ClinicSpecialty.cardiology,
          ClinicSpecialty.neurology,
          // ClinicSpecialty.orthopedics
        ],
        operatingHours: {
          'monday': {'open': '09:00', 'close': '17:00'},
          'tuesday': {'open': '09:00', 'close': '17:00'},
          'wednesday': {'open': '09:00', 'close': '17:00'},
          'thursday': {'open': '09:00', 'close': '17:00'},
          'friday': {'open': '09:00', 'close': '17:00'},
          'saturday': {'open': '', 'close': ''},
          'sunday': {'open': '', 'close': ''},
        },
      ),
    ];

    if (mounted) {
      setState(() {
        _clinics = clinics;
        _isLoading = false;
      });
    }
  }

  List<Clinic> get _filteredClinics {
    return _clinics.where((clinic) {
      // Filter by search query
      final matchesQuery =
          clinic.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              clinic.address.toLowerCase().contains(_searchQuery.toLowerCase());

      // Filter by specialty
      final matchesSpecialty = _selectedSpecialty == 'All' ||
          clinic.specialties.contains(_selectedSpecialty);

      return matchesQuery && matchesSpecialty;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Clinics'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchClinics,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search clinics...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Specialty',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedSpecialty,
                        items: _specialties.map((specialty) {
                          return DropdownMenuItem<String>(
                            value: specialty,
                            child: Text(specialty),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedSpecialty = value;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: _filteredClinics.isEmpty
                          ? const Center(
                              child: Text(
                                'No clinics found matching your criteria',
                                style: TextStyle(fontSize: 16),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredClinics.length,
                              itemBuilder: (context, index) {
                                final clinic = _filteredClinics[index];
                                return ClinicCard(
                                  clinic: clinic,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            CreateAppointmentPage(
                                          clinic: clinic,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/clinic.dart';
import '../models/doctor.dart';
// import '../widgets/doctor_card.dart'; // Remove this self-import to avoid circular reference
import '../utils/error_handler.dart';

class DoctorsListPage extends StatefulWidget {
  final Clinic clinic;

  const DoctorsListPage({
    super.key,
    required this.clinic,
  });

  @override
  State<DoctorsListPage> createState() => _DoctorsListPageState();
}

class _DoctorsListPageState extends State<DoctorsListPage> {
  final _searchController = TextEditingController();
  bool _isLoading = true;
  String? _errorMessage;
  List<Doctor> _doctors = [];
  List<Doctor> _filteredDoctors = [];
  DoctorSpecialty? _selectedSpecialty;

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchDoctors() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Simulated data fetch
      // In a real app, replace this with an API call
      await Future.delayed(const Duration(seconds: 1));

      // Dummy data for testing
      final dummyDoctors = [
        Doctor(
          id: '1',
          name: 'Dr. Sarah Johnson',
          specialty: DoctorSpecialty.generalPractice,
          email: 'sarah.johnson@medicalclinic.com',
          phoneNumber: '555-1111',
          qualifications: 'MD, General Medicine',
          bio:
              'Dr. Johnson has 15 years of experience in general medicine and is dedicated to providing comprehensive care for the whole family.',
          isVerified: true,
          associatedClinics: [widget.clinic],
          availabilitySchedule: {
            'monday': {'start': '09:00', 'end': '17:00'},
            'wednesday': {'start': '09:00', 'end': '17:00'},
            'friday': {'start': '09:00', 'end': '17:00'},
          },
        ),
        Doctor(
          id: '2',
          name: 'Dr. Michael Chen',
          specialty: DoctorSpecialty.cardiology,
          email: 'michael.chen@medicalclinic.com',
          phoneNumber: '555-2222',
          qualifications: 'MD, Cardiology Specialist',
          bio:
              'Dr. Chen specializes in cardiovascular health and preventive care with over 10 years of experience in treating heart conditions.',
          isVerified: true,
          associatedClinics: [widget.clinic],
          availabilitySchedule: {
            'monday': {'start': '10:00', 'end': '16:00'},
            'thursday': {'start': '10:00', 'end': '18:00'},
          },
        ),
        Doctor(
          id: '3',
          name: 'Dr. Emily Rodriguez',
          specialty: DoctorSpecialty.pediatrics,
          email: 'emily.rodriguez@medicalclinic.com',
          phoneNumber: '555-3333',
          qualifications: 'MD, Pediatrics',
          bio:
              'Dr. Rodriguez has a passion for children\'s health and development. She provides comprehensive care from newborns to adolescents.',
          isVerified: true,
          associatedClinics: [widget.clinic],
          availabilitySchedule: {
            'tuesday': {'start': '09:00', 'end': '17:00'},
            'thursday': {'start': '09:00', 'end': '17:00'},
            'friday': {'start': '09:00', 'end': '13:00'},
          },
        ),
        Doctor(
          id: '4',
          name: 'Dr. Robert Wilson',
          specialty: DoctorSpecialty.dermatology,
          email: 'robert.wilson@medicalclinic.com',
          phoneNumber: '555-4444',
          qualifications: 'MD, Dermatology',
          bio:
              'Dr. Wilson is a board-certified dermatologist specializing in skin conditions, cosmetic procedures, and skin cancer detection.',
          isVerified: true,
          associatedClinics: [widget.clinic],
          availabilitySchedule: {
            'wednesday': {'start': '11:00', 'end': '18:00'},
            'saturday': {'start': '10:00', 'end': '14:00'},
          },
        ),
      ];

      setState(() {
        _doctors = dummyDoctors;
        _filteredDoctors = dummyDoctors;
        _isLoading = false;
      });
    } catch (e) {
      ErrorHandler.handleError(e);
      setState(() {
        _errorMessage = ErrorHandler.getErrorMessage(e);
        _isLoading = false;
      });
    }
  }

  void _filterDoctors(String query) {
    List<Doctor> filtered = _doctors;

    // Filter by search query
    if (query.isNotEmpty) {
      filtered = filtered
          .where((doctor) =>
              doctor.name.toLowerCase().contains(query.toLowerCase()) ||
              doctor.specialty
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              doctor.qualifications.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    // Filter by selected specialty
    if (_selectedSpecialty != null) {
      filtered = filtered
          .where((doctor) => doctor.specialty == _selectedSpecialty)
          .toList();
    }

    setState(() {
      _filteredDoctors = filtered;
    });
  }

  String _formatSpecialtyName(DoctorSpecialty specialty) {
    return specialty
        .toString()
        .split('.')
        .last
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match[1]}')
        .trim()
        .replaceFirstMapped(RegExp(r'^.'),
            (Match match) => match.group(0)?.toUpperCase() ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doctors at ${widget.clinic.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchDoctors,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or specialty',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterDoctors('');
                        },
                      )
                    : null,
              ),
              onChanged: _filterDoctors,
            ),
          ),

          // Specialty Filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All Specialties'),
                  selected: _selectedSpecialty == null,
                  onSelected: (selected) {
                    setState(() {
                      _selectedSpecialty = null;
                      _filterDoctors(_searchController.text);
                    });
                  },
                ),
                ...DoctorSpecialty.values.map((specialty) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: FilterChip(
                      label: Text(_formatSpecialtyName(specialty)),
                      selected: _selectedSpecialty == specialty,
                      onSelected: (selected) {
                        setState(() {
                          _selectedSpecialty = selected ? specialty : null;
                          _filterDoctors(_searchController.text);
                        });
                      },
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Doctors List
          Expanded(
            child: _isLoading
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
                              onPressed: _fetchDoctors,
                              child: const Text('Try Again'),
                            ),
                          ],
                        ),
                      )
                    : _filteredDoctors.isEmpty
                        ? const Center(
                            child:
                                Text('No doctors found matching your search.'),
                          )
                        : ListView.builder(
                            itemCount: _filteredDoctors.length,
                            padding: const EdgeInsets.all(16),
                            itemBuilder: (context, index) {
                              final doctor = _filteredDoctors[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: DoctorCard(
                                  doctor: doctor,
                                  clinic: widget.clinic,
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/create_appointment',
                                      arguments: {
                                        'doctor': doctor,
                                        'clinic': widget.clinic,
                                      },
                                    );
                                  },
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

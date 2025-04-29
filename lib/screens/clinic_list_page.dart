import 'package:flutter/material.dart';
import '../config/routes.dart';
import '../config/theme.dart';
import '../models/clinic.dart';

class ClinicListPage extends StatefulWidget {
  const ClinicListPage({Key? key}) : super(key: key);

  @override
  _ClinicListPageState createState() => _ClinicListPageState();
}

class _ClinicListPageState extends State<ClinicListPage> {
  bool _isLoading = true;
  List<Clinic> _clinics = [];
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadClinics();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadClinics() async {
    // Simuler un chargement depuis l'API
    await Future.delayed(const Duration(seconds: 1));

    // Données fictives pour l'exemple
    final mockClinics = [
      Clinic(
        id: '1',
        name: 'Clinique Médicale St-Jean',
        address: '15 Rue de la Santé, 75001 Paris',
        phoneNumber: '+33 1 23 45 67 89',
        imageUrl: 'https://example.com/clinic1.jpg',
        rating: 4.5,
        services: ['Consultation générale', 'Cardiologie', 'Pédiatrie'],
        schedule: {
          'lundi': '08:00-18:00',
          'mardi': '08:00-18:00',
          'mercredi': '08:00-18:00',
          'jeudi': '08:00-18:00',
          'vendredi': '08:00-17:00',
          'samedi': '09:00-12:00',
          'dimanche': 'Fermé',
        },
      ),
      Clinic(
        id: '2',
        name: 'Centre Médical du Parc',
        address: '42 Avenue des Champs, 75008 Paris',
        phoneNumber: '+33 1 98 76 54 32',
        imageUrl: 'https://example.com/clinic2.jpg',
        rating: 4.2,
        services: ['Consultation générale', 'Dermatologie', 'Gynécologie'],
        schedule: {
          'lundi': '09:00-19:00',
          'mardi': '09:00-19:00',
          'mercredi': '09:00-19:00',
          'jeudi': '09:00-19:00',
          'vendredi': '09:00-19:00',
          'samedi': '10:00-14:00',
          'dimanche': 'Fermé',
        },
      ),
      Clinic(
        id: '3',
        name: 'Polyclinique des Étoiles',
        address: '7 Rue de la République, 69001 Lyon',
        phoneNumber: '+33 4 56 78 90 12',
        imageUrl: 'https://example.com/clinic3.jpg',
        rating: 4.8,
        services: [
          'Consultation générale',
          'Orthopédie',
          'Neurologie',
          'Radiologie'
        ],
        schedule: {
          'lundi': '08:30-19:30',
          'mardi': '08:30-19:30',
          'mercredi': '08:30-19:30',
          'jeudi': '08:30-19:30',
          'vendredi': '08:30-19:30',
          'samedi': '09:00-16:00',
          'dimanche': '10:00-12:00',
        },
      ),
    ];

    setState(() {
      _clinics = mockClinics;
      _isLoading = false;
    });
  }

  List<Clinic> get _filteredClinics {
    if (_searchQuery.isEmpty) {
      return _clinics;
    }

    return _clinics.where((clinic) {
      final query = _searchQuery.toLowerCase();
      return clinic.name.toLowerCase().contains(query) ||
          clinic.address.toLowerCase().contains(query) ||
          clinic.services
              .any((service) => service.toLowerCase().contains(query));
    }).toList();
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _navigateToCreateAppointment(Clinic clinic) {
    NavigationHelper.navigateToCreateAppointment(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cliniques'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Implémenter le filtrage par services
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredClinics.isEmpty
                    ? _buildEmptyState()
                    : _buildClinicList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Rechercher une clinique...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
        onChanged: _onSearch,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off,
            size: 64,
            color: lightTextColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune clinique trouvée',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Essayez de modifier vos critères de recherche',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: lightTextColor,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildClinicList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredClinics.length,
      itemBuilder: (context, index) {
        final clinic = _filteredClinics[index];
        return _buildClinicCard(clinic);
      },
    );
  }

  Widget _buildClinicCard(Clinic clinic) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _navigateToCreateAppointment(clinic),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Container(
                height: 120,
                width: double.infinity,
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(
                    Icons.local_hospital,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          clinic.name,
                          style: Theme.of(context).textTheme.headlineSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            clinic.rating.toString(),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 16, color: lightTextColor),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          clinic.address,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: lightTextColor,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 16, color: lightTextColor),
                      const SizedBox(width: 4),
                      Text(
                        clinic.phoneNumber,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: lightTextColor,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: clinic.services
                        .take(3)
                        .map((service) => _buildServiceChip(service))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _navigateToCreateAppointment(clinic),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today, size: 16),
                        SizedBox(width: 8),
                        Text('Prendre rendez-vous'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceChip(String service) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        service,
        style: TextStyle(
          color: Colors.grey[800],
          fontSize: 12,
        ),
      ),
    );
  }
}

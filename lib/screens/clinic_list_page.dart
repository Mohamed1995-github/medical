import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/routes.dart';
import '../config/theme.dart';
import '../models/clinic.dart';
import '../services/clinic_service.dart';

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
  String? _errorMessage;

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
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Récupérer le service des cliniques depuis le contexte
      final clinicService = Provider.of<ClinicService>(context, listen: false);

      // Charger les cliniques depuis l'API
      final clinics = await clinicService.fetchClinics();

      setState(() {
        _clinics = clinics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage =
            "Erreur lors du chargement des cliniques: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  Future<void> _searchClinics(String query) async {
    if (query.isEmpty) {
      _loadClinics();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Récupérer le service des cliniques depuis le contexte
      final clinicService = Provider.of<ClinicService>(context, listen: false);

      // Rechercher les cliniques depuis l'API
      final clinics = await clinicService.searchClinics(query);

      setState(() {
        _clinics = clinics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage =
            "Erreur lors de la recherche des cliniques: ${e.toString()}";
        _isLoading = false;
      });
    }
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

    // Déclencher la recherche après un court délai pour éviter trop d'appels API
    Future.delayed(const Duration(milliseconds: 500), () {
      if (query == _searchQuery) {
        _searchClinics(query);
      }
    });
  }

  void _navigateToCreateAppointment(Clinic clinic) {
    NavigationHelper.navigateToCreateAppointment(context);
  }

  Future<void> _onRefresh() async {
    await _loadClinics();
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
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: Column(
          children: [
            _buildSearchBar(),
            if (_errorMessage != null) _buildErrorMessage(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredClinics.isEmpty
                      ? _buildEmptyState()
                      : _buildClinicList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade800),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red.shade800),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              setState(() {
                _errorMessage = null;
              });
            },
            color: Colors.red.shade800,
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
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _onSearch('');
                  },
                )
              : null,
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
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadClinics,
            icon: const Icon(Icons.refresh),
            label: const Text('Rafraîchir'),
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
              child: clinic.imageUrl != null
                  ? Image.network(
                      clinic.imageUrl!,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 120,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 48,
                        color: Colors.grey,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

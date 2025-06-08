
// lib/screens/home/home_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medicall_app/config/theme.dart';
import 'package:medicall_app/helper/shared_pref.dart';
import 'package:medicall_app/screens/home/provider/home_provider.dart';
import 'package:medicall_app/screens/Medical/provider/medical_provider.dart';
import 'package:medicall_app/Models/Medical/specialty_model.dart';
import 'package:medicall_app/screens/Medical/physisian.dart';
import 'package:medicall_app/screens/Medical/all_physisian.dart';
import 'package:medicall_app/Models/Authentication/login_response.dart';
// Pour UserDetails, assurez-vous que le chemin est correct.

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _patientIdController = TextEditingController();
  final _newPatientNameController = TextEditingController();

  String _userName = 'Médecin';
  String _userEmail = '';
  String _userPhone = '';

  @override
  void initState() {
    super.initState();
    checklogin();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserData();
  }

  Future<void> checklogin() async {
    final isLoggedIn = await SessionManager.getIsLoggedIn();
    if (!isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> _loadUserData() async {
    try {
      final userDetails = await SessionManager.getUserDetails();
      if (mounted) {
        setState(() {
          _userName = userDetails.name;
          _userEmail = userDetails.email;
          _userPhone = userDetails.phone;
        });
      }
    } catch (_) {
      // Si aucune donnée utilisateur n’est trouvée, on ne change rien ou on peut afficher un message
    }

    // Charger les spécialités médicales après que le contexte soit prêt
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MedicalProvider>(context, listen: false).fetchSpecialties();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _patientIdController.dispose();
    _newPatientNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: TabBarView(
        controller: _tabController,
        physics: const BouncingScrollPhysics(),
        children: [
          HomeTabContent(userName: _userName),
          const NotificationsTabContent(),
          ProfileTabContent(
            userName: _userName,
            userEmail: _userEmail,
            userPhone: _userPhone,
          ),
        ],
      ),
      floatingActionButton: _buildFloatingButton(),
      bottomNavigationBar: _buildBottomAppBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Accueil',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      backgroundColor: primaryColor,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, size: 28),
          onPressed: () {
            // TODO : ajouter la logique de recherche
          },
        ),

        // — Bouton Déconnexion dans l’AppBar
        IconButton(
          icon: const Icon(Icons.logout, size: 28),
          onPressed: () async {
            await SessionManager.setIsLoggedIn(false);
            Navigator.pushReplacementNamed(context, '/login');
          },
        ),

        // — Bouton Profil (pour basculer vers l’onglet Profil)
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: CircleAvatar(
            backgroundColor: Colors.white24,
            child: IconButton(
              icon: const Icon(Icons.person, color: Colors.white),
              onPressed: () {
                _tabController.animateTo(2);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingButton() {
    return FloatingActionButton(
      onPressed: () => Navigator.pushNamed(context, '/patient-choice'),
      backgroundColor: primaryColor,
      elevation: 4,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [primaryColor, primaryColor.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.4),
              blurRadius: 10,
              spreadRadius: 2,
            )
          ],
        ),
        child: const Icon(Icons.add, size: 32, color: Colors.white),
      ),
    );
  }

  Widget _buildBottomAppBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        child: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            indicatorColor: Colors.transparent,
            labelColor: primaryColor,
            unselectedLabelColor: Colors.grey,
            labelStyle:
                const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            tabs: [
              Tab(
                icon: _buildAnimatedIcon(
                  Icons.home_outlined,
                  Icons.home_filled,
                  0,
                ),
              ),
              Tab(
                icon: _buildAnimatedIcon(
                  Icons.notifications_outlined,
                  Icons.notifications,
                  1,
                ),
              ),
              Tab(
                icon: _buildAnimatedIcon(
                  Icons.person_outline,
                  Icons.person,
                  2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon(IconData outline, IconData filled, int index) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) => ScaleTransition(
        scale: animation,
        child: FadeTransition(opacity: animation, child: child),
      ),
      child: _tabController.index == index
          ? Icon(filled, key: ValueKey('filled$index'), size: 28)
          : Icon(outline, key: ValueKey('outline$index'), size: 26),
    );
  }
}

// =============================
// Onglet Accueil
// =============================
class HomeTabContent extends StatefulWidget {
  final String userName;
  const HomeTabContent({Key? key, required this.userName}) : super(key: key);

  @override
  State<HomeTabContent> createState() => _HomeTabContentState();
}

class _HomeTabContentState extends State<HomeTabContent> {
  @override
  void initState() {
    super.initState();
    // Charger les spécialités un peu après que le widget soit construit
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MedicalProvider>(context, listen: false).fetchSpecialties();
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = Provider.of<HomeProvider>(context);
    final medicalProvider = Provider.of<MedicalProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 24),
          _buildSearchCard(),
          const SizedBox(height: 32),
          _buildSectionTitle('Spécialités médicales'),
          const SizedBox(height: 16),
          _buildSpecialtiesList(medicalProvider),
          _buildSectionTitle('Mes médecins'),
          const SizedBox(height: 16),
          _buildPhysiciansList(medicalProvider),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Bonjour,', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(
          '${widget.userName}',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
        ),
      ],
    );
  }

  Widget _buildSearchCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Rechercher un médecin, une spécialité...',
                  border: InputBorder.none,
                  suffixIcon: Icon(Icons.search, color: primaryColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildSpecialtiesList(MedicalProvider provider) {
    if (provider.isLoadingSpecialties) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.error != null) {
      return Center(child: Text(provider.error!));
    }
    final specialties = provider.specialties?.data ?? [];

    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: specialties.length,
        itemBuilder: (context, index) {
          final specialty = specialties[index];
          return _buildSpecialtyCard(specialty);
        },
      ),
    );
  }

  Widget _buildSpecialtyCard(SpecialtyModel specialty) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PhysicianScreen(
              specialtyId: specialty.id ?? 0,
              specialtyName: specialty.name ?? 'Spécialité',
            ),
          ),
        );
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 16),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getSpecialtyIcon(specialty.name ?? ''),
                  size: 32,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  specialty.name ?? 'Spécialité',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getSpecialtyIcon(String specialtyName) {
    final lower = specialtyName.toLowerCase();
    if (lower.contains('cardio')) return Icons.favorite;
    if (lower.contains('dermato')) return Icons.face;
    if (lower.contains('neuro')) return Icons.psychology;
    if (lower.contains('ortho')) return Icons.accessible;
    if (lower.contains('pédiatrie')) return Icons.child_care;
    return Icons.medical_services;
  }

  Widget _buildPhysicianCard(dynamic physician) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: primaryColor.withOpacity(0.2),
          child: const Icon(Icons.person, color: primaryColor),
        ),
        title: Text(physician.name ?? 'Médecin'),
        subtitle: Text(physician.specialty ?? ''),
        trailing: Icon(Icons.chevron_right, color: primaryColor),
      ),
    );
  }

  // Inside _buildPhysiciansList (or below specialties for global access)
  Widget _buildPhysiciansList(MedicalProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AllPhysiciansScreen()),
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Voir tous les médecins',
              style: TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        provider.isLoadingPhysicians
            ? const Center(child: CircularProgressIndicator())
            : provider.physicians == null
                ? const Text('Aucun médecin à afficher')
                : SizedBox(
                    height: 200, // Adjust height as needed
                    child: PageView.builder(
                      itemCount: provider.physicians?.data?.length ?? 0,
                      controller: PageController(viewportFraction: 0.8),
                      itemBuilder: (context, index) {
                        final physician = provider.physicians!.data![index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: _buildPhysicianCard(physician),
                        );
                      },
                    ),
                  ),
      ],
    );
  }

  Widget _buildAppointmentsList() {
    // Exemple statique, vous pouvez remplacer par vos propres données
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: CircleAvatar(
            backgroundColor: primaryColor.withOpacity(0.2),
            child: const Icon(Icons.person, color: primaryColor),
          ),
          title: Text(
            'Patient ${index + 1}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text('Aujourd\'hui, ${10 + index}:00'),
          trailing: Icon(Icons.chevron_right, color: primaryColor),
          tileColor: index == 0 ? primaryColor.withOpacity(0.05) : null,
        ),
      ),
    );
  }
}

// =============================
// Onglet Notifications
// =============================
class NotificationsTabContent extends StatelessWidget {
  const NotificationsTabContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Aucune notification pour le moment',
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }
}

// =============================
// Onglet Profil
// =============================
class ProfileTabContent extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String userPhone;

  const ProfileTabContent({
    Key? key,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mon Profil',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          // — Nom complet
          Text('Nom complet', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            userName,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),

          // — Email
          Text('Email', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            userEmail.isNotEmpty ? userEmail : 'Non renseigné',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),

          // — Téléphone
          Text('Téléphone', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            userPhone.isNotEmpty ? userPhone : 'Non renseigné',
            style: Theme.of(context).textTheme.bodyLarge,
          ),

          const Spacer(),

          Center(
            child: ElevatedButton(
              onPressed: () async {
                await SessionManager.setIsLoggedIn(false);
                await SessionManager.saveBaseUrl(
                    'https://hms-pro.odoo.com/odoo/api');
                Navigator.pushReplacementNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor, // Remplace `primary:`
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Déconnexion',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
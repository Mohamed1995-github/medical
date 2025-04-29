import 'package:flutter/material.dart';
import '../config/routes.dart';
import '../config/theme.dart';
import '../models/user.dart';
import '../widgets/custom_button.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = true;
  late User _user;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    // Simuler un chargement depuis l'API
    await Future.delayed(const Duration(seconds: 1));

    // Données fictives pour l'exemple
    final mockUser = User(
      id: 'user123',
      username: 'Jean Dupont',
      phoneNumber: '+33 6 12 34 56 78',
      cni: 'AB123456',
      profileImage: null,
    );

    setState(() {
      _user = mockUser;
      _isLoading = false;
    });
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              NavigationHelper.navigateToLogin(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: errorColor,
            ),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 32),
                  _buildProfileInfo(),
                  const SizedBox(height: 32),
                  _buildActionButtons(),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Container(
          height: 120,
          width: 120,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: _user.profileImage != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(60),
                  child: Image.network(
                    _user.profileImage!,
                    fit: BoxFit.cover,
                  ),
                )
              : Icon(
                  Icons.person,
                  size: 60,
                  color: Colors.grey[600],
                ),
        ),
        const SizedBox(height: 16),
        Text(
          _user.username,
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 4),
        Text(
          _user.phoneNumber,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: lightTextColor,
              ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () {
            // Logique pour modifier la photo de profil
          },
          icon: const Icon(Icons.camera_alt),
          label: const Text('Modifier la photo'),
        ),
      ],
    );
  }

  Widget _buildProfileInfo() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations personnelles',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Nom d\'utilisateur', _user.username),
            const Divider(),
            _buildInfoRow('Numéro de téléphone', _user.phoneNumber),
            const Divider(),
            _buildInfoRow('Numéro CNI', _user.cni),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: lightTextColor,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomButton(
          text: 'Modifier le profil',
          onPressed: () {
            // Navigation vers la page de modification du profil
          },
          icon: Icons.edit,
        ),
        const SizedBox(height: 12),
        CustomButton(
          text: 'Changer le mot de passe',
          onPressed: () {
            // Navigation vers la page de changement de mot de passe
          },
          type: ButtonType.outline,
          icon: Icons.lock,
        ),
        const SizedBox(height: 12),
        CustomButton(
          text: 'Mes paiements',
          onPressed: () {
            // Navigation vers la page des paiements
          },
          type: ButtonType.outline,
          icon: Icons.payment,
        ),
        const SizedBox(height: 24),
        CustomButton(
          text: 'Se déconnecter',
          onPressed: _logout,
          type: ButtonType.text,
          icon: Icons.exit_to_app,
        ),
      ],
    );
  }
}

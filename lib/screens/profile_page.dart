import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
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
  int? _userId;
  int? _partnerId;
  String _name = '';
  String _email = '';
  String _phone = '';
  String _cni = '';
  String? _profileImageUrl;

  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getInt('user_id');
    _partnerId = prefs.getInt('partner_id');
    _name = prefs.getString('name') ?? '';
    _email = prefs.getString('email') ?? '';
    _phone = prefs.getString('phone') ?? '';
    _cni = prefs.getString('cni') ?? '';
    _profileImageUrl = prefs.getString('profileImage');

    setState(() => _isLoading = false);
  }

  Future<void> _pickImage() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 600,
        imageQuality: 80,
      );
      if (picked != null) {
        setState(() {
          _imageFile = picked;
        });
        // TODO: upload picked.path to server, then save new URL in prefs
      }
    } catch (e) {
      debugPrint('Erreur lors de la sélection de l\'image: \$e');
    }
  }

  void _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: errorColor,
            ),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      NavigationHelper.navigateToLogin(context);
    }
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
          child: ClipOval(
            child: _imageFile != null
                ? Image.file(File(_imageFile!.path), fit: BoxFit.cover)
                : (_profileImageUrl != null && _profileImageUrl!.isNotEmpty)
                    ? Image.network(_profileImageUrl!, fit: BoxFit.cover)
                    : Icon(Icons.person, size: 60, color: Colors.grey[600]),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _name,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 4),
        Text(
          _phone,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: lightTextColor),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.camera_alt),
          label: const Text('Modifier la photo'),
        ),
      ],
    );
  }

  Widget _buildProfileInfo() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations personnelles',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Nom d\'utilisateur', _name),
            const Divider(),
            _buildInfoRow('Numéro de téléphone', _phone),
            const Divider(),
            _buildInfoRow('Numéro CNI', _cni),
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
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
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
            text: 'Modifier le profil', onPressed: () {}, icon: Icons.edit),
        const SizedBox(height: 12),
        CustomButton(
            text: 'Changer le mot de passe',
            onPressed: () {},
            type: ButtonType.outline,
            icon: Icons.lock),
        const SizedBox(height: 12),
        CustomButton(
            text: 'Mes paiements',
            onPressed: () {},
            type: ButtonType.outline,
            icon: Icons.payment),
        const SizedBox(height: 24),
        CustomButton(
            text: 'Se déconnecter',
            onPressed: _logout,
            type: ButtonType.text,
            icon: Icons.exit_to_app),
      ],
    );
  }
}

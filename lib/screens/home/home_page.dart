import 'package:flutter/material.dart';
import 'package:medicall_app/config/theme.dart';
import 'package:medicall_app/helper/shared_pref.dart';
import 'package:medicall_app/screens/home/home_provider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _patientIdController = TextEditingController();
  final _newPatientNameController = TextEditingController();
  int _selectedIndex = 0; // 0: Home, 1: Notifications, 2: Profil

  /// Les routes pour chaque onglet
  static const List<String> _routeNames = [
    '/home',
    '/notifications',
    '/profile',
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final nni = await SessionManager.getGoveCode();
      Provider.of<HomeProvider>(context, listen: false).checkPatient(nni ?? '');
    });
  }

  @override
  void dispose() {
    _patientIdController.dispose();
    _newPatientNameController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
    Navigator.pushNamed(context, _routeNames[index]);
  }

  Widget _navIcon(IconData icon, int index) {
    final isSelected = _selectedIndex == index;
    return IconButton(
      onPressed: () => _onItemTapped(index),
      icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: primaryColor,
            width: 2,
          ),
        ),
        child: Icon(
          icon,
          size: 32,
          color: isSelected ? primaryColor : Colors.grey,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil'),
        backgroundColor: primaryColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // TODO: Contenu principal selon _selectedIndex
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/patient-choice'),
        tooltip: 'Créer un rendez-vous',
        backgroundColor: primaryColor,
        child: Icon(
          Icons.add,
          size: 32,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _navIcon(Icons.home, 0),
            const SizedBox(width: 24),
            _navIcon(Icons.notifications, 1),
            const SizedBox(width: 24),
            _navIcon(Icons.person, 2),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}

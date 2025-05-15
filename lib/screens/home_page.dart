import 'package:flutter/material.dart';
import '../config/routes.dart';
import '../config/theme.dart';
import '../models/appointment.dart';
import '../widgets/appointment_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _appointments = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    // Simuler un chargement depuis l'API
    await Future.delayed(const Duration(seconds: 1));

    // Données fictives pour l'exemple
    final mockAppointments = [
      {
        'appointment': Appointment(
          id: '1',
          userId: 'user123',
          clinicId: '1',
          date: DateTime.now().add(const Duration(days: 2)),
          time: '10:30',
          service: 'Consultation générale',
          status: AppointmentStatus.confirmed,
          isPaid: false,
          amount: 45.0,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        'clinicName': 'Clinique Médicale St-Jean'
      },
      {
        'appointment': Appointment(
          id: '2',
          userId: 'user123',
          clinicId: '2',
          date: DateTime.now().add(const Duration(days: 5)),
          time: '14:15',
          service: 'Dermatologie',
          status: AppointmentStatus.pending,
          isPaid: true,
          amount: 65.0,
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        ),
        'clinicName': 'Centre Médical du Parc'
      },
    ];

    setState(() {
      _appointments = mockAppointments;
      _isLoading = false;
    });
  }

  void _navigateToCreateAppointment() {
    // Passage par la liste des cliniques
    NavigationHelper.navigateToClinics(context);
  }

  void _makePayment(Appointment appointment) {
    NavigationHelper.navigateToPayment(context, arguments: appointment);
  }

  void _cancelAppointment(Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler le rendez-vous'),
        content:
            const Text('Êtes-vous sûr de vouloir annuler ce rendez-vous ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Non'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Rendez-vous annulé avec succès'),
                  backgroundColor: successColor,
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: errorColor,
            ),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Rendez-vous'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => NavigationHelper.navigateToProfile(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _appointments.isEmpty
              ? _buildEmptyState()
              : _buildAppointmentsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateAppointment,
        backgroundColor: primaryColor,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.calendar_today,
            size: 64,
            color: lightTextColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun rendez-vous',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Prenez votre premier rendez-vous',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: lightTextColor,
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _navigateToCreateAppointment,
            icon: const Icon(Icons.add),
            label: const Text('Prendre rendez-vous'),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _appointments.length,
      itemBuilder: (context, index) {
        final appointmentData = _appointments[index];
        final appointment = appointmentData['appointment'] as Appointment;
        final clinicName = appointmentData['clinicName'] as String;

        return AppointmentCard(
          appointment: appointment,
          clinicName: clinicName,
          onTap: () {
            // Naviguer vers les détails du rendez-vous
          },
          onPayment:
              appointment.isPaid ? null : () => _makePayment(appointment),
          onCancel: appointment.status == AppointmentStatus.cancelled
              ? null
              : () => _cancelAppointment(appointment),
        );
      },
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });

        switch (index) {
          case 0:
            // Page d'accueil (actuelle)
            break;
          case 1:
            NavigationHelper.navigateToHistory(context);
            break;
          case 2:
            // Navigation vers la liste des cliniques
            NavigationHelper.navigateToClinics(context);
            break;
          case 3:
            NavigationHelper.navigateToProfile(context);
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Accueil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: 'Historique',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.local_hospital),
          label: 'Cliniques',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
      selectedItemColor: primaryColor,
      unselectedItemColor: lightTextColor,
    );
  }
}

import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/appointment.dart';
import '../widgets/appointment_card.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  List<Map<String, dynamic>> _pastAppointments = [];
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPastAppointments();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _loadPastAppointments() async {
    // Simuler un chargement depuis l'API
    await Future.delayed(const Duration(seconds: 1));

    // Données fictives pour l'exemple
    final mockPastAppointments = [
      {
        'appointment': Appointment(
          id: '3',
          userId: 'user123',
          clinicId: '1',
          date: DateTime.now().subtract(const Duration(days: 10)),
          time: '09:45',
          service: 'Consultation générale',
          status: AppointmentStatus.completed,
          isPaid: true,
          amount: 45.0,
          createdAt: DateTime.now().subtract(const Duration(days: 15)),
        ),
        'clinicName': 'Clinique Médicale St-Jean'
      },
      {
        'appointment': Appointment(
          id: '4',
          userId: 'user123',
          clinicId: '3',
          date: DateTime.now().subtract(const Duration(days: 25)),
          time: '11:30',
          service: 'Radiologie',
          status: AppointmentStatus.completed,
          isPaid: true,
          amount: 120.0,
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
        ),
        'clinicName': 'Polyclinique des Étoiles'
      },
      {
        'appointment': Appointment(
          id: '5',
          userId: 'user123',
          clinicId: '2',
          date: DateTime.now().subtract(const Duration(days: 5)),
          time: '16:00',
          service: 'Dermatologie',
          status: AppointmentStatus.cancelled,
          isPaid: false,
          amount: 65.0,
          createdAt: DateTime.now().subtract(const Duration(days: 7)),
        ),
        'clinicName': 'Centre Médical du Parc'
      },
    ];

    setState(() {
      _pastAppointments = mockPastAppointments;
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get _completedAppointments {
    return _pastAppointments
        .where((data) =>
            (data['appointment'] as Appointment).status ==
            AppointmentStatus.completed)
        .toList();
  }

  List<Map<String, dynamic>> get _cancelledAppointments {
    return _pastAppointments
        .where((data) =>
            (data['appointment'] as Appointment).status ==
            AppointmentStatus.cancelled)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Terminés'),
            Tab(text: 'Annulés'),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildAppointmentsList(_completedAppointments),
                _buildAppointmentsList(_cancelledAppointments),
              ],
            ),
    );
  }

  Widget _buildAppointmentsList(List<Map<String, dynamic>> appointments) {
    if (appointments.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointmentData = appointments[index];
        final appointment = appointmentData['appointment'] as Appointment;
        final clinicName = appointmentData['clinicName'] as String;

        return AppointmentCard(
          appointment: appointment,
          clinicName: clinicName,
          onTap: () {
            // Naviguer vers les détails du rendez-vous
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    String message = _tabController?.index == 0
        ? 'Aucun rendez-vous terminé'
        : 'Aucun rendez-vous annulé';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.event_busy,
            size: 64,
            color: lightTextColor,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Votre historique apparaîtra ici',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: lightTextColor,
                ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/appointment.dart';
import '../utils/auth_service.dart';
import '../widgets/appointment_card.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String? _errorMessage;
  List<Appointment> _appointments = [];

  final _authService = AuthService();
  final _appointmentService = AppointmentService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchAppointments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchAppointments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_authService.currentUser == null) {
        throw Exception('You must be logged in to view appointments');
      }

      final appointments = await _appointmentService.getPatientAppointments(
        _authService.currentUser!.id,
      );

      setState(() {
        _appointments = appointments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Appointment> get _upcomingAppointments {
    final now = DateTime.now();
    return _appointments
        .where((appointment) =>
            appointment.scheduledTime.isAfter(now) &&
            appointment.status != AppointmentStatus.cancelled)
        .toList()
      ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
  }

  List<Appointment> get _pastAppointments {
    final now = DateTime.now();
    return _appointments
        .where((appointment) =>
            appointment.scheduledTime.isBefore(now) &&
            appointment.status != AppointmentStatus.cancelled)
        .toList()
      ..sort((a, b) =>
          b.scheduledTime.compareTo(a.scheduledTime)); // Descending order
  }

  List<Appointment> get _cancelledAppointments {
    return _appointments
        .where(
            (appointment) => appointment.status == AppointmentStatus.cancelled)
        .toList()
      ..sort((a, b) =>
          b.scheduledTime.compareTo(a.scheduledTime)); // Descending order
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical History'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
            Tab(text: 'Cancelled'),
          ],
        ),
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
                        onPressed: _fetchAppointments,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchAppointments,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Upcoming Appointments Tab
                      _buildAppointmentList(
                        _upcomingAppointments,
                        'No upcoming appointments',
                        'Your upcoming appointments will appear here.',
                      ),

                      // Past Appointments Tab
                      _buildAppointmentList(
                        _pastAppointments,
                        'No past appointments',
                        'Your past appointment history will appear here.',
                      ),

                      // Cancelled Appointments Tab
                      _buildAppointmentList(
                        _cancelledAppointments,
                        'No cancelled appointments',
                        'Your cancelled appointments will appear here.',
                      ),
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/clinics');
        },
        child: const Icon(Icons.add),
        tooltip: 'Book New Appointment',
      ),
    );
  }

  Widget _buildAppointmentList(
    List<Appointment> appointments,
    String emptyTitle,
    String emptySubtitle,
  ) {
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.event_busy, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              emptyTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              emptySubtitle,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return AppointmentCard(
          appointment: appointment,
          onTap: () {
            // Navigate to appointment details
            // This would be implemented in a future feature
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Appointment details coming soon!'),
              ),
            );
          },
        );
      },
    );
  }
}

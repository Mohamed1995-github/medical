import 'package:flutter/material.dart';
import '../utils/auth_service.dart';
import '../models/appointment.dart';
import '../widgets/appointment_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _authService = AuthService();
  final _appointmentService = AppointmentService();
  bool _isLoading = true;
  String? _errorMessage;
  List<Appointment> _upcomingAppointments = [];

  @override
  void initState() {
    super.initState();
    _fetchUpcomingAppointments();
  }

  Future<void> _fetchUpcomingAppointments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_authService.currentUser == null) {
        throw Exception('You must be logged in to view appointments');
      }

      final allAppointments = await _appointmentService.getPatientAppointments(
        _authService.currentUser!.id,
      );

      // Filter for upcoming appointments
      final now = DateTime.now();
      final upcoming = allAppointments
          .where((a) =>
              a.scheduledTime.isAfter(now) &&
              a.status != AppointmentStatus.cancelled)
          .toList()
        ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));

      setState(() {
        _upcomingAppointments = upcoming;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _fetchUpcomingAppointments,
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 180,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text('MediCall'),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.blue.shade700, Colors.blue.shade500],
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.person),
                  onPressed: () {
                    Navigator.pushNamed(context, '/profile');
                  },
                  tooltip: 'Profile',
                ),
              ],
            ),

            // User greeting
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${user?.name ?? 'User'}!',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'How can we help you today?',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Quick Actions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildQuickActionButton(
                          context,
                          Icons.calendar_month,
                          'Book',
                          () => Navigator.pushNamed(context, '/clinics'),
                        ),
                        _buildQuickActionButton(
                          context,
                          Icons.history,
                          'History',
                          () => Navigator.pushNamed(context, '/history'),
                        ),
                        _buildQuickActionButton(
                          context,
                          Icons.emergency,
                          'Emergency',
                          () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Emergency services coming soon!'),
                              ),
                            );
                          },
                        ),
                        _buildQuickActionButton(
                          context,
                          Icons.chat,
                          'Chat',
                          () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Chat with doctors coming soon!'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Upcoming Appointments
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Upcoming Appointments',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/history');
                          },
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Appointments list or loading/error state
            _isLoading
                ? const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                : _errorMessage != null
                    ? SliverFillRemaining(
                        child: Center(
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
                                onPressed: _fetchUpcomingAppointments,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _upcomingAppointments.isEmpty
                        ? SliverToBoxAdapter(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today_outlined,
                                      size: 64,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'No upcoming appointments',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Schedule your next appointment with our doctors',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 24),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.pushNamed(
                                            context, '/clinics');
                                      },
                                      icon: const Icon(Icons.add),
                                      label: const Text('Book Now'),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                if (index < _upcomingAppointments.length) {
                                  final appointment =
                                      _upcomingAppointments[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 4.0,
                                    ),
                                    child: AppointmentCard(
                                      appointment: appointment,
                                      onTap: () {
                                        // Navigate to appointment details
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Appointment details coming soon!'),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                } else {
                                  return null;
                                }
                              },
                              childCount: _upcomingAppointments.length,
                            ),
                          ),

            // Health Tips Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Health Tips',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      clipBehavior: Clip.antiAlias,
                      elevation: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 120,
                            color: Colors.blue.shade100,
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.health_and_safety,
                              size: 64,
                              color: Colors.blue,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Stay Hydrated',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Drink at least 8 glasses of water daily to stay hydrated and maintain health.',
                                  style: TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 16),
                                TextButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Health tips section coming soon!'),
                                      ),
                                    );
                                  },
                                  child: const Text('Read More'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Extra space at the bottom
            const SliverToBoxAdapter(
              child: SizedBox(height: 24),
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

  Widget _buildQuickActionButton(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onPressed,
  ) {
    return Column(
      children: [
        InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: Colors.blue,
              size: 32,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }
}

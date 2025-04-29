import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/routes.dart';
import '../config/theme.dart';
import '../models/clinic.dart';
import '../widgets/custom_button.dart';

class CreateAppointmentPage extends StatefulWidget {
  const CreateAppointmentPage({Key? key}) : super(key: key);

  @override
  _CreateAppointmentPageState createState() => _CreateAppointmentPageState();
}

class _CreateAppointmentPageState extends State<CreateAppointmentPage> {
  final _formKey = GlobalKey<FormState>();

  late Clinic _selectedClinic;
  String? _selectedService;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedTime;
  bool _isLoading = true;
  bool _isSubmitting = false;

  List<String> _availableTimes = [];

  @override
  void initState() {
    super.initState();
    _loadClinicData();
  }

  Future<void> _loadClinicData() async {
    // Simuler un chargement depuis l'API
    await Future.delayed(const Duration(seconds: 1));

    // Données fictives pour l'exemple
    final mockClinic = Clinic(
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
    );

    setState(() {
      _selectedClinic = mockClinic;
      _isLoading = false;
      _updateAvailableTimes();
    });
  }

  void _updateAvailableTimes() {
    // Simuler des horaires disponibles en fonction du jour sélectionné
    final day = DateFormat('EEEE', 'fr_FR').format(_selectedDate).toLowerCase();

    if (_selectedClinic.schedule[day] == 'Fermé') {
      _availableTimes = [];
      _selectedTime = null;
      return;
    }

    final schedule = _selectedClinic.schedule[day] as String;
    final times = schedule.split('-');
    final startTime = times[0].split(':').map(int.parse).toList();
    final endTime = times[1].split(':').map(int.parse).toList();

    final startHour = startTime[0];
    final endHour = endTime[0];

    final availableTimes = <String>[];

    for (int hour = startHour; hour < endHour; hour++) {
      availableTimes.add('$hour:00');
      availableTimes.add('$hour:30');
    }

    // Simuler des horaires déjà réservés
    final bookedTimes = [
      '10:00',
      '11:30',
      '14:00',
    ];

    setState(() {
      _availableTimes =
          availableTimes.where((time) => !bookedTimes.contains(time)).toList();
      _selectedTime = _availableTimes.isNotEmpty ? _availableTimes[0] : null;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              onSurface: textColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _updateAvailableTimes();
      });
    }
  }

  void _createAppointment() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedService == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez sélectionner un service'),
            backgroundColor: errorColor,
          ),
        );
        return;
      }

      if (_selectedTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez sélectionner un horaire disponible'),
            backgroundColor: errorColor,
          ),
        );
        return;
      }

      setState(() {
        _isSubmitting = true;
      });

      // Simuler un appel API
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isSubmitting = false;
      });

      // Naviguer vers la page de paiement ou vers l'accueil
      NavigationHelper.navigateToPayment(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prendre rendez-vous'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildClinicInfo(),
                    const SizedBox(height: 24),
                    _buildServiceSelector(),
                    const SizedBox(height: 24),
                    _buildDateSelector(),
                    const SizedBox(height: 24),
                    _buildTimeSelector(),
                    const SizedBox(height: 32),
                    CustomButton(
                      text: 'Confirmer le rendez-vous',
                      onPressed: _createAppointment,
                      isLoading: _isSubmitting,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildClinicInfo() {
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
              'Clinique sélectionnée',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.local_hospital,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedClinic.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _selectedClinic.address,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: lightTextColor,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Service',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedService,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            hintText: 'Sélectionnez un service',
          ),
          items: _selectedClinic.services.map((service) {
            return DropdownMenuItem<String>(
              value: service,
              child: Text(service),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedService = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez sélectionner un service';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: () => _selectDate(context),
          borderRadius: BorderRadius.circular(8),
          child: InputDecorator(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(_selectedDate),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const Icon(Icons.calendar_today, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Horaire',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        _availableTimes.isEmpty
            ? Text(
                'Aucun horaire disponible pour cette date',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: errorColor),
              )
            : DropdownButtonFormField<String>(
                value: _selectedTime,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'Sélectionnez un horaire',
                ),
                items: _availableTimes.map((time) {
                  return DropdownMenuItem<String>(
                    value: time,
                    child: Text(time),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTime = value;
                  });
                },
                validator: (value) {
                  if (_availableTimes.isNotEmpty &&
                      (value == null || value.isEmpty)) {
                    return 'Veuillez sélectionner un horaire';
                  }
                  return null;
                },
              ),
      ],
    );
  }
}

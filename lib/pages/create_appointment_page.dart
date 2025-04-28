import 'package:flutter/material.dart';
import '../models/clinic.dart';
import '../models/doctor.dart';
import '../models/appointment.dart';
import '../utils/auth_service.dart';
import '../widgets/custom_button.dart';

class CreateAppointmentPage extends StatefulWidget {
  final Clinic clinic;
  final Doctor? initialDoctor;

  const CreateAppointmentPage({
    super.key,
    required this.clinic,
    this.initialDoctor,
  });

  @override
  State<CreateAppointmentPage> createState() => _CreateAppointmentPageState();
}

class _CreateAppointmentPageState extends State<CreateAppointmentPage> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  late DateTime _selectedDate;
  TimeOfDay? _selectedTime;
  Doctor? _selectedDoctor;
  bool _isLoading = false;
  bool _loadingDoctors = true;
  String? _errorMessage;
  List<Doctor> _availableDoctors = [];

  final _authService = AuthService();
  final _appointmentService = AppointmentService();

  @override
  void initState() {
    super.initState();
    _selectedDate = _getNextAvailableDate();
    _selectedDoctor = widget.initialDoctor;
    _fetchDoctors();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  DateTime _getNextAvailableDate() {
    // Start with tomorrow
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
  }

  Future<void> _fetchDoctors() async {
    // This would be replaced with a real API call
    await Future.delayed(const Duration(seconds: 1));

    // Simulated doctor data
    final doctors = [
      Doctor(
        id: '1',
        name: 'Dr. Sarah Johnson',
        specialty: DoctorSpecialty.generalPractice,
        email: 'sarah.johnson@example.com',
        phoneNumber: '+123456789',
        qualifications: 'MD, General Medicine',
        bio: 'Experienced general practitioner with 10 years of experience.',
        isVerified: true,
        associatedClinics: [widget.clinic],
        availabilitySchedule: {
          'monday': {'start': '09:00', 'end': '17:00'},
          'tuesday': {'start': '09:00', 'end': '17:00'},
          'wednesday': {'start': '09:00', 'end': '17:00'},
          'thursday': {'start': '09:00', 'end': '17:00'},
          'friday': {'start': '09:00', 'end': '17:00'},
        },
      ),
      Doctor(
        id: '2',
        name: 'Dr. Michael Chen',
        specialty: DoctorSpecialty.cardiology,
        email: 'michael.chen@example.com',
        phoneNumber: '+234567890',
        qualifications: 'MD, Cardiology',
        bio: 'Cardiology specialist with focus on preventive care.',
        isVerified: true,
        associatedClinics: [widget.clinic],
        availabilitySchedule: {
          'monday': {'start': '10:00', 'end': '18:00'},
          'tuesday': {'start': '10:00', 'end': '18:00'},
          'wednesday': {'start': '10:00', 'end': '18:00'},
          'thursday': {'start': '10:00', 'end': '18:00'},
          'friday': {'start': '10:00', 'end': '16:00'},
        },
      ),
      Doctor(
        id: '3',
        name: 'Dr. Emily Rodriguez',
        specialty: DoctorSpecialty.pediatrics,
        email: 'emily.rodriguez@example.com',
        phoneNumber: '+345678901',
        qualifications: 'MD, Pediatrics',
        bio: 'Specializes in pediatric care with 8 years of experience.',
        isVerified: true,
        associatedClinics: [widget.clinic],
        availabilitySchedule: {
          'monday': {'start': '09:00', 'end': '17:00'},
          'tuesday': {'start': '09:00', 'end': '17:00'},
          'wednesday': {'start': '09:00', 'end': '17:00'},
          'thursday': {'start': '09:00', 'end': '17:00'},
          'friday': {'start': '09:00', 'end': '15:00'},
        },
      ),
    ];

    // Filter to only include doctors that work at this clinic
    final clinicDoctors = doctors.where((doctor) {
      return doctor.associatedClinics
          .any((clinic) => clinic.id == widget.clinic.id);
    }).toList();

    if (mounted) {
      setState(() {
        _availableDoctors = clinicDoctors;
        _loadingDoctors = false;

        // If an initial doctor wasn't provided, select the first available one
        if (_selectedDoctor == null && clinicDoctors.isNotEmpty) {
          _selectedDoctor = clinicDoctors.first;
        }
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _selectedTime = null; // Reset time when date changes
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    // Default time options based on clinic hours
    final TimeOfDay initialTime = const TimeOfDay(hour: 9, minute: 0);

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  Future<void> _createAppointment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDoctor == null) {
      setState(() {
        _errorMessage = 'Please select a doctor';
      });
      return;
    }

    if (_selectedTime == null) {
      setState(() {
        _errorMessage = 'Please select a time';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Create a datetime that combines the selected date and time
      final scheduledTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final appointment = await _appointmentService.createAppointment(
        patientId: _authService.currentUser!.id,
        doctor: _selectedDoctor!,
        clinic: widget.clinic,
        scheduledTime: scheduledTime,
        notes: _notesController.text,
      );

      if (mounted) {
        // Show success message and navigate back
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment created successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to appointment confirmation/details page
        Navigator.pop(context, appointment);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  String _formatDoctorSpecialty(DoctorSpecialty specialty) {
    return specialty
        .toString()
        .split('.')
        .last
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(0)}')
        .trim()
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
      ),
      body: _loadingDoctors
          ? const Center(child: CircularProgressIndicator())
          : _availableDoctors.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.medical_services_outlined,
                            size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          'No doctors available at this clinic',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Please try another clinic or check back later',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Go Back'),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Clinic Information
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Clinic Information',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  widget.clinic.name,
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.clinic.address,
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.grey),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Phone: ${widget.clinic.phoneNumber}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Doctor Selection
                        const Text(
                          'Select Doctor',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<Doctor>(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                          ),
                          value: _selectedDoctor,
                          items: _availableDoctors.map((doctor) {
                            return DropdownMenuItem<Doctor>(
                              value: doctor,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(doctor.name),
                                  Text(
                                    _formatDoctorSpecialty(doctor.specialty),
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (Doctor? newValue) {
                            setState(() {
                              _selectedDoctor = newValue;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a doctor';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Date Selection
                        const Text(
                          'Select Date',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () => _selectDate(context),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            child: Text(
                              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Time Selection
                        const Text(
                          'Select Time',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () => _selectTime(context),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              suffixIcon: Icon(Icons.access_time),
                            ),
                            child: Text(
                              _selectedTime != null
                                  ? '${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
                                  : 'Select a time',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Notes
                        const Text(
                          'Notes (Optional)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _notesController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText:
                                'Add any additional information for the doctor',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Error Message
                        if (_errorMessage != null)
                          Container(
                            padding: const EdgeInsets.all(8),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline,
                                    color: Colors.red),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style:
                                        TextStyle(color: Colors.red.shade800),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Submit Button
                        CustomButton(
                          text: 'Book Appointment',
                          onPressed: _createAppointment,
                          isLoading: _isLoading,
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}

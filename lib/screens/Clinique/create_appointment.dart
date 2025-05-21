// lib/presentation/screens/add_appointment_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get_it/get_it.dart';
import '../../Models/Medical/specialty_model.dart';
import '../../Models/Medical/physician_model.dart';
import '../../Models/Appointment/create_appointment_response.dart';
import '../../Models/Patient/check_patient_response.dart';
import '../../Models/Patient/create_patient_response.dart';
import '../../NetworkManager/odoo_api_client.dart';

class AddAppointmentScreen extends StatefulWidget {
  static const routeName = '/create-appointment';
  const AddAppointmentScreen({Key? key}) : super(key: key);

  @override
  _AddAppointmentScreenState createState() => _AddAppointmentScreenState();
}

class _AddAppointmentScreenState extends State<AddAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _api = GetIt.instance<OdooApiClient>();

  // Data lists
  List<SpecialtyModel> _specialties = [];
  List<PhysicianModel> _physicians = [];

  // Selected values
  SpecialtyModel? _selectedSpecialty;
  PhysicianModel? _selectedPhysician;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  // Patient fields
  final _patientIdController = TextEditingController();
  bool _isCheckingPatient = false;
  bool _patientExists = false;
  bool _showNewPatientForm = false;
  final _newPatientNameController = TextEditingController();

  // Loading
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSpecialties();
  }

  Future<void> _loadSpecialties() async {
    try {
      final resp = await _api.getSpecialties();
      setState(() => _specialties = resp.data?.cast<SpecialtyModel>() ?? []);
    } catch (_) {
      _showSnack('Erreur chargement spécialités');
    }
  }

  Future<void> _loadPhysicians(int specialtyId) async {
    try {
      final resp =
          await _api.getPhysiciansBySpecialty({'specialty_id': specialtyId});
      setState(() => _physicians = resp.data?.cast<PhysicianModel>() ?? []);
    } catch (_) {
      _showSnack('Erreur chargement médecins');
    }
  }

  Future<void> _checkPatient() async {
    if (_patientIdController.text.isEmpty) return;
    setState(() {
      _isCheckingPatient = true;
      _patientExists = false;
      _showNewPatientForm = false;
    });
    try {
      final id = int.tryParse(_patientIdController.text) ?? 0;
      final CheckPatientResponse resp =
          await _api.checkPatientExists({'patient_id': id});
      if (resp.exists == true) {
        setState(() {
          _patientExists = true;
        });
        _showSnack('Patient trouvé');
      } else {
        setState(() {
          _showNewPatientForm = true;
        });
        _showSnack('Patient non trouvé. Veuillez créer un patient');
      }
    } catch (_) {
      _showSnack('Erreur vérification patient');
    } finally {
      setState(() {
        _isCheckingPatient = false;
      });
    }
  }

  Future<void> _createPatient() async {
    final name = _newPatientNameController.text;
    if (name.isEmpty) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final CreatePatientResponse resp =
          await _api.createPatient({'name': name});
      if (resp.success == true && resp.patientId != null) {
        _patientIdController.text = resp.patientId.toString();
        setState(() {
          _patientExists = true;
          _showNewPatientForm = false;
        });
        _showSnack('Patient créé (ID: ${resp.patientId})');
      } else {
        _showSnack('Erreur création patient: ${resp.message}');
      }
    } catch (_) {
      _showSnack('Erreur lors création patient');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) setState(() => _selectedTime = time);
  }

  Future<void> _createAppointment() async {
    if (!_formKey.currentState!.validate() || !_patientExists) return;
    if (_selectedSpecialty == null ||
        _selectedPhysician == null ||
        _selectedDate == null ||
        _selectedTime == null) {
      _showSnack('Tous les champs requis');
      return;
    }
    setState(() {
      _isLoading = true;
    });
    final dateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );
    final body = {
      'specialty_id': _selectedSpecialty!.id ?? 0,
      'physician_id': _selectedPhysician!.id ?? 0,
      'patient_id': int.tryParse(_patientIdController.text) ?? 0,
      'datetime': DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(dateTime),
    };
    try {
      final CreateAppointmentResponse resp = await _api.createAppointment(body);
      if (resp.success == true && resp.appointmentId != null) {
        _showSnack('RDV créé (ID: ${resp.appointmentId})');
        Navigator.pop(context);
      } else {
        _showSnack('Erreur: ${resp.message ?? 'inconnue'}');
      }
    } catch (_) {
      _showSnack('Erreur création rendez-vous');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouveau RDV')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Patient ID + check
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _patientIdController,
                            decoration:
                                const InputDecoration(labelText: 'ID Patient'),
                            keyboardType: TextInputType.number,
                            validator: (v) => v == null || v.isEmpty
                                ? 'Entrez ID patient'
                                : null,
                            enabled: !_patientExists,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _isCheckingPatient
                            ? const CircularProgressIndicator()
                            : IconButton(
                                icon: const Icon(Icons.check),
                                onPressed: _checkPatient),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Nouvelle création patient
                    if (_showNewPatientForm) ...[
                      TextFormField(
                        controller: _newPatientNameController,
                        decoration:
                            const InputDecoration(labelText: 'Nom patient'),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Entrez nom' : null,
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                          onPressed: _createPatient,
                          child: const Text('Créer patient')),
                      const SizedBox(height: 16),
                    ],
                    // Spécialité
                    DropdownButtonFormField<SpecialtyModel>(
                      decoration:
                          const InputDecoration(labelText: 'Spécialité'),
                      items: _specialties
                          .map((s) => DropdownMenuItem(
                              value: s, child: Text(s.name ?? '')))
                          .toList(),
                      onChanged: (s) {
                        setState(() {
                          _selectedSpecialty = s;
                          _physicians = [];
                          _selectedPhysician = null;
                        });
                        if (s?.id != null) _loadPhysicians(s!.id!);
                      },
                      validator: (v) => v == null ? 'Choisir spécialité' : null,
                    ),
                    const SizedBox(height: 16),
                    // Médecin
                    DropdownButtonFormField<PhysicianModel>(
                      decoration: const InputDecoration(labelText: 'Médecin'),
                      items: _physicians
                          .map((p) => DropdownMenuItem(
                              value: p, child: Text(p.name ?? '')))
                          .toList(),
                      onChanged: (p) => setState(() => _selectedPhysician = p),
                      validator: (v) => v == null ? 'Choisir médecin' : null,
                    ),
                    const SizedBox(height: 16),
                    // Date
                    ListTile(
                        title: Text(_selectedDate == null
                            ? 'Sélectionner date'
                            : DateFormat('dd/MM/yyyy').format(_selectedDate!)),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: _pickDate),
                    const SizedBox(height: 8),
                    // Heure
                    ListTile(
                        title: Text(_selectedTime == null
                            ? 'Sélectionner horaire'
                            : _selectedTime!.format(context)),
                        trailing: const Icon(Icons.access_time),
                        onTap: _pickTime),
                    const SizedBox(height: 24),
                    ElevatedButton(
                        onPressed: _createAppointment,
                        child: const Text('Créer RDV')),
                  ],
                ),
              ),
            ),
    );
  }
}

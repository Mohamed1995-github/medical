// lib/screens/create_appointment_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/clinic.dart';
import '../models/specialty.dart';
import '../models/physician.dart';
import '../services/odoo_service.dart';

class CreateAppointmentPage extends StatefulWidget {
  final Clinic clinic;
  final String govCode;

  const CreateAppointmentPage({
    Key? key,
    required this.clinic,
    required this.govCode,
  }) : super(key: key);

  @override
  _CreateAppointmentPageState createState() => _CreateAppointmentPageState();
}

class _CreateAppointmentPageState extends State<CreateAppointmentPage> {
  final _formKey = GlobalKey<FormState>();
  late final OdooService _odoo;
  late int _patientId;
  bool _patientExists = false;

  final _nameController = TextEditingController();
  String? _selectedGender;

  List<Specialty> _specialties = [];
  Specialty? _selectedSpecialty;

  List<Physician> _physicians = [];
  Physician? _selectedPhysician;

  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _odoo = context.read<OdooService>();
    _patientId = 0;
    _checkPatientExists();
    _loadSpecialties();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _checkPatientExists() async {
    debugPrint('🔍 checkPatientExists pour ${widget.govCode}');
    try {
      final result = await _odoo.checkPatientExists(widget.govCode);
      setState(() {
        _patientExists = result['exists'] as bool;
        if (_patientExists) {
          _patientId = result['id'] as int;
        }
      });
    } catch (e) {
      debugPrint('Erreur checkPatientExists: $e');
      setState(() => _patientExists = false);
    }
  }

  Future<void> _loadSpecialties() async {
    try {
      final specs = await _odoo.getSpecialties();
      setState(() => _specialties = specs);
    } catch (e) {
      setState(() => _errorMessage = 'Erreur chargement spécialités');
    }
  }

  void _onSpecialtyChanged(Specialty? spec) {
    setState(() {
      _selectedSpecialty = spec;
      _physicians = [];
      _selectedPhysician = null;
    });
    if (spec != null) {
      _odoo
          .getPhysiciansBySpecialty(spec.id)
          .then((docs) => setState(() => _physicians = docs))
          .catchError((_) =>
              setState(() => _errorMessage = 'Erreur chargement praticiens'));
    }
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      if (!_patientExists) {
        debugPrint('➕ createPatient pour ${widget.govCode}');
        _patientId = await _odoo.createPatient(
          name: _nameController.text,
          gender: _selectedGender!,
          govCode: widget.govCode,
        );
      }

      debugPrint('🚀 createAppointment patientId=$_patientId');
      final appointmentId = await _odoo.createAppointment(
        patientId: _patientId,
        physicianId: _selectedPhysician!.id,
        productId: 42,
      );

      Navigator.pushNamed(
        context,
        '/payment',
        arguments: {'appointmentId': appointmentId},
      );
    } catch (e) {
      setState(() => _errorMessage = 'Erreur : $e');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prendre un rendez-vous')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (_errorMessage != null) ...[
                Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 12),
              ],
              if (!_patientExists) ...[
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nom complet'),
                  validator: (v) => !_patientExists && (v == null || v.isEmpty)
                      ? 'Obligatoire'
                      : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Genre'),
                  items: const [
                    DropdownMenuItem(value: 'M', child: Text('Homme')),
                    DropdownMenuItem(value: 'F', child: Text('Femme')),
                  ],
                  value: _selectedGender,
                  onChanged: (g) => setState(() => _selectedGender = g),
                  validator: (v) =>
                      !_patientExists && v == null ? 'Obligatoire' : null,
                ),
                const SizedBox(height: 24),
              ],
              DropdownButtonFormField<Specialty>(
                decoration: const InputDecoration(labelText: 'Spécialité'),
                items: _specialties
                    .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
                    .toList(),
                value: _selectedSpecialty,
                onChanged: _onSpecialtyChanged,
                validator: (v) => v == null ? 'Obligatoire' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Physician>(
                decoration: const InputDecoration(labelText: 'Praticien'),
                items: _physicians
                    .map((p) => DropdownMenuItem(value: p, child: Text(p.name)))
                    .toList(),
                value: _selectedPhysician,
                onChanged: (p) => setState(() => _selectedPhysician = p),
                validator: (v) => v == null ? 'Obligatoire' : null,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _onSubmit,
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Confirmer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

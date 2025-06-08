// // lib/screens/Appointment/create_appointment_screen.dart
// import 'package:flutter/material.dart';
// import 'package:medicall_app/screens/Appointment/appointemt_provider.dart';
// import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';
// import '../../Models/Medical/specialty_model.dart';
// import '../../Models/Medical/physician_model.dart';
// // import '../../Models/Patient/check_patient_response.dart';
// // import '../../Models/Patient/create_patient_response.dart';
// import '../../NetworkManager/odoo_api_client.dart';
// import 'package:get_it/get_it.dart';

// class CreateAppointmentScreen extends StatefulWidget {
//   const CreateAppointmentScreen({Key? key}) : super(key: key);

//   @override
//   _CreateAppointmentScreenState createState() =>
//       _CreateAppointmentScreenState();
// }

// class _CreateAppointmentScreenState extends State<CreateAppointmentScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _api = GetIt.instance<OdooApiClient>();

//   // Controllers
//   final _patientIdController = TextEditingController();
//   final _newPatientNameController = TextEditingController();
//   final _notesController = TextEditingController();

//   // Data lists
//   List<SpecialtyModel> _specialties = [];
//   List<PhysicianModel> _physicians = [];

//   // Selected values
//   SpecialtyModel? _selectedSpecialty;
//   PhysicianModel? _selectedPhysician;
//   DateTime? _selectedDate;
//   TimeOfDay? _selectedTime;
//   String _consultationType = 'consultation';

//   // Patient state
//   bool _isCheckingPatient = false;
//   bool _patientExists = false;
//   bool _showNewPatientForm = false;
//   String? _patientName;

//   // Loading states
//   bool _isLoadingSpecialties = false;
//   bool _isLoadingPhysicians = false;
//   bool _isCreatingPatient = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadSpecialties();
//   }

//   @override
//   void dispose() {
//     _patientIdController.dispose();
//     _newPatientNameController.dispose();
//     _notesController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadSpecialties() async {
//     setState(() => _isLoadingSpecialties = true);
//     try {
//       final response = await _api.getSpecialties();
//       if (response.success == true && response.data != null) {
//         setState(() {
//           _specialties = response.data!.cast<SpecialtyModel>();
//         });
//       } else {
//         _showErrorSnackBar('Erreur lors du chargement des spécialités');
//       }
//     } catch (e) {
//       _showErrorSnackBar(
//           'Erreur de connexion lors du chargement des spécialités');
//     } finally {
//       setState(() => _isLoadingSpecialties = false);
//     }
//   }

//   Future<void> _loadPhysicians(int specialtyId) async {
//     setState(() => _isLoadingPhysicians = true);
//     try {
//       final response =
//           await _api.getPhysiciansBySpecialty({'specialty_id': specialtyId});
//       if (response.success == true && response.data != null) {
//         setState(() {
//           _physicians = response.data!.cast<PhysicianModel>();
//           _selectedPhysician = null;
//         });
//       } else {
//         _showErrorSnackBar('Erreur lors du chargement des médecins');
//       }
//     } catch (e) {
//       _showErrorSnackBar('Erreur de connexion lors du chargement des médecins');
//     } finally {
//       setState(() => _isLoadingPhysicians = false);
//     }
//   }

//   Future<void> _checkPatient() async {
//     if (_patientIdController.text.isEmpty) {
//       _showErrorSnackBar('Veuillez entrer un ID patient');
//       return;
//     }

//     setState(() {
//       _isCheckingPatient = true;
//       _patientExists = false;
//       _showNewPatientForm = false;
//       _patientName = null;
//     });

//     // try {
//     //   final patientId = int.tryParse(_patientIdController.text);
//     //   if (patientId == null) {
//     //     _showErrorSnackBar('ID patient invalide');
//     //     return;
//     //   }

//     //   final CheckPatientResponse response =
//     //       await _api.checkPatientExists({'patient_id': patientId});

//     //   if (response.exists == true) {
//     //     setState(() {
//     //       _patientExists = true;
//     //       _patientName = response.patientName;
//     //     });
//     //     _showSuccessSnackBar(
//     //         'Patient trouvé: ${response.patientName ?? 'ID $patientId'}');
//     //   } else {
//     //     setState(() {
//     //       _showNewPatientForm = true;
//     //     });
//     //     _showErrorSnackBar(
//     //         'Patient non trouvé. Veuillez créer un nouveau patient');
//     //   }
//     // } catch (e) {
//     //   _showErrorSnackBar('Erreur lors de la vérification du patient');
//     // } finally {
//     //   setState(() => _isCheckingPatient = false);
//     // }
//   }

//   // Future<void> _createPatient() async {
//   //   if (_newPatientNameController.text.trim().isEmpty) {
//   //     _showErrorSnackBar('Veuillez entrer le nom du patient');
//   //     return;
//   //   }

//   //   setState(() => _isCreatingPatient = true);
//   //   try {
//   //     final CreatePatientResponse response = await _api.createPatient({
//   //       'name': _newPatientNameController.text.trim(),
//   //     });

//   //     if (response.success == true && response.patientId != null) {
//   //       setState(() {
//   //         _patientIdController.text = response.patientId.toString();
//   //         _patientExists = true;
//   //         _showNewPatientForm = false;
//   //         _patientName = _newPatientNameController.text.trim();
//   //       });
//   //       _newPatientNameController.clear();
//   //       _showSuccessSnackBar(
//   //           'Patient créé avec succès (ID: ${response.patientId})');
//   //     } else {
//   //       _showErrorSnackBar(
//   //           'Erreur lors de la création: ${response.message ?? 'Erreur inconnue'}');
//   //     }
//   //   } catch (e) {
//   //     _showErrorSnackBar('Erreur de connexion lors de la création du patient');
//   //   } finally {
//   //     setState(() => _isCreatingPatient = false);
//   //   }
//   // }

//   Future<void> _selectDate() async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate ?? DateTime.now(),
//       firstDate: DateTime.now(),
//       lastDate: DateTime.now().add(const Duration(days: 365)),
//     );
//     if (picked != null) {
//       setState(() => _selectedDate = picked);
//     }
//   }

//   Future<void> _selectTime() async {
//     final TimeOfDay? picked = await showTimePicker(
//       context: context,
//       initialTime: _selectedTime ?? TimeOfDay.now(),
//     );
//     if (picked != null) {
//       setState(() => _selectedTime = picked);
//     }
//   }

//   Future<void> _createAppointment() async {
//     if (!_formKey.currentState!.validate()) return;

//     if (!_patientExists) {
//       _showErrorSnackBar('Veuillez vérifier le patient d\'abord');
//       return;
//     }

//     if (_selectedSpecialty == null) {
//       _showErrorSnackBar('Veuillez sélectionner une spécialité');
//       return;
//     }

//     if (_selectedPhysician == null) {
//       _showErrorSnackBar('Veuillez sélectionner un médecin');
//       return;
//     }

//     if (_selectedDate == null) {
//       _showErrorSnackBar('Veuillez sélectionner une date');
//       return;
//     }

//     if (_selectedTime == null) {
//       _showErrorSnackBar('Veuillez sélectionner une heure');
//       return;
//     }

//     final appointmentProvider =
//         Provider.of<AppointmentProvider>(context, listen: false);

//     // Combine date and time
//     final DateTime appointmentDateTime = DateTime(
//       _selectedDate!.year,
//       _selectedDate!.month,
//       _selectedDate!.day,
//       _selectedTime!.hour,
//       _selectedTime!.minute,
//     );

//     final bool success = await appointmentProvider.createAppointment(
//       patientId: int.parse(_patientIdController.text),
//       date: DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(appointmentDateTime),
//       consultationType: _consultationType,
//       productId: _selectedSpecialty!.id ?? 0,
//       physicianId: _selectedPhysician!.id?.toString(),
//       additionalData: {
//         'notes': _notesController.text.trim(),
//         'specialty_id': _selectedSpecialty!.id,
//       },
//     );

//     if (success) {
//       _showSuccessSnackBar('Rendez-vous créé avec succès');
//       Navigator.pop(context, true); // Return true to indicate success
//     } else {
//       _showErrorSnackBar(appointmentProvider.createAppointmentError ??
//           'Erreur lors de la création');
//     }
//   }

//   void _showErrorSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red,
//       ),
//     );
//   }

//   void _showSuccessSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.green,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Créer un Rendez-vous'),
//         backgroundColor: Theme.of(context).primaryColor,
//       ),
//       body: Consumer<AppointmentProvider>(
//         builder: (context, appointmentProvider, child) {
//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(16.0),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Patient Section
//                   _buildSectionTitle('Informations Patient'),
//                   const SizedBox(height: 8),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: TextFormField(
//                           controller: _patientIdController,
//                           decoration: InputDecoration(
//                             labelText: 'ID Patient',
//                             border: const OutlineInputBorder(),
//                             enabled: !_patientExists,
//                             suffixIcon: _patientExists
//                                 ? const Icon(Icons.check_circle,
//                                     color: Colors.green)
//                                 : null,
//                           ),
//                           keyboardType: TextInputType.number,
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Veuillez entrer l\'ID du patient';
//                             }
//                             if (int.tryParse(value) == null) {
//                               return 'ID patient invalide';
//                             }
//                             return null;
//                           },
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       _isCheckingPatient
//                           ? const CircularProgressIndicator()
//                           : ElevatedButton.icon(
//                               onPressed: _patientExists ? null : _checkPatient,
//                               icon: const Icon(Icons.search),
//                               label: const Text('Vérifier'),
//                             ),
//                     ],
//                   ),

//                   if (_patientExists && _patientName != null) ...[
//                     const SizedBox(height: 8),
//                     Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: Colors.green.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(color: Colors.green),
//                       ),
//                       child: Row(
//                         children: [
//                           const Icon(Icons.person, color: Colors.green),
//                           const SizedBox(width: 8),
//                           Text('Patient: $_patientName',
//                               style:
//                                   const TextStyle(fontWeight: FontWeight.bold)),
//                         ],
//                       ),
//                     ),
//                   ],

//                   if (_showNewPatientForm) ...[
//                     const SizedBox(height: 16),
//                     TextFormField(
//                       controller: _newPatientNameController,
//                       decoration: const InputDecoration(
//                         labelText: 'Nom du nouveau patient',
//                         border: OutlineInputBorder(),
//                       ),
//                       validator: (value) {
//                         if (value == null || value.trim().isEmpty) {
//                           return 'Veuillez entrer le nom du patient';
//                         }
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 8),
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton.icon(
//                         onPressed: _isCreatingPatient ? null : ,
//                         icon: _isCreatingPatient
//                             ? const SizedBox(
//                                 width: 16,
//                                 height: 16,
//                                 child:
//                                     CircularProgressIndicator(strokeWidth: 2))
//                             : const Icon(Icons.add),
//                         label: const Text('Créer le patient'),
//                       ),
//                     ),
//                   ],

//                   const SizedBox(height: 24),

//                   // Medical Information Section
//                   _buildSectionTitle('Informations Médicales'),
//                   const SizedBox(height: 8),

//                   // Specialty Dropdown
//                   DropdownButtonFormField<SpecialtyModel>(
//                     decoration: const InputDecoration(
//                       labelText: 'Spécialité',
//                       border: OutlineInputBorder(),
//                     ),
//                     value: _selectedSpecialty,
//                     items: _specialties.map((specialty) {
//                       return DropdownMenuItem(
//                         value: specialty,
//                         child: Text(specialty.name ?? 'Spécialité inconnue'),
//                       );
//                     }).toList(),
//                     onChanged: _isLoadingSpecialties
//                         ? null
//                         : (SpecialtyModel? newValue) {
//                             setState(() {
//                               _selectedSpecialty = newValue;
//                               _physicians.clear();
//                               _selectedPhysician = null;
//                             });
//                             if (newValue?.id != null) {
//                               _loadPhysicians(newValue!.id!);
//                             }
//                           },
//                     validator: (value) => value == null
//                         ? 'Veuillez sélectionner une spécialité'
//                         : null,
//                   ),

//                   const SizedBox(height: 16),

//                   // Physician Dropdown
//                   DropdownButtonFormField<PhysicianModel>(
//                     decoration: const InputDecoration(
//                       labelText: 'Médecin',
//                       border: OutlineInputBorder(),
//                     ),
//                     value: _selectedPhysician,
//                     items: _physicians.map((physician) {
//                       return DropdownMenuItem(
//                         value: physician,
//                         child: Text(physician.name ?? 'Médecin inconnu'),
//                       );
//                     }).toList(),
//                     onChanged: _isLoadingPhysicians
//                         ? null
//                         : (PhysicianModel? newValue) {
//                             setState(() => _selectedPhysician = newValue);
//                           },
//                     validator: (value) => value == null
//                         ? 'Veuillez sélectionner un médecin'
//                         : null,
//                   ),

//                   const SizedBox(height: 24),

//                   // Date and Time Section
//                   _buildSectionTitle('Date et Heure'),
//                   const SizedBox(height: 8),

//                   Row(
//                     children: [
//                       Expanded(
//                         child: InkWell(
//                           onTap: _selectDate,
//                           child: Container(
//                             padding: const EdgeInsets.all(16),
//                             decoration: BoxDecoration(
//                               border: Border.all(color: Colors.grey),
//                               borderRadius: BorderRadius.circular(4),
//                             ),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text(
//                                   _selectedDate == null
//                                       ? 'Sélectionner la date'
//                                       : DateFormat('dd/MM/yyyy')
//                                           .format(_selectedDate!),
//                                   style: TextStyle(
//                                     color: _selectedDate == null
//                                         ? Colors.grey[600]
//                                         : Colors.black,
//                                   ),
//                                 ),
//                                 const Icon(Icons.calendar_today),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       Expanded(
//                         child: InkWell(
//                           onTap: _selectTime,
//                           child: Container(
//                             padding: const EdgeInsets.all(16),
//                             decoration: BoxDecoration(
//                               border: Border.all(color: Colors.grey),
//                               borderRadius: BorderRadius.circular(4),
//                             ),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text(
//                                   _selectedTime == null
//                                       ? 'Sélectionner l\'heure'
//                                       : _selectedTime!.format(context),
//                                   style: TextStyle(
//                                     color: _selectedTime == null
//                                         ? Colors.grey[600]
//                                         : Colors.black,
//                                   ),
//                                 ),
//                                 const Icon(Icons.access_time),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 24),

//                   // Consultation Type Section
//                   _buildSectionTitle('Type de Consultation'),
//                   const SizedBox(height: 8),

//                   DropdownButtonFormField<String>(
//                     decoration: const InputDecoration(
//                       labelText: 'Type de consultation',
//                       border: OutlineInputBorder(),
//                     ),
//                     value: _consultationType,
//                     items: const [
//                       DropdownMenuItem(
//                           value: 'consultation', child: Text('Consultation')),
//                       DropdownMenuItem(
//                           value: 'urgence', child: Text('Urgence')),
//                       DropdownMenuItem(value: 'suivi', child: Text('Suivi')),
//                       DropdownMenuItem(
//                           value: 'controle', child: Text('Contrôle')),
//                     ],
//                     onChanged: (String? newValue) {
//                       if (newValue != null) {
//                         setState(() => _consultationType = newValue);
//                       }
//                     },
//                   ),

//                   const SizedBox(height: 16),

//                   // Notes Section
//                   TextFormField(
//                     controller: _notesController,
//                     decoration: const InputDecoration(
//                       labelText: 'Notes (optionnel)',
//                       border: OutlineInputBorder(),
//                       alignLabelWithHint: true,
//                     ),
//                     maxLines: 3,
//                     maxLength: 500,
//                   ),

//                   const SizedBox(height: 32),

//                   // Create Button
//                   SizedBox(
//                     width: double.infinity,
//                     height: 50,
//                     child: ElevatedButton.icon(
//                       onPressed: appointmentProvider.isCreatingAppointment
//                           ? null
//                           : _createAppointment,
//                       icon: appointmentProvider.isCreatingAppointment
//                           ? const SizedBox(
//                               width: 20,
//                               height: 20,
//                               child: CircularProgressIndicator(strokeWidth: 2))
//                           : const Icon(Icons.add),
//                       label: Text(appointmentProvider.isCreatingAppointment
//                           ? 'Création en cours...'
//                           : 'Créer le Rendez-vous'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Theme.of(context).primaryColor,
//                         foregroundColor: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildSectionTitle(String title) {
//     return Text(
//       title,
//       style: const TextStyle(
//         fontSize: 18,
//         fontWeight: FontWeight.bold,
//         color: Colors.black87,
//       ),
//     );
//   }
// }

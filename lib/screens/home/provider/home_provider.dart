import 'package:flutter/material.dart';
import 'package:medicall_app/Models/Patient/check_patient_response.dart';
import 'package:medicall_app/NetworkManager/odoo_api_client.dart';
import 'package:medicall_app/helper/shared_pref.dart';
import 'package:medicall_app/models/clinique/clinique_model.dart';

class HomeProvider with ChangeNotifier {
  final OdooApiClient apiClient;

  // Patient state
  bool isCheckingPatient = false;
  bool patientExists = false;
  bool showNewPatientForm = false;
  bool isCreatingPatient = false;
  String? patientError;

  // Clinics state
  bool isLoadingClinics = false;
  List<CliniqueModel> clinics = [];
  String? clinicsError;

  HomeProvider(this.apiClient);

  /// Vérifie si le patient existe
  Future<void> checkPatient(String id) async {
    isCheckingPatient = true;
    patientError = null;
    patientExists = false;
    showNewPatientForm = false;
    notifyListeners();
    try {
      CheckPatientResponse resp =
          await apiClient.checkPatientExists({'gov_code': id});

      await SessionManager.setExpirationFlag(resp.exists ?? false);
      // Vous pouvez récupérer les infos patient si la réponse les contient
    } catch (e) {
      patientError = e.toString();
    }
    isCheckingPatient = false;
    notifyListeners();
  }

  /// Crée un nouveau patient
  // Future<void> createPatient(String name) async {
  //   isCreatingPatient = true;
  //   patientError = null;
  //   notifyListeners();
  //   try {
  //     final CreatePatientResponse resp =
  //         await apiClient.createPatient({'name': name});
  //     if (resp.success == true && resp.patientId != null) {
  //       patientExists = true;
  //       showNewPatientForm = false;
  //     } else {
  //       patientError = resp.message;
  //     }
  //   } catch (e) {
  //     patientError = e.toString();
  //   }
  //   isCreatingPatient = false;
  //   notifyListeners();
  // }
}

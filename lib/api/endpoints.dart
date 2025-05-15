// lib/api/endpoints.dart

abstract class Endpoints {
  static const String baseUrl = 'https://abc-hms-pro.odoo.com/odoo/api';

  /// SMS / Auth
  static const String sendCode = '/si7a/send_code';
  static const String register = '/si7a/register';
  static const String login = '/si7a/login';
  static const String resetPassword = '/si7a/reset_password';

  /// Cliniques / Patients / RDV
  static const String getClinics = '/si7a/cliniques';
  static const String createPatient = '/si7a/create_patient';
  static const String checkPatientExists = '/si7a/check_patient_exists';
  static const String createAppointment = '/si7a/create_appointment';

  /// Spécialités / Praticiens
  static const String getSpecialties = '/si7a/get_specialties';
  static const String getPhysiciansBySpecialty =
      '/si7a/get_physicians_by_specialty';
}

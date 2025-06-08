class ApiUrl {
  static const String baseUrl =
      "https://hms-pro.odoo.com/odoo/api"; // Set this in app initialization

  // Authentication endpoints
  static const String sendCodeUrl = "/si7a/send_code";
  static const String registerUrl = "/si7a/register";
  static const String loginUrl = "/si7a/login";
  static const String resetPasswordUrl = "/si7a/reset_password";

  // Clinique endpoints
  static const String cliniquesUrl = "/si7a/cliniques";

  // Patient endpoints
  static const String createPatientUrl = "/si7a/create_patient";
  static const String checkPatientExistsUrl = "/si7a/check_patient_exists";

  // Appointment endpoints
  static const String createAppointmentUrl = "/si7a/create_appointment";
  // Appointment history endpoint
  static const String appointmentHistoryUrl = "/si7a/get_appointments_by_patient";
  // Medical data endpoints
  static const String specialtiesUrl = "/si7a/get_specialties";
  static const String physiciansBySpecialtyUrl =
      "/si7a/get_physicians_by_specialty";
  static const String physicianDetailsUrl = "/si7a/get_all_physicians";


}

class Endpoints {
  // URL de base de l'API Odoo
  static const String baseUrl = 'https://abc-hms-pro.odoo.com/odoo/api';

  // Endpoints d'authentification
  static const String register = '/si7a/create';
  static const String login = '/si7a/login';
  static const String refreshToken = '/si7a/refresh-token';
  static const String checkStatus = '/si7a/check-status';

  // Endpoints pour les utilisateurs
  static const String users = '/si7a/users';
  static String userById(String userId) => '$users/$userId';
  static String userProfile(String userId) => '$users/$userId/profile';

  // Endpoints pour les cliniques
  static const String clinics = '/si7a/clinics';
  static String clinicById(String clinicId) => '$clinics/$clinicId';
  static String clinicServices(String clinicId) =>
      '$clinics/$clinicId/services';
  static String clinicAvailability(String clinicId) =>
      '$clinics/$clinicId/availability';

  // Endpoints pour les rendez-vous
  static const String appointments = '/si7a/appointments';
  static String appointmentById(String appointmentId) =>
      '$appointments/$appointmentId';
  static String userAppointments(String userId) =>
      '$users/$userId/appointments';
  static String appointmentPayment(String appointmentId) =>
      '$appointments/$appointmentId/payment';
  static String cancelAppointment(String appointmentId) =>
      '$appointments/$appointmentId/cancel';
}

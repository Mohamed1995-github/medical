// lib/config/routes.dart

import 'package:flutter/material.dart';
import 'package:medical_app/screens/Clinique/clinique_page.dart';
import '../screens/Authentication/login_page.dart';
import '../screens/Authentication/register_page.dart';
import '../screens/Authentication/reset_password_page.dart';
// import '../screens/verify_sms_code_page.dart';
// import '../screens/clinic_list_page.dart';
// import '../screens/home_page.dart';
// import '../screens/profile_page.dart';
// import '../screens/history_page.dart';
// import '../screens/create_appointment_page.dart';
// import '../screens/payment_page.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/login': (c) => LoginPage(),
  '/register': (c) => RegisterPage(),
  '/reset-password': (c) => ResetPasswordPage(),
  '/clinic-list': (c) => CliniquesListPage(),
  // '/verify-sms-code': (c) {
  //   final args = ModalRoute.of(c)!.settings.arguments as Map<String, dynamic>;
  //   return VerifySmsCodePage(
  //     phoneNumber: args['phoneNumber'] as String,
  //     userId: args['userId'] as String,
  //   );
  // },
  // '/clinics': (c) => ClinicListPage(),
  // '/home': (c) => HomePage(),
  // '/profile': (c) => ProfilePage(),
  // '/history': (c) => HistoryPage(),

  // // 🚑 Create Appointment : on lit clinic & govCode depuis arguments
  // '/create-appointment': (c) {
  //   final args = ModalRoute.of(c)!.settings.arguments as Map<String, dynamic>;
  //   return CreateAppointmentPage(
  //     clinic: args['clinic'] as Clinic,
  //     govCode: args['govCode'] as String,
  //   );
  // },

  // '/payment': (c) => PaymentPage(),
};

class NavigationHelper {
  static void navigateToLogin(BuildContext c) =>
      Navigator.pushReplacementNamed(c, '/login');
  static void navigateToRegister(BuildContext c) =>
      Navigator.pushNamed(c, '/register');
  static void navigateToResetPassword(BuildContext c) =>
      Navigator.pushNamed(c, '/reset-password');
  static void navigateToClinics(BuildContext c) =>
      Navigator.pushNamed(c, '/clinic-list');

  // static void navigateToHome(BuildContext c) =>
  //     Navigator.pushReplacementNamed(c, '/home');
  // static void navigateToClinics(BuildContext c) =>
  //     Navigator.pushNamed(c, '/clinics');
  // static void navigateToHistory(BuildContext c) =>
  //     Navigator.pushNamed(c, '/history');

  // static void navigateToCreateAppointment(
  //   BuildContext c, {
  //   required Clinic clinic,
  //   required String govCode,
  // }) =>
  //     Navigator.pushNamed(
  //       c,
  //       '/create-appointment',
  //       arguments: {
  //         'clinic': clinic,
  //         'govCode': govCode,
  //       },
  //     );

  // static void navigateToPayment(BuildContext c, {required int appointmentId}) =>
  //     Navigator.pushNamed(
  //       c,
  //       '/payment',
  //       arguments: {'appointmentId': appointmentId},
  //     );

  // static void navigateToProfile(BuildContext c) =>
  //     Navigator.pushNamed(c, '/profile');
}

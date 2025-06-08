// lib/config/routes.dart

import 'package:flutter/material.dart';
import 'package:medicall_app/screens/payment.dart';
import '../screens/Clinique/clinique_page.dart';
import '../screens/Authentication/login_page.dart';
import '../screens/Authentication/register_page.dart';
import '../screens/Authentication/reset_password_page.dart';
// import '../screens/verify_sms_code_page.dart';
// import '../screens/clinic_list_page.dart';
import '../screens/home/home_page.dart';
// import '../screens/profile_page.dart';
// import '../screens/history_page.dart';
// import '../screens/clinique/create_appointment.dart';
import '../screens/patient/patient.dart';
import '../screens/Medical/speciality.dart';
import '../screens/Medical/all_physisian.dart';
// import '../screens/payment_page.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/login': (c) => LoginPage(),
  '/register': (c) => RegisterPage(),
  '/reset-password': (c) => ResetPasswordPage(),
  '/clinic-list': (c) => CliniquesListPage(),
  // '/create-appointment': (c) => CreateAppointmentPage(),
  '/patient-choice': (c) => PatientChoicePage(),

  // '/verify-sms-code': (c) {
  //   final args = ModalRoute.of(c)!.settings.arguments as Map<String, dynamic>;
  //   return VerifySmsCodePage(
  //     phoneNumber: args['phoneNumber'] as String,
  //     userId: args['userId'] as String,
  //   );
  // },
  // '/clinics': (c) => ClinicListPage(),
  '/home': (c) => HomePage(),
  '/speciality': (c) => SpecialtyScreen(),
  '/payment': (c) => PaymentWalletSelectionPage(),
  '/physicians': (c) => AllPhysiciansScreen(),
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
  static const routeName = '/create-appointment';
  static void navigateToHome(BuildContext c) =>
      Navigator.pushReplacementNamed(c, '/home');
  static void navigateToPatientChoice(BuildContext c) =>
      Navigator.pushNamed(c, '/patient-choice');
  static void navigateToSpeciality(BuildContext c) =>
      Navigator.pushNamed(c, '/speciality');
  static void navigateToPayment(BuildContext c) =>
      Navigator.pushNamed(c, '/payment');
  static void navigateToPhysicians(BuildContext c) =>
      Navigator.pushNamed(c, '/physicians');
}

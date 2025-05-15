// lib/config/routes.dart

import 'package:flutter/material.dart';
import '../screens/login_page.dart';
import '../screens/register_page_odoo.dart';
import '../screens/clinic_list_page.dart';
import '../models/clinic.dart';
import '../screens/home_page.dart';
import '../screens/profile_page.dart';
import '../screens/history_page.dart';
import '../screens/create_appointment_page.dart';
import '../screens/payment_page.dart';
import '../screens/verify_sms_code_page.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/login': (c) => LoginPage(),
  '/register': (c) => RegisterPageOdoo(),
  '/verify-sms-code': (c) {
    final args = ModalRoute.of(c)!.settings.arguments as Map<String, dynamic>;
    return VerifySmsCodePage(
      phoneNumber: args['phoneNumber'] as String,
      userId: args['userId'] as String,
    );
  },
  '/clinics': (c) => ClinicListPage(),
  '/home': (c) => HomePage(),
  '/profile': (c) => ProfilePage(),
  '/history': (c) => HistoryPage(),
  '/create-appointment': (c) {
    final args = ModalRoute.of(c)!.settings.arguments as Map<String, dynamic>;
    return CreateAppointmentPage(
      clinic: args['clinic']
          as Clinic, // plus de clinic_list.Clinic :contentReference[oaicite:2]{index=2}:contentReference[oaicite:3]{index=3}
      govCode: args['govcode'] as String,
    );
  },
  '/payment': (c) => PaymentPage(),
};

class NavigationHelper {
  static void navigateToLogin(BuildContext c) =>
      Navigator.pushReplacementNamed(c, '/login');
  static void navigateToRegister(BuildContext c) =>
      Navigator.pushNamed(c, '/register');
  static void navigateToHome(BuildContext c) =>
      Navigator.pushReplacementNamed(c, '/home');
  static void navigateToClinics(BuildContext c) =>
      Navigator.pushNamed(c, '/clinics');
  static void navigateToHistory(BuildContext c) =>
      Navigator.pushNamed(c, '/history');

  static void navigateToCreateAppointment(
    BuildContext c, {
    required Clinic clinic,
    required String govCode,
  }) =>
      Navigator.pushNamed(
        c,
        '/create-appointment',
        arguments: {
          'clinic': clinic,
          'govCode': govCode,
        },
      );

  static void navigateToPayment(BuildContext c, {Object? arguments}) =>
      Navigator.pushNamed(c, '/payment', arguments: arguments);

  static void navigateToProfile(BuildContext c) => Navigator.pushNamed(c,
      '/profile'); // ajouté pour régler l'erreur :contentReference[oaicite:4]{index=4}:contentReference[oaicite:5]{index=5}
}

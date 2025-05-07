import 'package:flutter/material.dart';
import '../screens/login_page.dart';
import '../screens/register_page_odoo.dart';
import '../screens/clinic_list_page.dart' as clinic_list;
// Make sure the path and class name match your project structure
import '../screens/home_page.dart';
import '../screens/profile_page.dart';
import '../screens/history_page.dart';
import '../screens/create_appointment_page.dart';
import '../screens/payment_page.dart';
import '../screens/verify_sms_code_page.dart';

// Définition des routes de l'application
final Map<String, WidgetBuilder> appRoutes = {
  '/login': (context) => LoginPage(),
  '/register': (context) => RegisterPageOdoo(),
  '/verify-sms-code': (context) {
    // Assuming you have a VerifySmsCodePage that takes phoneNumber and userId as parameters
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return VerifySmsCodePage(
        phoneNumber: args['phoneNumber'], userId: args['userId']);
  },
  // You must provide actual values for phoneNumber and userId here or handle them dynamically
  // Example with placeholder values:
  // '/register': (context) => VerifySmsCodePage(phoneNumber: '1234567890', userId: 1),
  // Or remove this route if you do not have default values
  '/clinics': (context) => clinic_list.ClinicListPage(),
  '/home': (context) => HomePage(),
  '/profile': (context) => ProfilePage(),
  '/history': (context) => HistoryPage(),
  '/create-appointment': (context) => CreateAppointmentPage(),
  '/payment': (context) => PaymentPage(),
};

// Navigation helper
class NavigationHelper {
  static void navigateToLogin(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/login');
  }

  static void navigateToRegister(BuildContext context) {
    Navigator.pushNamed(context, '/register');
  }

  static void navigateToHome(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/home');
  }

  static void navigateToClinics(BuildContext context) {
    Navigator.pushNamed(context, '/clinics');
  }

  static void navigateToProfile(BuildContext context) {
    Navigator.pushNamed(context, '/profile');
  }

  static void navigateToHistory(BuildContext context) {
    Navigator.pushNamed(context, '/history');
  }

  static void navigateToCreateAppointment(BuildContext context) {
    Navigator.pushNamed(context, '/create-appointment');
  }

  static void navigateToPayment(BuildContext context, {Object? arguments}) {
    Navigator.pushNamed(context, '/payment', arguments: arguments);
  }
}

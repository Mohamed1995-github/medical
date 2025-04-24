import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/dashboard_page.dart';
import 'utils/theme.dart';
import 'utils/auth_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();

    // Listen for authentication state changes
    _authService.userStream.listen((user) {
      // You could use this to handle app-wide authentication state
      // For this example, we'll just print the user
      print('Current user: ${user?.name ?? 'Not logged in'}');
    });
  }

  @override
  void dispose() {
    _authService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediCall',
      theme: AppTheme.lightTheme,

      // Define initial route based on authentication state
      initialRoute: _authService.isAuthenticated ? '/dashboard' : '/login',

      // Define named routes
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/dashboard': (context) => const DashboardPage(),
      },

      // Fallback route handler
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('Not Found')),
            body: const Center(
              child: Text('Page not found'),
            ),
          ),
        );
      },
    );
  }
}

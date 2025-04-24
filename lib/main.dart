import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
import 'pages/login_page.dart';
import 'utils/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediCall',
      theme: AppTheme.lightTheme,
      home: const LoginPage(),
    );
  }
}

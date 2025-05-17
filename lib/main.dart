// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medical_app/NetworkManager/odoo_api_client.dart';
import 'package:medical_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/routes.dart';
import 'config/theme.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final apiClient = OdooApiClient.create();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    MultiProvider(
      providers: [
        Provider<OdooApiClient>(create: (_) => apiClient),
        ChangeNotifierProvider(
          create: (context) => AuthProvider(context.read<OdooApiClient>()),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clinique App',
      theme: appTheme,
      initialRoute: '/login',
      routes: appRoutes,
      // home: AuthCheckPage(), // supprimé car non défini :contentReference[oaicite:0]{index=0}:contentReference[oaicite:1]{index=1}
      debugShowCheckedModeBanner: false,
    );
  }
}

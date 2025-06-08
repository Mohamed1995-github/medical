// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:medicall_app/NetworkManager/odoo_api_client.dart';
import 'package:medicall_app/screens/Authentication/provider/auth_provider.dart';
import 'package:medicall_app/screens/Clinique/provider/clinique_provider.dart';
import 'package:medicall_app/screens/home/provider/home_provider.dart';
import 'package:medicall_app/screens/patient/patint_provider.dart';
import 'package:medicall_app/screens/Medical/provider/medical_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/routes.dart';
import 'config/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Await the Future to get the OdooApiClient instance
  final apiClient = await OdooApiClient.create();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        Provider<OdooApiClient>.value(value: apiClient),
        ChangeNotifierProvider(
          create: (context) => AuthProvider(context.read<OdooApiClient>()),
        ),
        ChangeNotifierProvider(
          create: (context) => CliniqueProvider(context.read<OdooApiClient>()),
        ),
        ChangeNotifierProvider(
          create: (context) => HomeProvider(context.read<OdooApiClient>()),
        ),
        ChangeNotifierProvider(
          create: (ctx) => PatientProvider(
            apiClient: ctx.read<OdooApiClient>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (ctx) => MedicalProvider(
            apiClient: ctx.read<OdooApiClient>(),
          ),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("PatientProvider dispo ? ${context.read<PatientProvider>()}");

    return MaterialApp(
      title: 'Clinique App',
      theme: appTheme,
      initialRoute: '/home',
      routes: appRoutes,
      // home: AuthCheckPage(), // supprimé car non défini :contentReference[oaicite:0]{index=0}:contentReference[oaicite:1]{index=1}
      debugShowCheckedModeBanner: false,
    );
  }
}

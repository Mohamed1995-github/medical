// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'config/routes.dart';
import 'config/theme.dart';

import 'screens/login_page.dart';
import 'services/auth_service.dart';
import 'services/clinic_service.dart';

import 'api/odoo_api_client.dart';
import 'api/auth_api_odoo.dart';
import 'services/odoo_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(
    MultiProvider(
      providers: [
        Provider<OdooApiClient>(
          create: (_) => OdooApiClient(),
          dispose: (_, c) => c.close(),
        ),
        Provider<AuthApiOdoo>(
          create: (ctx) => AuthApiOdoo(apiClient: ctx.read<OdooApiClient>()),
        ),
        ChangeNotifierProvider<AuthService>(
          create: (_) => AuthService(),
        ),
        ChangeNotifierProvider<ClinicService>(
          create: (ctx) => ClinicService(apiClient: ctx.read<OdooApiClient>()),
        ),
        Provider<OdooService>(
          create: (ctx) => OdooService(apiClient: ctx.read<OdooApiClient>()),
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

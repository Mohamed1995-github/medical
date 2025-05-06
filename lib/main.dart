import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'config/routes.dart';
import 'config/theme.dart';
import 'screens/login_page.dart';
import 'services/auth_service.dart';
import 'api/odoo_api_client.dart';
import 'api/auth_api_odoo.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(
    MultiProvider(
      providers: [
        // Fournir le client API Odoo
        Provider<OdooApiClient>(
          create: (_) => OdooApiClient(),
          dispose: (_, client) => client.close(),
        ),

        // Fournir l'API d'authentification Odoo
        Provider<AuthApiOdoo>(
          create: (context) => AuthApiOdoo(
            apiClient: Provider.of<OdooApiClient>(context, listen: false),
          ),
        ),

        // Fournir le service d'authentification
        ChangeNotifierProvider<AuthService>(
          create: (_) => AuthService(),
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
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      initialRoute: '/login',
      routes: appRoutes,
      home: AuthCheckPage(),
    );
  }
}

// Créer une page intermédiaire pour vérifier l'authentification
class AuthCheckPage extends StatefulWidget {
  @override
  _AuthCheckPageState createState() => _AuthCheckPageState();
}

class _AuthCheckPageState extends State<AuthCheckPage> {
  late Future<bool> _authCheckFuture;

  @override
  void initState() {
    super.initState();
    // Initialiser le service d'authentification dans initState plutôt que dans build
    _authCheckFuture =
        Provider.of<AuthService>(context, listen: false).initializeService();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _authCheckFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Si l'utilisateur est déjà connecté, aller à la page d'accueil
        // Sinon, aller à la page de connexion
        if (snapshot.data == true) {
          // Rediriger vers la page d'accueil
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/home');
          });
        } else {
          // Rediriger vers la page de connexion
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/login');
          });
        }

        // Pendant la redirection, afficher un écran de chargement
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}

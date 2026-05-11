import 'package:app_bitacora/provider/user_provider.dart';
// import 'package:app_bitacora/services/seed_service.dart';
import 'package:app_bitacora/ui/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/local_db.dart';
import 'provider/bitacora_provider.dart';
import 'ui/screens/bitacoras_list.dart'; // Importar BitacorasListScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalDB.instance.db;
  // await SeedService.seedIfNeeded();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<BitacoraProvider>(create: (_) => BitacoraProvider()),
        ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider()), // Se inicializa aquí
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal),
      // home ya no es estático, depende del estado del usuario
      home: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          // Si hay un usuario logueado, va a la lista de bitácoras, sino al login.
          return userProvider.user != null
              ? const BitacorasListScreen()
              : const LoginScreen();
        },
      ),
      routes: {
        // Mantener las rutas si las usas, pero la navegación inicial se hace con Consumer.
        '/login': (_) => const LoginScreen(),
        '/bitacoras': (_) => const BitacorasListScreen(), // Añadir ruta para BitacorasListScreen
      },
    );
  }
}

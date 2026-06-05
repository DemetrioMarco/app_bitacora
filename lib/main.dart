import 'package:app_bitacora/provider/user_provider.dart';
import 'package:app_bitacora/services/navigator_service.dart';
import 'package:app_bitacora/ui/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/local_db.dart';
import 'provider/bitacora_provider.dart';
import 'ui/screens/bitacoras_list.dart'; // Importar BitacorasListScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalDB.instance.db;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<BitacoraProvider>(create: (_) => BitacoraProvider()),
        ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider()),
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
      title: 'MSS-PLUS',
      navigatorKey: NavigatorService.navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal),
      home: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          // Mientras lee el storage, muestra una pantalla de carga y evita el flasheo
          if (userProvider.isLoading) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: Colors.teal),
              ),
            );
          }
          
          return userProvider.user != null
              ? const BitacorasListScreen()
              : const LoginScreen();
        },
      ),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/bitacoras': (_) => const BitacorasListScreen(), // Añadir ruta para BitacorasListScreen
      },
    );
  }
}

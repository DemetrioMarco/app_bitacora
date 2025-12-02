import 'package:app_bitacora/provider/user_provider.dart';
import 'package:app_bitacora/services/seed_service.dart';
import 'package:app_bitacora/ui/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/local_db.dart';
import 'provider/bitacora_provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalDB.instance.db;
  await SeedService.seedIfNeeded();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<BitacoraProvider>(create: (_) => BitacoraProvider()),
        ChangeNotifierProvider<UserProvider>(create:  (_) => UserProvider())
      ],
      child: const MyApp(),)
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
      home: const LoginScreen(),
      routes: {
        '/login': (_) => const LoginScreen(),
      },
    );
  }
}
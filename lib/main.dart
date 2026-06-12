import 'package:app_bitacora/provider/user_provider.dart';
import 'package:app_bitacora/services/auth_service.dart';
import 'package:app_bitacora/services/navigator_service.dart';
import 'package:app_bitacora/services/task_service.dart';
import 'package:app_bitacora/ui/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/local_db.dart';
import 'provider/bitacora_provider.dart';
import 'ui/screens/bitacoras_list.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalDB.instance.db;

  final authService = AuthService.instance;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<BitacoraProvider>(create: (_) => BitacoraProvider()),
        Provider<AuthService>.value(value: authService),
        Provider<TaskService>(create: (context) => TaskService(context.read<AuthService>())),
        ChangeNotifierProvider<UserProvider>(create: (context) => UserProvider(context.read<AuthService>())),
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
        '/bitacoras': (_) => const BitacorasListScreen(),
      },
    );
  }
}

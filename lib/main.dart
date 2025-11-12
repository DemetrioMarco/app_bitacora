// lib/main.dart
import 'package:flutter/material.dart';
import 'ui/screens/bitacoras_list.dart'; // ruta según tu proyecto

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi App',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const HomeScreen(), // usa tu HomeScreen existente o la que pongo más abajo
      routes: {
        '/bitacoras': (_) => const BitacorasListScreen(),
      },
    );
  }
}

/// Si ya tienes HomeScreen, ignora este widget. Es un ejemplo que integra la pantalla.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: const Center(child: Text('Pantalla principal')),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Abrir Bitácoras',
        onPressed: () => Navigator.of(context).pushNamed('/bitacoras'),
        child: const Icon(Icons.list),
      ),
    );
  }
}
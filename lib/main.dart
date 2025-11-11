import 'package:flutter/material.dart';
import 'package:app_bitacora/data/repositories/cat_repo.dart';
import 'package:app_bitacora/services/api_service.dart';
import 'package:app_bitacora/services/sync_service.dart';
import 'package:app_bitacora/ui/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final repo = CatalogRepo();
  final api = ApiService(); // tu implementación existente
  final syncService = SyncService(api: api, repo: repo);

  runApp(MyApp(syncService: syncService, repo: repo));
}

class MyApp extends StatelessWidget {
  final SyncService syncService;
  final CatalogRepo repo;

  const MyApp({super.key, required this.syncService, required this.repo});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'APP_BITACORA',
      theme: ThemeData.from(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      home: HomeScreen(syncService: syncService, repo: repo),
    );
  }
}

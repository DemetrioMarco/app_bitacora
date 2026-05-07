import 'package:app_bitacora/models/app_user.dart';
import 'package:app_bitacora/services/auth_service.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  AppUser? _user;
  AppUser? get user => _user;

  // Constructor para inicializar el usuario al crear el provider
  UserProvider() {
    _initializeUser();
  }

  // Método privado para cargar el usuario desde el almacenamiento seguro
  Future<void> _initializeUser() async {
    _user = await AuthService.instance.getCurrentUser();
    notifyListeners();
  }

  Future<void> loginUser(AppUser user) async {
    _user = user;
    notifyListeners();
  }

  Future<void> logout() async {
    await AuthService.instance.logout();
    _user = null;
    notifyListeners();
  }
}

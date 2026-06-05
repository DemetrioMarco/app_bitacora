import 'package:app_bitacora/models/app_user.dart';
import 'package:app_bitacora/services/auth_service.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  AppUser? _user;
  bool _isLoading = true; // Nueva variable de estado

  AppUser? get user => _user;
  bool get isLoading => _isLoading;

  UserProvider() {
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    try {
      _user = await AuthService.instance.getCurrentUser();
    } catch (e) {
      debugPrint("Error inicializando usuario: $e");
      await AuthService.instance.logout();
      _user = null;
    } finally {
      _isLoading = false; 
      notifyListeners();
    }
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

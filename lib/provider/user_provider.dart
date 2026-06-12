import 'package:app_bitacora/models/app_user.dart';
import 'package:app_bitacora/services/auth_service.dart';
import 'package:app_bitacora/utils/exceptions.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  UserProvider(this._authService) {
    _initializeUser();
  }

  final AuthService _authService;

  AppUser? _user;
  bool _isLoading = true;

  AppUser? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;

  Future<void> _initializeUser() async {
    try {
      final hasSession = await _authService.hasSession();

      if (!hasSession) {
        _user = null;
        return;
      }

      _user = await _authService.getCurrentUser();
    } on AppException catch (e) {
      debugPrint('Error inicializando usuario: ${e.userMessage}');
      _user = null;
    } catch (e) {
      debugPrint('Error inicializando usuario: $e');
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setUserFromLogin(AppUser userData) async {
    _user = userData;
    notifyListeners();
  }

  Future<void> refreshUserFromStorage() async {
    try {
      _user = await _authService.getCurrentUser();
      notifyListeners();
    } catch (e) {
      debugPrint('Error recargando usuario: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (e) {
      debugPrint('Error cerrando sesión: $e');
    } finally {
      _user = null;
      notifyListeners();
    }
  }
}

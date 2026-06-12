import 'dart:convert';

import 'package:app_bitacora/constants/env.dart';
import 'package:app_bitacora/models/app_user.dart';
import 'package:app_bitacora/utils/exceptions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String _kAccess = 'access_token';
  static const String _kRefresh = 'refresh_token';
  static const String _kUser = 'user_json';
  static const String _kExpiry = 'session_expiry';

  static const Duration _sessionDuration = Duration(days: 15);

  Future<AppUser> login(String email, String password) async {
    try {
      final res = await http
          .post(
            Uri.parse('${Env.apiBaseUrl}${Env.loginPath}'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 20));

      if (res.statusCode == 401 || res.statusCode == 403) {
        throw const AuthException(
          message: 'Credenciales inválidas',
        );
      }

      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw ServerException(
          message: 'Error en el login',
          cause: res.body,
        );
      }

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      await _persist(data);

      final userData = data['user'];
      if (userData is Map<String, dynamic>) {
        return AppUser.fromJson(userData);
      }

      throw const FormatAppException(
        message: 'El servidor no regresó la información del usuario',
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException(cause: e);
    }
  }

  Future<String?> refresh() async {
    try {
      final refreshToken = await _storage.read(key: _kRefresh);
      if (refreshToken == null || refreshToken.isEmpty) return null;

      final res = await http
          .post(
            Uri.parse('${Env.apiBaseUrl}${Env.refreshPath}'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'refresh_token': refreshToken}),
          )
          .timeout(const Duration(seconds: 20));

      if (kDebugMode) {
        print('Refresh status: ${res.statusCode}');
      }

      if (res.statusCode == 401 || res.statusCode == 403) {
        await logout();
        return null;
      }

      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw ServerException(
          message: 'Error al refrescar la sesión',
          cause: res.body,
        );
      }

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      await _persist(data);

      return data['access_token'] as String?;
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException(cause: e);
    }
  }

  Future<void> _persist(Map<String, dynamic> data) async {
    try {
      final accessToken = data['access_token'] as String?;
      final refreshToken = data['refresh_token'] as String?;
      final user = data['user'];

      if (accessToken == null || accessToken.isEmpty) {
        throw const FormatAppException(
          message: 'El servidor no regresó un access_token válido',
        );
      }

      if (refreshToken == null || refreshToken.isEmpty) {
        throw const FormatAppException(
          message: 'El servidor no regresó un refresh_token válido',
        );
      }

      await _storage.write(key: _kAccess, value: accessToken);
      await _storage.write(key: _kRefresh, value: refreshToken);
      await _storage.write(key: _kUser, value: jsonEncode(user));

      final expireDate = DateTime.now().add(_sessionDuration);
      await _storage.write(key: _kExpiry, value: expireDate.toIso8601String());
    } catch (e) {
      if (e is AppException) rethrow;
      throw StorageException(cause: e);
    }
  }

  Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: _kAccess);
    } catch (e) {
      throw StorageException(cause: e);
    }
  }

  Future<AppUser?> getCurrentUser() async {
    try {
      final expiryStr = await _storage.read(key: _kExpiry);
      final raw = await _storage.read(key: _kUser);

      if (raw == null || expiryStr == null) return null;

      final expiryDate = DateTime.tryParse(expiryStr);
      if (expiryDate == null) {
        await logout();
        return null;
      }

      if (DateTime.now().isAfter(expiryDate)) {
        await logout();
        return null;
      }

      return AppUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      throw StorageException(cause: e);
    }
  }

  Future<bool> isLoggedIn() async => (await getCurrentUser()) != null;

  Future<Map<String, dynamic>?> getSavedUser() async {
    try {
      final raw = await _storage.read(key: _kUser);
      if (raw == null) return null;
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (e) {
      throw StorageException(cause: e);
    }
  }

  Future<bool> hasSession() async {
    try {
      final expiryStr = await _storage.read(key: _kExpiry);
      final raw = await _storage.read(key: _kUser);

      if (expiryStr == null || raw == null) return false;

      final expiryDate = DateTime.tryParse(expiryStr);
      if (expiryDate == null) {
        await logout();
        return false;
      }

      if (DateTime.now().isAfter(expiryDate)) {
        await logout();
        return false;
      }

      return true;
    } catch (e) {
      throw StorageException(cause: e);
    }
  }

  Future<void> logout() async {
    try {
      await _storage.delete(key: _kAccess);
      await _storage.delete(key: _kRefresh);
      await _storage.delete(key: _kUser);
      await _storage.delete(key: _kExpiry);
    } catch (e) {
      throw StorageException(cause: e);
    }
  }
}

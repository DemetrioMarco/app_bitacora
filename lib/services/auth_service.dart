import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:app_bitacora/constants/env.dart'; 
import 'package:app_bitacora/models/app_user.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  static const _storage = FlutterSecureStorage();
  static const _kAccess = 'access_token';
  static const _kRefresh = 'refresh_token';
  static const _kUser = 'user_json';

  Future<AppUser?> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('${Env.apiBaseUrl}${Env.loginPath}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (res.statusCode != 200) return null;

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    await _persist(data);
    return AppUser.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<String?> refresh() async {
    final refreshToken = await _storage.read(key: _kRefresh);
    if (refreshToken == null) return null;

    final res = await http.post(
      Uri.parse('${Env.apiBaseUrl}${Env.refreshPath}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh_token': refreshToken}),
    );

    if (res.statusCode != 200) {
      await logout();
      return null;
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    await _persist(data);
    return data['access_token'] as String?;
  }

  Future<void> _persist(Map<String, dynamic> data) async {
    await _storage.write(key: _kAccess, value: data['access_token'] as String);
    await _storage.write(key: _kRefresh, value: data['refresh_token'] as String);
    await _storage.write(key: _kUser, value: jsonEncode(data['user']));
  }

  Future<String?> getAccessToken() => _storage.read(key: _kAccess);

  Future<AppUser?> getCurrentUser() async {
    final raw = await _storage.read(key: _kUser);
    if (raw == null) return null;
    return AppUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<bool> isLoggedIn() async => (await _storage.read(key: _kAccess)) != null;

  Future<void> logout() async {
    await _storage.delete(key: _kAccess);
    await _storage.delete(key: _kRefresh);
    await _storage.delete(key: _kUser);
  }
}

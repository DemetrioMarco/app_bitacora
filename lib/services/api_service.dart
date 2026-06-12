import 'dart:convert';
import 'package:app_bitacora/constants/env.dart';
import 'package:app_bitacora/services/auth_service.dart';
import 'package:http/http.dart' as http;

class ApiService {
  ApiService(this._authService);

  final AuthService _authService;

  Future<http.Response> get(String path) =>
      _send(() async => http.get(_uri(path), headers: await _headers()));

  Future<http.Response> post(String path, {Object? body}) =>
      _send(() async => http.post(
            _uri(path),
            headers: await _headers(),
            body: jsonEncode(body),
          ));

  Future<http.Response> put(String path, {Object? body}) =>
      _send(() async => http.put(
            _uri(path),
            headers: await _headers(),
            body: jsonEncode(body),
          ));

  Future<http.Response> delete(String path) =>
      _send(() async => http.delete(_uri(path), headers: await _headers()));

  Uri _uri(String path) => Uri.parse('${Env.apiBaseUrl}$path');

  Future<Map<String, String>> _headers() async {
    final token = await _authService.getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> _send(Future<http.Response> Function() request) async {
    var res = await request();

    if (res.statusCode == 401) {
      try {
        await _authService.refresh();
        res = await request();
      } catch (_) {
        rethrow;
      }
    }

    return res;
  }
}

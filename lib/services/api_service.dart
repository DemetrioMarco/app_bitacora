import 'dart:convert';
import 'package:app_bitacora/constants/env.dart';
import 'package:http/http.dart' as http;

import 'package:app_bitacora/services/auth_service.dart';

class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  Future<http.Response> get(String path) =>
      _send(() async => http.get(_uri(path), headers: await _headers()));

  Future<http.Response> post(String path, {Object? body}) =>
      _send(() async => http.post(_uri(path), headers: await _headers(), body: jsonEncode(body)));

  Future<http.Response> put(String path, {Object? body}) =>
      _send(() async => http.put(_uri(path), headers: await _headers(), body: jsonEncode(body)));

  Future<http.Response> delete(String path) =>
      _send(() async => http.delete(_uri(path), headers: await _headers()));

  Uri _uri(String path) => Uri.parse('${Env.apiBaseUrl}$path');

  Future<Map<String, String>> _headers() async {
    final token = await AuthService.instance.getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> _send(Future<http.Response> Function() request) async {
    var res = await request();
    if (res.statusCode == 401) {
      final newToken = await AuthService.instance.refresh();
      if (newToken != null) res = await request();
    }
    return res;
  }
}

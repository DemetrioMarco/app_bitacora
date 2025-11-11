import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:app_bitacora/constants/env.dart'; // ajusta package: si tu paquete tiene otro id

class ApiService {
  final String baseUrl;
  final FlutterSecureStorage secureStorage;
  final http.Client client;

  ApiService({
    String? baseUrl,
    FlutterSecureStorage? secureStorage,
    http.Client? client,
  })  : baseUrl = _normalizeBaseUrl(baseUrl ?? Env.baseUrl),
        secureStorage = secureStorage ?? const FlutterSecureStorage(),
        client = client ?? http.Client();

  static String _normalizeBaseUrl(String url) {
    // quita slash final si lo hay para evitar 'https://.../ /path' con doble slash
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  Future<Map<String, String>> _headers() async {
    final seed = await secureStorage.read(key: 'API_SEED') ?? '';
    return {
      'Content-Type': 'application/json',
      'X-API-KEY': seed,
    };
  }

  Uri _makeUri(String path) {
    // limpia path de slash inicial para concatenar correctamente
    final cleanedPath = path.startsWith('/') ? path.substring(1) : path;
    return Uri.parse('$baseUrl/$cleanedPath');
  }

  Future<http.Response> get(String path) async {
    final h = await _headers();
    final uri = _makeUri(path);
    return client.get(uri, headers: h);
  }

  Future<http.Response> post(String path, Map body) async {
    final h = await _headers();
    final uri = _makeUri(path);
    return client.post(uri, headers: h, body: jsonEncode(body));
  }

  // agregar put, patch, delete, uploadFile (multipart) si es necesario...
}

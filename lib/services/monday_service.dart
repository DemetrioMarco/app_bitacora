import 'dart:async';
import 'dart:convert';

import 'package:app_bitacora/constants/env.dart';
import 'package:app_bitacora/utils/monday_exception.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class MondayService {
  MondayService._();
  static final MondayService instance = MondayService._();

  static const String _endpoint = Env.mondayUrl;

  // Timeouts CORRECTOS
  static const Duration _queryTimeout = Duration(seconds: 30);
  static const Duration _mutationTimeout = Duration(seconds: 45);
  static const Duration _fileTimeout = Duration(seconds: 120);

  // Lock para serializar uploads (CRÍTICO)
  static Completer<void> _uploadLock = Completer<void>()..complete();

  // =============================
  // HTTP HELPERS
  // =============================

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': Env.mondayToken,
      };

  http.Client _newClient() => http.Client();

  void _checkResponse(http.Response response) {
    if (response.statusCode == 429) {
       throw MondayRateLimitException();
    }

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }

    final payload = jsonDecode(response.body);
    if (payload is Map && payload.containsKey('errors')) {
      throw Exception('GraphQL errors: ${payload['errors']}');
    }
  }

  // =============================
  // QUERIES
  // =============================

  Future<List<Map<String, String>>> fetchItemsByTurnoAndOperador({
    required String turno,
    required String operador,
    int boardId = 18391680104,
  }) async {
    final query =
        _buildQuery(boardId: boardId, turno: turno, operador: operador);

    final client = _newClient();
    try {
      final response = await client
          .post(
            Uri.parse(_endpoint),
            headers: _headers,
            body: jsonEncode({'query': query}),
          )
          .timeout(_queryTimeout);

      _checkResponse(response);

      final payload = jsonDecode(response.body);
      final boards = payload['data']?['boards'] as List<dynamic>? ?? [];
      if (boards.isEmpty) return [];

      final items =
          boards[0]['items_page']?['items'] as List<dynamic>? ?? [];

      return items.map<Map<String, String>>((i) {
        final item = i as Map<String, dynamic>;
        final cvs = item['column_values'] as List<dynamic>? ?? [];

        final date = cvs
                .firstWhere((cv) => cv['id'] == 'date', orElse: () => {})['text']
                ?.toString() ??
            '';

        final equipoId = cvs
                .firstWhere(
                    (cv) => cv['id'] == 'lookup_mkyg2wyy',
                    orElse: () => {})['display_value']
                ?.toString() ??
            '';

        return {
          'itemId': item['id']?.toString() ?? '',
          'date': date,
          'equipoId': equipoId,
        };
      }).toList();
    } finally {
      client.close();
    }
  }

  // =============================
  // MUTATIONS
  // =============================

  Future<String> changeItemStatus({
    required dynamic itemId,
    required String status,
    int boardId = 18391680104,
    String columnId = 'status',
  }) async {
    final mutation = '''
      mutation {
        change_simple_column_value(
          board_id: $boardId
          item_id: ${itemId.toString()}
          column_id: "$columnId"
          value: "$status"
        ) { id }
      }
    ''';

    final client = _newClient();
    try {
      final response = await client
          .post(
            Uri.parse(_endpoint),
            headers: _headers,
            body: jsonEncode({'query': mutation}),
          )
          .timeout(_mutationTimeout);

      _checkResponse(response);

      return jsonDecode(response.body)['data']
              ['change_simple_column_value']['id']
          .toString();
    } finally {
      client.close();
    }
  }

  Future<String> crearUpdate({
    required dynamic itemId,
    required String body,
  }) async {
    final mutation = '''
      mutation {
        create_update(
          item_id: ${itemId.toString()}
          body: "${_escapeGraphQLString(body)}"
        ) { id }
      }
    ''';

    final client = _newClient();
    try {
      final response = await client
          .post(
            Uri.parse(_endpoint),
            headers: _headers,
            body: jsonEncode({'query': mutation}),
          )
          .timeout(_mutationTimeout);

      _checkResponse(response);

      return jsonDecode(response.body)['data']['create_update']['id']
          .toString();
    } finally {
      client.close();
    }
  }

  // =============================
  // FILE UPLOAD (SERIALIZADO)
  // =============================

  Future<String> uploadFileToUpdate({
    required dynamic updateId,
    required String file,
  }) async {
    await _uploadLock.future;
    final completer = Completer<void>();
    _uploadLock = completer;

    try {
      final request =
          http.MultipartRequest('POST', Uri.parse('$_endpoint/file'));

      request.headers['Authorization'] = Env.mondayToken;
      request.fields['query'] =
          'mutation (\$file: File!) { add_file_to_update(update_id: ${updateId.toString()}, file: \$file) { id } }';

      request.files
          .add(await http.MultipartFile.fromPath('variables[file]', file));

      final streamed =
          await request.send().timeout(_fileTimeout);

      final response = await http.Response.fromStream(streamed);

      _checkResponse(response);

      return jsonDecode(response.body)['data']['add_file_to_update']['id']
          .toString();
    } finally {
      completer.complete();
    }
  }

  // =============================
  // FLOW PRINCIPAL
  // =============================

  Future<String?> cerrarTareaYAdjuntarPdf({
    required dynamic itemId,
    required String updateBody,
    required String fotoPath,
    required String pdfFile,
    required String nameFile,
  }) async {
    try {
      final updateId =
          await crearUpdate(itemId: itemId, body: updateBody);

      final pdfId =
          await uploadFileToUpdate(updateId: updateId, file: pdfFile);

      if (fotoPath.trim().isNotEmpty) {
        await uploadFileToUpdate(updateId: updateId, file: fotoPath);
      }

      await changeItemStatus(itemId: itemId, status: 'Listo');
      return pdfId;
    } catch (e, st) {
      if (kDebugMode) {
        print('Error al enviar update: $e\n$st');
      }
      rethrow;
    }
  }

  // =============================
  // HELPERS
  // =============================

  String _buildQuery({
    required int boardId,
    required String turno,
    required String operador,
  }) {
    final operadorJson = jsonEncode([operador]);
    final statusJson = jsonEncode(['Programada']);

    return '''
      query {
        boards(ids: [$boardId]) {
          items_page(
            query_params: {
              rules: [
                { column_id: "color_mkyg7x46", compare_value: $operadorJson, operator: contains_terms },
                { column_id: "status", compare_value: $statusJson, operator: contains_terms }
              ]
            }
          ) {
            items {
              id
              column_values {
                id
                text
                ... on MirrorValue { display_value }
              }
            }
          }
        }
      }
    ''';
  }

  String _escapeGraphQLString(String input) {
    return input
        .replaceAll(r'\', r'\\')
        .replaceAll('"', r'\"')
        .replaceAll('\n', r'\n');
  }
}

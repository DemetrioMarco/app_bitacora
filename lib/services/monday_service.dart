import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app_bitacora/constants/env.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class MondayService {
  final http.Client _client;
  MondayService._(this._client);
  static final MondayService instance = MondayService._(http.Client());

  static const _endpoint = Env.mondayUrl;
  static const Duration _queryTimeout = Duration(seconds: 30);
  static const Duration _mutationTimeout = Duration(seconds: 45);
  static const Duration _fileTimeout = Duration(seconds: 120);


  factory MondayService({http.Client? client}) =>
      MondayService._(client ?? http.Client());

  Future<List<Map<String, dynamic>>> fetchItemsByTurnoAndOperador(
      {required String turno,
      required String operador,
      int boardId = 18391680104}) async {
    final query =
        _buildQuery(boardId: boardId, turno: turno, operador: operador);

    final uri = Uri.parse(_endpoint);
    final body = jsonEncode({'query': query});

    http.Response response;

    debugPrint('POST Monday -> $uri');
    debugPrint('Timeout -> $_queryTimeout'); 

    try {
      response = await _client
          .post(uri,
              headers: {
                'Content-Type': 'application/json',
                'Authorization': Env.mondayToken,
              },
              body: body)
          .timeout(_queryTimeout);
    } on SocketException catch (e) {
      throw Exception('Network error: ${e.message}');
    } on TimeoutException {
      throw Exception('Request timed out after ${_queryTimeout.inSeconds}s');
    } catch (e) {
      throw Exception('Request error: $e');
    }

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }

    Map<String, dynamic> payload;
    try {
      payload = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Invalid JSON response: $e');
    }

    if (payload.containsKey('errors')) {
      throw Exception('GraphQL errors: ${payload['errors']}');
    }

    final boards = payload['data']?['boards'] as List<dynamic>?;
    if (boards == null || boards.isEmpty) return [];

    final items = boards[0]['items_page']?['items'] as List<dynamic>? ?? [];

    // Devuelve cada item como Map con id y column_values (sin modelos adicionales)
    return items.map<Map<String, String>>((i) {
      final item = i as Map<String, dynamic>;
      final cvs = item['column_values'] as List<dynamic>? ?? [];

      // Buscar date
      final dateVal = cvs.firstWhere(
            (cv) => cv['id'] == 'date',
            orElse: () => {},
          )['text'] ??
          '';

      // Buscar equipoId desde display_value
      final lookupVal = cvs.firstWhere(
            (cv) => cv['id'] == 'lookup_mkyg2wyy',
            orElse: () => {},
          )['display_value'] ??
          '';

      return {
        'equipoId': lookupVal,
        'itemId': item['id']?.toString() ?? '',
        'date': dateVal,
      };
    }).toList();
  }

  String _buildQuery({
    required int boardId,
    required String turno,
    required String operador,
  }) {
    // Usamos jsonEncode para formar correctamente el array de compare_value
    final turnoJson = jsonEncode([turno]);
    final operadorJson = jsonEncode([operador]);
    final statusJson = jsonEncode(['Programada']);

    return '''
      query {
        boards(ids: [$boardId]) {
          items_page(
            query_params: {
              rules: [
            #    { column_id: "color_mkyggdbs", compare_value: $turnoJson, operator: contains_terms },   este es el filtro por turno que no he habilitado 
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
                ... on MirrorValue {
                  display_value
                }
              }
            }
          }
        }
      }
    ''';
  }

  Future<String> changeItemStatus({
    required dynamic itemId,
    required String status,
    int boardId = 18391680104,
    String columnId = 'status',
  }) async {
    final idStr = itemId.toString();

    final mutation = '''
      mutation {
        change_simple_column_value(
          board_id: $boardId
          item_id: $idStr
          column_id: "$columnId"
          value: "$status"
        ) {
          id
        }
      }
    ''';

    final uri = Uri.parse(_endpoint);
    final body = jsonEncode({'query': mutation});

    http.Response response;
    try {
      response = await _client
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': Env.mondayToken,
            },
            body: body,
          )
          .timeout(_mutationTimeout);
    } on SocketException catch (e) {
      debugPrint('SOCKET ERROR: ${e.osError}');
      throw Exception('Network error: ${e.message}');
    } on TimeoutException {
      throw Exception('Request timed out after ${_mutationTimeout.inSeconds}s');
    } catch (e) {
      throw Exception('Request error: $e');
    }

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }

    final Map<String, dynamic> payload;
    try {
      payload = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Invalid JSON response: $e');
    }

    if (payload.containsKey('errors')) {
      throw Exception('GraphQL errors: ${payload['errors']}');
    }

    final data = payload['data'] as Map<String, dynamic>?;
    final changed =
        data?['change_simple_column_value'] as Map<String, dynamic>?;
    final changedId = changed?['id']?.toString();
    if (changedId == null) {
      throw Exception('Unexpected response: no id returned.');
    }

    return changedId;
  }

  Future<String?> cerrarTareaYAdjuntarPdf({
    required dynamic itemId,
    required String updateBody,
    required String fotoPath,
    required String pdfFile,
    required String nameFile,
  }) async {
    try {
      final updateId = await MondayService.instance
          .crearUpdate(itemId: itemId, body: updateBody);
    

      final fileId = await MondayService.instance
          .uploadFileToUpdate(updateId: updateId, file: pdfFile);

      if (fileId.isEmpty) return null;

      if(fotoPath.trim().isNotEmpty){
        final fotoFileId = await MondayService.instance.uploadFileToUpdate(updateId: updateId, file: fotoPath);

        if(fotoFileId.isEmpty) return null;
      }
      
      if(fileId.isNotEmpty){
        await MondayService.instance.changeItemStatus(itemId: itemId, status: "Listo");
        return fileId;
      }
    } catch (e) {
      if(kDebugMode) print('Error en proceso: $e');
      rethrow;
    }
    return null;
  }

  /// Crea un update en un item y devuelve el id del update (como String).
  /// - itemId: id del item (String o int)
  /// - body: texto del update
  Future<String> crearUpdate({
    required dynamic itemId,
    required String body,
  }) async {
    final idStr = itemId.toString();

    final mutation = '''
      mutation {
        create_update(
          item_id: $idStr
          body: "${_escapeGraphQLString(body)}"
        ) {
          id
        }
      }
    ''';

    final uri = Uri.parse(_endpoint);
    final resp = await _client
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': Env.mondayToken,
          },
          body: jsonEncode({'query': mutation}),
        )
        .timeout(_mutationTimeout);

    if (resp.statusCode != 200) {
      throw Exception('HTTP ${resp.statusCode}: ${resp.body}');
    }

    final Map<String, dynamic> payload =
        jsonDecode(resp.body) as Map<String, dynamic>;

    if (payload.containsKey('errors')) {
      throw Exception('GraphQL errors: ${payload['errors']}');
    }

    final data = payload['data'] as Map<String, dynamic>?;
    final created = data?['create_update'] as Map<String, dynamic>?;
    final updateId = created?['id']?.toString();
    if (updateId == null) {
      throw Exception('Unexpected response: no update id returned');
    }

    return updateId;
  }


  /// - file: instancia File (dart:io) del PDF a subir
  Future<String> uploadFileToUpdate({
    required dynamic updateId,
    required String file
  }) async {
    final updateIdStr = updateId.toString();

    final uri = Uri.parse('$_endpoint/file');
    final request = http.MultipartRequest('POST', uri);

    // Headers
    request.headers['Authorization'] = Env.mondayToken;

    request.fields['query'] = 'mutation (\$file: File!) { add_file_to_update(update_id: $updateIdStr, file: \$file) { id } }';

    request.files.add(
      await http.MultipartFile.fromPath(
        'variables[file]', 
        file
      ),
    );
    

    // Enviar request
    final streamedResponse = await request.send().timeout(_fileTimeout);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }

    final Map<String, dynamic> payload =
        jsonDecode(response.body) as Map<String, dynamic>;
    if (payload.containsKey('errors')) {
      throw Exception('GraphQL errors: ${payload['errors']}');
    }

    final data = payload['data'] as Map<String, dynamic>?;
    final added = data?['add_file_to_update'] as Map<String, dynamic>?;
    final addedId = added?['id']?.toString();
    if (addedId == null) {
      // Dependiendo de la respuesta, puede devolver otra estructura; devolvemos el body completo si no hay id.
      throw Exception(
          'Unexpected response when uploading file: ${response.body}');
    }

    return addedId;
  }

  /// Helper para escapar caracteres especiales dentro de strings que insertamos inline en la query
  String _escapeGraphQLString(String input) {
    return input
        .replaceAll(r'\', r'\\')
        .replaceAll('"', r'\"')
        .replaceAll('\n', r'\n');
  }

  void dispose() {
    _client.close();
  }
}

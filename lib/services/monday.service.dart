import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app_bitacora/constants/env.dart';
import 'package:http/http.dart' as http;

class MondayService {
  final http.Client _client;
  MondayService._(this._client);
  static final MondayService instance = MondayService._(http.Client());

  static const _endpoint = Env.mondayUrl;
  static const Duration _timeout = Duration(seconds: 15);

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

    try {
      response = await _client
          .post(uri,
              headers: {
                'Content-Type': 'application/json',
                'Authorization': Env.mondayToken,
              },
              body: body)
          .timeout(_timeout);
    } on SocketException catch (e) {
      throw Exception('Network error: ${e.message}');
    } on TimeoutException {
      throw Exception('Request timed out after ${_timeout.inSeconds}s');
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
            #    { column_id: "color_mkyggdbs", compare_value: $turnoJson, operator: contains_terms },
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
          .timeout(_timeout);
    } on SocketException catch (e) {
      throw Exception('Network error: ${e.message}');
    } on TimeoutException {
      throw Exception('Request timed out after ${_timeout.inSeconds}s');
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

  Future<void> cerrarTareaYAdjuntarPdf({
    required dynamic itemId,
    required String updateBody,
    required File pdfFile,
  }) async {
    try {
      final updateId = await MondayService.instance
          .crearUpdate(itemId: itemId, body: updateBody);
      print('Update creado: $updateId');

      final fileId = await MondayService.instance
          .uploadFileToUpdate(updateId: updateId, file: pdfFile);
      print('Archivo subido, id: $fileId');
    } catch (e) {
      print('Error en proceso: $e');
      rethrow;
    }
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
        .timeout(_timeout);

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
    if (updateId == null)
      throw Exception('Unexpected response: no update id returned');

    return updateId;
  }

  /// Sube un archivo (p. ej. PDF) al update indicado. Devuelve el id del archivo o del attachment según la respuesta.
  /// - updateId: id del update donde se agregará el archivo (String o int)
  /// - file: instancia File (dart:io) del PDF a subir
  Future<String> uploadFileToUpdate({
    required dynamic updateId,
    required File file,
    String fileFieldName = '0', // clave en el map multipart
  }) async {
    final updateIdStr = updateId.toString();

    // Construimos la operación GraphQL con una variable para el archivo
    // Observa: algunos endpoints usan "File" o "Upload" como tipo; usamos "File!" (compat con monday).
    final operations = jsonEncode({
      'query':
          'mutation (\$file: File!) { add_file_to_update(update_id: $updateIdStr, file: \$file) { id } }',
      'variables': {'file': null},
    });

    // map: qué parte del multipart corresponde al archivo
    final mapPart = jsonEncode({
      fileFieldName: ['variables.file']
    });

    final uri = Uri.parse('$_endpoint/file');
    final request = http.MultipartRequest('POST', uri);
    // Headers
    request.headers['Authorization'] = Env.mondayToken;
    // NOTA: MultipartRequest pone su propio Content-Type

    // Campos 'operations' y 'map' según GraphQL multipart spec
    request.fields['operations'] = operations;
    request.fields['map'] = mapPart;

    // Añadimos el archivo. Usamos basename del path para nombre del archivo en la subida.
    final fileStream = http.ByteStream(file.openRead());
    final fileLength = await file.length();
    final filename = file.path.split(Platform.pathSeparator).last;

    final multipartFile = http.MultipartFile(
        fileFieldName, fileStream, fileLength,
        filename: filename);
    request.files.add(multipartFile);

    // Enviar request
    final streamedResponse = await request.send().timeout(_timeout);
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

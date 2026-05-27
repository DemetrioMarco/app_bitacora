import 'dart:async';
import 'dart:convert';

import 'package:app_bitacora/constants/env.dart';
import 'package:app_bitacora/data/controller/bitacora_api_controller.dart';
import 'package:app_bitacora/data/controller/elemento_controller.dart';
import 'package:app_bitacora/data/controller/equipo_api_controller.dart';
import 'package:app_bitacora/data/controller/equipo_elemento_controller.dart';
import 'package:app_bitacora/models/bitacora_api.dart';
import 'package:app_bitacora/models/elemento.dart';
import 'package:app_bitacora/models/equipo_api.dart';
import 'package:app_bitacora/models/equipo_elemento.dart';
import 'package:app_bitacora/services/auth_service.dart';
import 'package:app_bitacora/services/board_config_service.dart';
import 'package:app_bitacora/services/navigator_service.dart';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class TaskServiceException implements Exception {
  final String message;
  final int? statusCode;

  TaskServiceException(this.message, {this.statusCode});

  @override
  String toString() => statusCode != null
      ? 'TaskServiceException: $message (Status: $statusCode)'
      : 'TaskServiceException: $message';
}

class TaskService {
  TaskService._();
  static final TaskService instance = TaskService._();

  BitacoraAPIController get _bitacoraController => BitacoraAPIController();
  EquipoAPIController get _equipoController => EquipoAPIController();
  ElementoController get _elementoController => ElementoController();
  EquipoElementoController get _relacionController => EquipoElementoController();

  static const String _baseUrl = '${Env.apiBaseUrl}${Env.tareasPath}';
  static const String _evidencia = '${Env.apiBaseUrl}${Env.evidenciaPath}';
  static const Duration _queryTimeout = Duration(seconds: 30);

  Future<Map<String, String>> _buildHeaders() async {
    final token = await AuthService.instance.getAccessToken();
    if (token == null || token.isEmpty) {
      await AuthService.instance.logout();
      NavigatorService.navigateToLogin();
      throw TaskServiceException('No hay token de autenticación disponible.');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> _authorizedGet(Uri uri) async {
    final client = http.Client();
    try {
      var response = await client
          .get(uri, headers: await _buildHeaders())
          .timeout(_queryTimeout);

      if (kDebugMode) print('****************** _authorizedGet Response: ${response.statusCode}');

      if (response.statusCode == 403) {
        final newToken = await AuthService.instance.refresh();
        if (newToken == null) {
          throw TaskServiceException('Sesión expirada.', statusCode: 401);
        }
        response = await client
            .get(uri, headers: await _buildHeaders())
            .timeout(_queryTimeout);
      }
      return response;
    } finally {
      client.close();
    }
  }

  void _checkResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      if (kDebugMode) {
        print('HTTP Error: ${response.statusCode} - ${response.body}');
      }
      throw TaskServiceException(
        'Error en la solicitud: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }

  Future<Map<String, dynamic>> fetchTareasMovil() async {
    try {
      final uri = Uri.parse('$_baseUrl/tareas/movil');
      if (kDebugMode) print('Requesting: $uri');

      final response = await _authorizedGet(uri);
      _checkResponse(response);

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;

      // Guardar boardId
      int? boardId;
      if (decoded.containsKey('boardId') && decoded['boardId'] != null) {
        boardId = decoded['boardId'] as int;
        await BoardConfigService.instance.saveBoardId(boardId);
        if (kDebugMode) print('BoardId guardado: $boardId');
      }

      // Guardar bitácoras localmente desde las tareas
      await _saveBitacorasFromTareas(decoded);

      // Guardar equipos localmente
      await _saveEquiposFromResponse(decoded);

      // Guardar elementos localmente
      await _saveElementosFromResponse(decoded);

      // Guardar relaciones localmente
      await _saveRelacionesFromResponse(decoded);

      // Confirmación al servidor
      if (boardId != null && decoded['tareas'] != null) {
        await _confirmarTareas(boardId, decoded['tareas'] as List<dynamic>);
      }

      return decoded;
    } on TimeoutException {
      throw TaskServiceException(
          'Tiempo de espera agotado al conectar con el servidor.');
    } on http.ClientException catch (e) {
      throw TaskServiceException('Error de red: ${e.message}');
    } on TaskServiceException {
      rethrow;
    } catch (e, stack) {
      if (kDebugMode) {
        print('Error en fetchTareasMovil: $e');
        print(stack);
      }
      throw TaskServiceException('Error inesperado al obtener tareas: $e');
    }
  }

  Future<void> _saveBitacorasFromTareas(Map<String, dynamic> decoded) async {
    final tareas = decoded['tareas'] as List<dynamic>? ?? [];
    if (kDebugMode) print('*********** Tareas filtradas: =====>  $tareas\n');

    if (tareas.isEmpty) return;

    // Traer bitácoras ya guardadas para evitar duplicados por itemMonday
    final existentes = await _bitacoraController.getAllBitacorasLocal();

    final itemsExistentes = existentes.map((b) => b.itemMonday).toSet();
    if (kDebugMode) print('ItemId guardado: $itemsExistentes');

    for (final tarea in tareas) {
      final map = tarea as Map<String, dynamic>;

      final itemMonday = int.tryParse(map['id'].toString());
      final name = map['name'] as String?;
      final equipoId = int.tryParse(map['equipoId'].toString());
      final fechaStr = map['fecha'] as String?;

      if (itemMonday == null || name == null || equipoId == null || fechaStr == null) {
        if (kDebugMode) print('Tarea con datos inválidos, se omite: $map');
        continue;
      }

      if (itemsExistentes.contains(itemMonday)) {
        if (kDebugMode) print('Bitácora ya existe para itemMonday: $itemMonday');
        continue;
      }

      final bitacora = BitacoraAPI(
        nombre: name,
        equipoId: equipoId,
        itemMonday: itemMonday,
        fecha: DateTime.parse(fechaStr),
      );

      await _bitacoraController.saveBitacoraLocal(bitacora);
      if (kDebugMode)print('Bitácora guardada: itemMonday=$itemMonday, equipoId=$equipoId');
    }
  }

  Future<void> _saveEquiposFromResponse(Map<String, dynamic> decoded) async {
    final equipos = decoded['equipos'] as List<dynamic>? ?? [];
    if (kDebugMode) print('*********** Equipos recibidos: =====>  $equipos\n');

    if (equipos.isEmpty) return;

    // Traer equipos ya guardados para evitar duplicados por ID
    final existentes = await _equipoController.getAllEquiposLocal();
    final idsExistentes = existentes.map((e) => e.id).toSet();

    if (kDebugMode) print('IDs de equipos guardados: $idsExistentes');

    for (final equipoData in equipos) {
      final map = equipoData as Map<String, dynamic>;

      final equipoId = int.tryParse(map['id'].toString());

      if (equipoId == null) {
        if (kDebugMode) print('Equipo con ID inválido, se omite: $map');
        continue;
      }

      if (idsExistentes.contains(equipoId)) {
        if (kDebugMode) print('Equipo ya existe para ID: $equipoId');
        continue;
      }

      final equipo = EquipoAPI.fromMap(map);

      await _equipoController.saveEquipoLocal(equipo);
      if (kDebugMode)print('Equipo guardado: ID=$equipoId, nombre=${equipo.nombre}');
    }
  }

  Future<void> _saveElementosFromResponse(Map<String, dynamic> decoded) async {
    final elementosJson = decoded['elementos'] as List<dynamic>? ?? [];
    if (kDebugMode)print('*********** Elementos recibidos: =====>  $elementosJson\n');

    if (elementosJson.isEmpty) return;

    // Obtener los que ya existen para no duplicar
    final existentes = await _elementoController.getAllElementosLocal();
    final idsExistentes = existentes.map((e) => e.id).toSet();

    for (final data in elementosJson) {
      final map = data as Map<String, dynamic>;
      final id = int.tryParse(map['id'].toString());

      if (id == null) continue;

      if (idsExistentes.contains(id)) {
        if (kDebugMode) print('Elemento ya existe: ID=$id');
        continue;
      }

      final elemento = Elemento.fromMap(map);
      await _elementoController.saveElementoLocal(elemento);

      if (kDebugMode)print('Elemento guardado: ID=$id, nombre=${elemento.nombre}');
    }
  }

  Future<void> _saveRelacionesFromResponse(Map<String, dynamic> decoded) async {
    final relacionesJson = decoded['relaciones'] as List<dynamic>? ?? [];
    if (kDebugMode)print('*********** Relaciones recibidas: =====>  $relacionesJson\n');

    if (relacionesJson.isEmpty) return;

    // Obtener relaciones actuales para evitar duplicados del par (equipo_id, elemento_id)
    final existentes = await _relacionController.getAllRelacionesLocal();

    // Creamos un Set de strings con formato "equipoId-elementoId"
    final paresExistentes =
        existentes.map((r) => '${r.equipoId}-${r.elementoId}').toSet();

    for (final data in relacionesJson) {
      final map = data as Map<String, dynamic>;

      // Mapeo manual porque el JSON usa camelCase (equipoId) y el modelo snake_case (equipo_id)
      final int? eId = int.tryParse(map['equipoId'].toString());
      final int? elId = int.tryParse(map['elementoId'].toString());
      final int? orden = int.tryParse(map['orden'].toString());

      if (eId == null || elId == null) continue;

      // Verificar si el par ya existe
      if (paresExistentes.contains('$eId-$elId')) {
        if (kDebugMode)print('Relación ya existe: Equipo $eId - Elemento $elId');
        continue;
      }

      final relacion = EquipoElemento(
        equipoId: eId,
        elementoId: elId,
        orden: orden ?? 0,
      );

      await _relacionController.saveRelacionLocal(relacion);
      if (kDebugMode)print('Relación guardada: Equipo $eId <-> Elemento $elId');
    }
  }

  Future<void> _confirmarTareas(int boardId, List<dynamic> tareas) async {
    if (tareas.isEmpty) return;

    final url =
        Uri.parse('${Env.apiBaseUrl}${Env.tareasPath}/tareas/confirmar');

    // Extraemos y convertimos los IDs a int, ya que el JSON los trae como String
    final List<int> itemIds = tareas
        .map((t) => int.tryParse(t['id'].toString()))
        .whereType<int>() // Filtra nulos si el parseo falla
        .toList();

    final body = jsonEncode({
      "boardId": boardId.toString(), // Lo mandamos como String según tu ejemplo
      "itemIds": itemIds,
    });

    final client = http.Client();
    try {
      if (kDebugMode)print('Enviando confirmación a: $url con ${itemIds.length} tareas');

      var response = await client
          .post(url, headers: await _buildHeaders(), body: body)
          .timeout(_queryTimeout);

      // Manejo de refresh token (igual que en tu _authorizedGet)
      if (response.statusCode == 401) {
        final newToken = await AuthService.instance.refresh();
        if (newToken != null) {
          response = await client
              .post(url, headers: await _buildHeaders(), body: body)
              .timeout(_queryTimeout);
        }
      }

      _checkResponse(response);

      if (kDebugMode) {
        print('Confirmación procesada por el servidor: ${response.body}');
      }
    } finally {
      client.close();
    }
  }

  Future<bool> uploadTareaArchivos({
    required String itemId,
    required String pdfPath,
    required String photoPath,
  }) async {
    final url = Uri.parse('$_evidencia/upload/$itemId');
    if (kDebugMode) print('URL de subidasbida... $url');
    // Definimos una función interna para crear la petición, ya que si el token expira (401)
    // debemos recrear el MultipartRequest desde cero (no se puede reutilizar el stream).
    Future<http.MultipartRequest> createRequest() async {
      final request = http.MultipartRequest('POST', url);

      // Obtenemos los headers de auth (usamos los existentes del servicio)
      final headers = await _buildHeaders();
      // Quitamos Content-Type manual porque MultipartRequest lo genera automáticamente con el boundary
      headers.remove('Content-Type');
      request.headers.addAll(headers);

      // Adjuntamos los archivos
      request.files.add(await http.MultipartFile.fromPath('pdf', pdfPath));
      request.files.add(await http.MultipartFile.fromPath('photo', photoPath));
      //request.files.add(await http.MultipartFile.fromPath('photo', pdfPath));

      if (kDebugMode) print('Request... $request');
      return request;
    }

    try {
      if (kDebugMode) print('Subiendo archivos para la tarea $itemId...');

      var request = await createRequest();
      var streamedResponse =
          await request.send().timeout(const Duration(minutes: 2));
      var response = await http.Response.fromStream(streamedResponse);

      // Manejo de Refresh Token (401)
      if (response.statusCode == 401) {
        final newToken = await AuthService.instance.refresh();
        if (newToken != null) {
          if (kDebugMode) print('Token refrescado, reintentando subida...');
          request = await createRequest();
          streamedResponse = await request.send().timeout(const Duration(minutes: 2));
          response = await http.Response.fromStream(streamedResponse);
        }
      }

      _checkResponse(response);
      if (kDebugMode) {
        print('Archivos subidos exitosamente: ${response.body}');
      }
      return true;

    } on Exception catch (e) {
      if (kDebugMode) print('Error en uploadTareaArchivos: $e');
      throw TaskServiceException('Error al subir archivos de la tarea: $e');
    }
  }

  Future<bool> updateTaskStatus({
  required String boardId,
  required String itemId,
  String status = 'Listo',
}) async {
  final url = Uri.parse('$_evidencia/updateTask/$boardId/$itemId/$status');

  Future<http.Response> makeRequest() async {
    final headers = await _buildHeaders();
    return await http.put(url, headers: headers).timeout(const Duration(seconds: 30));
  }

  try {
    var response = await makeRequest();

    // Manejo de Refresh Token (401)
    if (response.statusCode == 401) {
      final newToken = await AuthService.instance.refresh();
      if (newToken != null) {
        response = await makeRequest();
      }
    }

    _checkResponse(response);
    return true;
  } catch (e) {
    if (kDebugMode) print('Error en updateTaskStatus: $e');
    throw TaskServiceException('Error al actualizar estado de la tarea: $e');
  }
}

}

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
  String toString() => message;
}

class TaskService {
  TaskService._();
  static final TaskService instance = TaskService._();

  final BitacoraAPIController _bitacoraController = BitacoraAPIController();
  final EquipoAPIController _equipoController = EquipoAPIController();
  final ElementoController _elementoController = ElementoController();
  final EquipoElementoController _relacionController = EquipoElementoController();

  static const String _baseUrl = '${Env.apiBaseUrl}${Env.tareasPath}';
  static const String _evidencia = '${Env.apiBaseUrl}${Env.evidenciaPath}';
  static const Duration _timeout = Duration(seconds: 30);

  // --- Helpers Privados ---

  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.instance.getAccessToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Ejecuta una petición y si falla por 401/403, refresca el token e intenta de nuevo.
  Future<http.Response> _sendWithRetry(Future<http.Response> Function() action) async {
    var response = await action().timeout(_timeout);

    if (response.statusCode == 401 || response.statusCode == 403) {
      if (kDebugMode) print('Token expirado, intentando refresh...');
      
      final newToken = await AuthService.instance.refresh();
      if (newToken != null) {
        response = await action().timeout(_timeout);
      } else {
        await AuthService.instance.logout();
        NavigatorService.navigateToLogin();
        throw TaskServiceException('Sesión expirada permanentemente.', statusCode: 401);
      }
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw TaskServiceException('Error del servidor: ${response.statusCode}', statusCode: response.statusCode);
    }
    
    return response;
  }

  // --- Métodos Públicos ---

  Future<Map<String, dynamic>> fetchTareasMovil() async {
    try {
      final uri = Uri.parse('$_baseUrl/tareas/movil');
      
      final response = await _sendWithRetry(() async {
        return await http.get(uri, headers: await _getHeaders());
      });

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;

      // 1. Guardar boardId
      if (decoded.containsKey('boardId') && decoded['boardId'] != null) {
        await BoardConfigService.instance.saveBoardId(decoded['boardId'] as int);
      }

      // 2. Persistencia Local
      await _saveBitacorasFromTareas(decoded);
      await _saveEquiposFromResponse(decoded);
      await _saveElementosFromResponse(decoded);
      await _saveRelacionesFromResponse(decoded);

      // 3. Confirmar recepción al servidor
      if (decoded['boardId'] != null && decoded['tareas'] != null) {
        await _confirmarTareas(decoded['boardId'] as int, decoded['tareas'] as List<dynamic>);
      }

      return decoded;
    } catch (e) {
      if (kDebugMode) print('Error en fetchTareasMovil: $e');
      throw TaskServiceException(e.toString());
    }
  }

  Future<bool> uploadTareaArchivos({
    required String itemId,
    required String pdfPath,
    required String photoPath,
  }) async {
    final url = Uri.parse('$_evidencia/upload/$itemId');

    try {
      final response = await _sendWithRetry(() async {
        final request = http.MultipartRequest('POST', url);
        final headers = await _getHeaders();
        headers.remove('Content-Type'); // Multipart lo genera solo
        request.headers.addAll(headers);
        
        request.files.add(await http.MultipartFile.fromPath('pdf', pdfPath));
        request.files.add(await http.MultipartFile.fromPath('photo', photoPath));
        
        final streamed = await request.send().timeout(const Duration(minutes: 2));
        return await http.Response.fromStream(streamed);
      });

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      throw TaskServiceException('Error al subir archivos: $e');
    }
  }

  Future<bool> updateTaskStatus({
    required String boardId,
    required String itemId,
    String status = 'Listo',
  }) async {
    final url = Uri.parse('$_evidencia/updateTask/$boardId/$itemId/$status');

    try {
      final response = await _sendWithRetry(() async {
        return await http.put(url, headers: await _getHeaders());
      });
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      throw TaskServiceException('Error al actualizar estado: $e');
    }
  }

  // --- Métodos de Persistencia Local (Se mantienen igual) ---

  Future<void> _confirmarTareas(int boardId, List<dynamic> tareas) async {
    if (tareas.isEmpty) return;
    final url = Uri.parse('$_baseUrl/tareas/confirmar');

    final List<int> itemIds = tareas
        .map((t) => int.tryParse(t['id'].toString()))
        .whereType<int>()
        .toList();

    await _sendWithRetry(() async {
      return await http.post(
        url,
        headers: await _getHeaders(),
        body: jsonEncode({"boardId": boardId.toString(), "itemIds": itemIds}),
      );
    });
  }

  Future<void> _saveBitacorasFromTareas(Map<String, dynamic> decoded) async {
    final tareas = decoded['tareas'] as List<dynamic>? ?? [];
    if (tareas.isEmpty) return;

    final existentes = await _bitacoraController.getAllBitacorasLocal();
    final itemsExistentes = existentes.map((b) => b.itemMonday).toSet();

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
    final existentes = await _equipoController.getAllEquiposLocal();
    final idsExistentes = existentes.map((e) => e.id).toSet();

    for (final eq in equipos) {
      final id = int.tryParse(eq['id'].toString());
      if (id == null || idsExistentes.contains(id)) continue;
      await _equipoController.saveEquipoLocal(EquipoAPI.fromMap(eq));
    }
  }

  Future<void> _saveElementosFromResponse(Map<String, dynamic> decoded) async {
    final elementos = decoded['elementos'] as List<dynamic>? ?? [];
    final existentes = await _elementoController.getAllElementosLocal();
    final idsExistentes = existentes.map((e) => e.id).toSet();

    for (final el in elementos) {
      final id = int.tryParse(el['id'].toString());
      if (id == null || idsExistentes.contains(id)) continue;
      await _elementoController.saveElementoLocal(Elemento.fromMap(el));
    }
  }

  Future<void> _saveRelacionesFromResponse(Map<String, dynamic> decoded) async {
    final relaciones = decoded['relaciones'] as List<dynamic>? ?? [];
    final existentes = await _relacionController.getAllRelacionesLocal();
    final paresExistentes = existentes.map((r) => '${r.equipoId}-${r.elementoId}').toSet();

    for (final rel in relaciones) {
      final eId = int.tryParse(rel['equipoId'].toString());
      final elId = int.tryParse(rel['elementoId'].toString());
      if (eId == null || elId == null || paresExistentes.contains('$eId-$elId')) continue;

      await _relacionController.saveRelacionLocal(EquipoElemento(
        equipoId: eId,
        elementoId: elId,
        orden: int.tryParse(rel['orden'].toString()) ?? 0,
      ));
    }
  }
}

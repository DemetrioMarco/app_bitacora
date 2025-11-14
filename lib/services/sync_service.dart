// lib/services/sync_service.dart (fragmento a añadir/ajustar)

import 'dart:convert';
import '../data/repositories/cat_repo.dart';
import '../models/area.dart';
import '../models/tipo_limpieza.dart';
import 'api_service.dart';

class SyncService {
  final ApiService api;
  final CatalogRepo repo;

  // lista de catálogos que manejamos
  final List<String> catalogList = [
    'area',
    'equipo',
    'frecuencia',
    'tipo_limpieza',
  ];

  SyncService({required this.api, required this.repo});

  // llamada inicial desde main / inicializador
  Future<void> initializeCatalogsIfNeeded() async {
    final isEmpty = await repo.catalogVersionIsEmpty();
    if (isEmpty) {
      // primer arranque: crear tablas si hiciera falta y sembrar
    //  await repo.createCatalogTablesIfNeeded();
      await seedCatalogsFirstTime();
    } else {
      // sincronización normal
      await syncCatalogsIfNeeded();
    }
  }

  // si es la primera vez: descargar y colocar version = "1"
  Future<void> seedCatalogsFirstTime() async {
    final now = DateTime.now().toIso8601String();

    // Ejemplo concreto para cada catálogo -> puedes generalizar si quieres
    // 1) area
    try {
      final respA = await api.get('/areas');
      if (respA.statusCode == 200) {
        final text = utf8.decode(respA.bodyBytes);
        final list = jsonDecode(text) as List;
        final areas = list.map((e) => Area.fromJson(Map<String, dynamic>.from(e))).toList();
        if (areas.isNotEmpty) await repo.upsertAreasList(areas);
      }
      await repo.setLocalVersion('area', '1', updatedAt: now);
    } catch (e) {
      // log / manejar error según convenga
    }

    // 2) equipo
    try {
      final respE = await api.get('/equipos');
      if (respE.statusCode == 200) {
        final text = utf8.decode(respE.bodyBytes);
        final list = jsonDecode(text) as List;
        // parse a tu modelo Equipo: Equipo.fromJson(...)
        // final equipos = list.map((e) => Equipo.fromJson(...)).toList();
        // await repo.upsertEquiposList(equipos);
      }
      await repo.setLocalVersion('equipo', '1', updatedAt: now);
    } catch (e) {}

    // 3) frecuencia
    try {
      final respF = await api.get('/frecuencias');
      if (respF.statusCode == 200) {
        final text = utf8.decode(respF.bodyBytes);
        final list = jsonDecode(text) as List;
        // parse y upsert
        // await repo.upsertFrecuenciaList(parsedList);
      }
      await repo.setLocalVersion('frecuencia', '1', updatedAt: now);
    } catch (e) {}

    // 4) tipo_limpieza (ejemplo detallado porque pediste específicamente)
    try {
      final respT = await api.get('/tipos_limpieza');
      if (respT.statusCode == 200) {
        final text = utf8.decode(respT.bodyBytes);
        final list = jsonDecode(text) as List;
        final tipos = list.map((e) => TipoLimpieza.fromJson(Map<String, dynamic>.from(e))).toList();
        if (tipos.isNotEmpty) await repo.upsertTiposLimpiezaList(tipos);
      }
      await repo.setLocalVersion('tipo_limpieza', '1', updatedAt: now);
    } catch (e) {}

    // fin seed
  }

  // flujo normal para revisar versiones y actualizar si cambian
  Future<void> syncCatalogsIfNeeded() async {
    // obtener listado de versiones remotas una sola vez si quieres optimizar
    // pero aquí usamos helper por tabla (puedes cachear)
    for (final table in catalogList) {
      final localV = await repo.getLocalVersion(table);
      final remoteV = await _fetchRemoteVersion(table);

      if (remoteV == null) {
        // fallback: descargar datos y calcular version (por fecha o hash)
        await _downloadAndUpsertTable(table);
        continue;
      }

      if (localV == remoteV) {
        // misma versión -> skip
        continue;
      }

      // versiones distintas -> actualizar
      await _downloadAndUpsertTable(table, remoteVersion: remoteV);
    }
  }

  Future<void> _downloadAndUpsertTable(String tableName, {String? remoteVersion}) async {
    final now = DateTime.now().toIso8601String();
    try {
      switch (tableName) {
        case 'area':
          final respA = await api.get('/areas');
          if (respA.statusCode == 200) {
            final text = utf8.decode(respA.bodyBytes);
            final list = jsonDecode(text) as List;
            final areas = list.map((e) => Area.fromJson(Map<String, dynamic>.from(e))).toList();
            if (areas.isNotEmpty) await repo.upsertAreasList(areas);
          }
          break;
        case 'tipo_limpieza':
          final respT = await api.get('/tipos_limpieza');
          if (respT.statusCode == 200) {
            final text = utf8.decode(respT.bodyBytes);
            final list = jsonDecode(text) as List;
            final tipos = list.map((e) => TipoLimpieza.fromJson(Map<String, dynamic>.from(e))).toList();
            if (tipos.isNotEmpty) await repo.upsertTiposLimpiezaList(tipos);
          }
          break;
        case 'equipo':
          final respE = await api.get('/equipos');
          if (respE.statusCode == 200) {
            final text = utf8.decode(respE.bodyBytes);
            final list = jsonDecode(text) as List;
            // parse y upsert equipos
          }
          break;
        case 'frecuencia':
          final respF = await api.get('/frecuencias');
          if (respF.statusCode == 200) {
            final text = utf8.decode(respF.bodyBytes);
            final list = jsonDecode(text) as List;
            // parse y upsert frecuencias
          }
          break;
        default:
          // no soportado
          break;
      }

      // actualizar catalogo_version con remoteVersion (si no se pasó, se podría calcular)
      final verToStore = remoteVersion ?? DateTime.now().toIso8601String();
      await repo.setLocalVersion(tableName, verToStore, updatedAt: now);
    } catch (e) {
      // manejar/logging
    }
  }

  // obtiene la versión remota desde /catalogos_version (puede devolver null)
  Future<String?> _fetchRemoteVersion(String tableName) async {
    try {
      final resp = await api.get('/catalogos_version');
      if (resp.statusCode == 200) {
        final text = utf8.decode(resp.bodyBytes);
        final data = jsonDecode(text);
        if (data is List) {
          final rows = List<Map<String, dynamic>>.from(data);
          final row = rows.firstWhere(
            (m) => (m['table_name'] ?? m['tabla'] ?? '') == tableName,
            orElse: () => <String, dynamic>{},
          );
          if (row.isNotEmpty) {
            return (row['version']?.toString() ?? row['updated_at']?.toString());
          }
        } else if (data is Map) {
          return data[tableName]?.toString();
        }
      }
    } catch (_) {
      // ignore
    }
    return null;
  }

  String md5Hex(String input) {
    // mantén tu impl o usa package:crypto para md5 real
    return input.hashCode.toString();
  }
}

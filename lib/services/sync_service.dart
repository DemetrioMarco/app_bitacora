// lib/services/sync_service.dart (fragmento)
import 'dart:convert';
import '../data/repositories/cat_repo.dart';
import '../models/area.dart';
import 'api_service.dart';

class SyncService {
  final ApiService api;
  final CatalogRepo repo;

  SyncService({required this.api, required this.repo});

  Future<void> syncAreasIfNeeded() async {
    const tableName = 'areas';
    final localVersion = await repo.getLocalVersion(tableName);

    // 1) intentar obtener versión desde endpoint /api.php/catalogos_version
    String? remoteVersion;
    try {
      final resp = await api.get('/catalogos_version');
      if (resp.statusCode == 200) {
        final text = utf8.decode(resp.bodyBytes);
        final data = jsonDecode(text);
        if (data is List) {
          // Convertir a lista tipada segura
          final rows = List<Map<String, dynamic>>.from(data);

          // Buscar entry para 'areas'
          final row = rows.firstWhere(
            (m) => (m['table_name'] ?? m['tabla'] ?? '') == tableName,
            orElse: () => <String, dynamic>{},
          );

            if (row.isNotEmpty) {
              remoteVersion = row['version']?.toString() ?? row['updated_at']?.toString();
            }
        } else if (data is Map) {
          // Tal vez endpoint retorno objeto con keys
          remoteVersion = data[tableName]?.toString();
        }
      }
    } catch (_) {
      // ignora si no existe endpoint, caeremos a estrategia 2
    }

    // 2) si no conseguimos remoteVersion, descargar lista y calcular max fecha_actualizacion
    List<Area> remoteAreas = [];
    if (remoteVersion == null) {
      final resp = await api.get('/areas'); // ajusta path si tu endpoint es otro
      if (resp.statusCode != 200) throw Exception('No se pudo descargar áreas: ${resp.statusCode}');
      final text = utf8.decode(resp.bodyBytes);
      final list = jsonDecode(text) as List;
      remoteAreas = list.map((e) => Area.fromJson(Map<String, dynamic>.from(e))).toList();
      // computar versión como max fecha_actualizacion
      final latest = remoteAreas.map((a) => a.fechaActualizacion).whereType<DateTime>().fold<DateTime?>(null, (prev, cur) {
        if (prev == null) return cur;
        return cur.isAfter(prev) ? cur : prev;
      });
      if (latest != null) {
        remoteVersion = latest.toIso8601String();
      } else {
        // fallback: usar hash del payload
        remoteVersion = md5Hex(jsonEncode(list));
      }
    } else {
      // si ya tenemos remoteVersion obtenido, solo descargar areas si cambia
      if (localVersion == remoteVersion) {
        // no hay cambio -> salir
        return;
      } else {
        final resp = await api.get('/areas');
        if (resp.statusCode != 200) throw Exception('No se pudo descargar áreas: ${resp.statusCode}');
        final text = utf8.decode(resp.bodyBytes);
        final list = jsonDecode(text) as List;
        remoteAreas = list.map((e) => Area.fromJson(Map<String, dynamic>.from(e))).toList();
      }
    }

    // si llegamos aquí: actualizar local y registrar nueva versión
    if (remoteAreas.isNotEmpty) {
      await repo.upsertAreasList(remoteAreas);
    }
    await repo.setLocalVersion(
      tableName, 
      remoteVersion, 
      updatedAt: DateTime.now().toIso8601String());
  }


  String md5Hex(String input) {
    // implementación simple md5 si no tienes paquete crypto
    // preferible usar package:crypto
    // aquí sólo stub: return input.hashCode.toString();
    return input.hashCode.toString();
  }
}

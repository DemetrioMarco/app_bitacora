// lib/data/repositories/catalog_repo.dart
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../models/area.dart';
import '../local_db.dart';

class CatalogRepo {
  final LocalDB _localDb = LocalDB();

  Future<List<Area>> getAreas() async {
    final db = await _localDb.db;
    final rows = await db.query('areas', orderBy: 'nombre COLLATE NOCASE');
    return rows.map((r) {
      final raw = r['raw_json'] as String?;
      if (raw != null && raw.isNotEmpty) {
        // mantener consistencia con Area.fromJson
        return Area.fromJson(Map<String, dynamic>.from(jsonDecode(raw)));
      }
      return Area.fromJson({
        'id': r['id'],
        'nombre': r['nombre'],
        'activo': r['activo']?.toString(),
        'fecha_creacion': r['fecha_creacion'],
        'fecha_actualizacion': r['fecha_actualizacion'],
      });
    }).toList();
  }

  Future<void> upsertArea(Area area) async {
    final db = await _localDb.db;
    final raw = jsonEncode(area.toJson());
    await db.insert(
      'areas',
      {
        'id': area.id,
        'nombre': area.nombre,
        'activo': area.activo ? 1 : 0,
        'fecha_creacion': area.fechaCreacion.toIso8601String(),
        'fecha_actualizacion': area.fechaActualizacion.toIso8601String(),
        'raw_json': raw,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> upsertAreasList(List<Area> areas) async {
    final db = await _localDb.db;
    final batch = db.batch();
    for (final a in areas) {
      batch.insert(
        'areas',
        {
          'id': a.id,
          'nombre': a.nombre,
          'activo': a.activo ? 1 : 0,
          'fecha_creacion': a.fechaCreacion.toIso8601String(),
          'fecha_actualizacion': a.fechaActualizacion.toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<String?> getLocalVersion(String tableName) async {
    final db = await _localDb.db;
    final rows = await db.query('catalogos_version', where: 'table_name = ?', whereArgs: [tableName]);
    if (rows.isEmpty) return null;
    return rows.first['version'] as String?;
  }

  Future<void> setLocalVersion(String tableName, String version, {String? updatedAt}) async {
    final db = await _localDb.db;
    await db.insert(
      'catalogos_version',
      {'table_name': tableName, 'version': version, 'updated_at': updatedAt},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}

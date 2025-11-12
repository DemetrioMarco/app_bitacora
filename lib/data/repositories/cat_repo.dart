// lib/data/repositories/cat_repo.dart (fragmento)
import 'package:sqflite/sqflite.dart';
import '../../models/area.dart';
import '../../models/tipo_limpieza.dart';

class CatalogRepo {
  final Database db;

  CatalogRepo(this.db);

  Future<bool> catalogVersionIsEmpty() async {
    final res = await db.rawQuery('SELECT COUNT(1) AS c FROM catalogo_version');
    final c = Sqflite.firstIntValue(res) ?? 0;
    return c == 0;
  }

  Future<void> createCatalogTablesIfNeeded() async {
    // Si ya tienes SQL en otro lado, usa ese código. Aquí un ejemplo mínimo:
    await db.execute('''
      CREATE TABLE IF NOT EXISTS catalogo_version (
        table_name TEXT PRIMARY KEY,
        version TEXT,
        updated_at TEXT
      )
    ''');

    // solo ejemplo de tablas; si ya existen tablas concretas, no sobrescribir
    await db.execute('''
      CREATE TABLE IF NOT EXISTS areas (
        id INTEGER PRIMARY KEY,
        nombre TEXT,
        fecha_actualizacion TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS tipos_limpieza (
        id INTEGER PRIMARY KEY,
        nombre TEXT,
        fecha_creacion TEXT
      )
    ''');

    // crea tablas equipos y frecuencias según tu modelo...
  }

  Future<String?> getLocalVersion(String tableName) async {
    final rows = await db.query(
      'catalogo_version',
      columns: ['version'],
      where: 'table_name = ?',
      whereArgs: [tableName],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['version']?.toString();
  }

  Future<void> setLocalVersion(String tableName, String version, {required String updatedAt}) async {
    await db.insert(
      'catalogo_version',
      {'table_name': tableName, 'version': version, 'updated_at': updatedAt},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> upsertAreasList(List<Area> list) async {
    final batch = db.batch();
    for (final a in list) {
      batch.insert('areas', a.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<void> upsertTiposLimpiezaList(List<TipoLimpieza> list) async {
    final batch = db.batch();
    for (final t in list) {
      batch.insert('tipos_limpieza', t.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  // Implementa upsertEquiposList y upsertFrecuenciaList según tus modelos...
}

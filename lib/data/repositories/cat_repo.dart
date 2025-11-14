// lib/data/repositories/cat_repo.dart (fragmento)
import 'package:app_bitacora/models/equipo_elemento.dart';
import 'package:sqflite/sqflite.dart';
import '../../models/area.dart';
import '../../models/elemento.dart';
import '../../models/equipo.dart';
import '../../models/tipo_limpieza.dart';

class CatalogRepo {
  final Database db;

  CatalogRepo(this.db);

  Future<bool> catalogVersionIsEmpty() async {
    final res = await db.rawQuery('SELECT COUNT(1) AS c FROM catalogo_version');
    final c = Sqflite.firstIntValue(res) ?? 0;
    return c == 0;
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

  Future<List<Equipo>>getAllEquipos() async {
    final row = await db.query('equipos');
    return row.map((e) => Equipo.fromMap(e)).toList();
  }

  Future<Elemento>getElemento(int id) async {
    final rows = await db.query(
      'elemento',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1
      );
    return Elemento.fromMap(rows.first);
  }

  Future<void> insertEquipo (Equipo equipo) async {
    final map = Map<String, Object?>.from(equipo.toMap());
    await db.insert('equipos', map);
  }

  Future<void> insertElemento(Elemento e) async {
    final map = Map<String, Object?>.from(e.toMap());
    await db.insert('elementos', map);
  }

  Future<void> insertEquipoElemento(EquipoElemento e) async {
    final map = Map<String, Object?>.from(e.toMap());
    await db.insert('equipo_elemento', map);
  }

  Future<List<EquipoElemento>> getChecklistByEquipo(int equipoId) async {
  final List<Map<String, dynamic>> maps = await db.query(
    'equipo_elemento',
    where: 'equipoId = ?',
    whereArgs: [equipoId],
    orderBy: 'orden ASC',
  );

  return maps.map((m) => EquipoElemento(
    equipoId: m['equipoId'] as int,
    elementoId: m['elementoId'] as int,
    orden: m['orden'] as int,
  )).toList();
}


}

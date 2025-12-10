import 'package:app_bitacora/models/bitacora.dart';
import 'package:app_bitacora/models/check_item.dart';
import 'package:app_bitacora/models/checklist_item.dart';
import 'package:app_bitacora/models/equipo_elemento.dart';
import 'package:app_bitacora/models/equipo_relacion.dart';
import 'package:app_bitacora/models/frecuencia.dart';
import 'package:app_bitacora/models/sub_area.dart';
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

  Future<List<CheckItem>> getCheckItem(int equipoId) async {
  final List<Map<String, dynamic>> rows = await db.rawQuery(
    '''
    SELECT  
      e.id,
      e.nombre AS nombre, 
      ee.orden AS orden
    FROM equipo_elemento ee 
    JOIN  elementos e 
      ON e.id = ee.elemento_id 
    WHERE ee.equipo_id = ?
    ORDER BY ee.orden ASC;
    ''',
    [equipoId]
  );

  return rows.map((e) => CheckItem(
    id: e['id'] as int, 
    title: e['nombre'] as String, 
    orden: e['orden'] as int
  )).toList();
 
}

Future<Bitacora?> getEquipoRelacion(int equipoId, DateTime fecha) async {
  final List<Map<String, dynamic>> rows = await db.rawQuery(
    '''
      SELECT 
	      e.nombre AS 'Equipo',
	      a.nombre AS 'Area',
	      sa.nombre AS 'Sub-area',
	      f.nombre AS 'Frecuencia',
	      tl.nombre AS 'Tipo Limpieza'
      FROM equipo_relacion er
	      JOIN equipos e ON er.equipo_id = e.id
	      JOIN areas a ON er.area_id = a.id
	      JOIN sub_area sa ON er.sub_area_id = sa.id 
	      JOIN frecuencia f ON er.frecuencia_id = f.id
	      JOIN tipos_limpieza tl ON er.tipo_limpieza_id = tl.id
      WHERE er.equipo_id = ?
      LIMIT 1;
    ''',
    [equipoId]
  );

  if(rows.isEmpty) return null;

  final row = rows.first;

  return Bitacora(
    fecha: fecha, 
    equipoId: equipoId, 
    equipo: row['Equipo'] as String? ?? '', 
    area: row['Area'] as String? ?? '',  
    linea: row['Sub-area'] as String? ?? '', 
    tipoLimpieza: row['Tipo Limpieza'] as String? ?? '', 
    frecuencia: row['Frecuencia'] as String? ?? '', 
  );
}

  Future<void> insertCheckList(ChecklistItem items) async {
    final map = Map<String, Object?>.from(items.toMap());
    await db.insert('checklist_items', map);
  }

  Future<void> insertArea(Area area) async {
    final map = Map<String, Object?>.from(area.toJson());
    await db.insert('areas', map);
  }

  Future<Area> getArea(int id) async {
    final rows = await db.query(
      'areas',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1
      );
    return Area.fromJson(rows.first);
  }

  Future<void> insertSubArea(SubArea subarea) async {
    final map = Map<String, Object?>.from(subarea.toJson());
    await db.insert('sub_area', map);
  }

  Future<SubArea> getSubArea(int id) async {
    final rows = await db.query(
      'sub_area',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1
      );
    return SubArea.fromJson(rows.first);
  }

  Future<void> insertTipoLimpieza(TipoLimpieza tipo) async {
    final map = Map<String, Object?>.from(tipo.toJson());
    await db.insert('tipos_limpieza', map);
  }

  Future<TipoLimpieza> getTipoLimpieza(int id) async {
    final rows = await db.query(
      'tipos_limpieza',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1
      );
    return TipoLimpieza.fromJson(rows.first);
  }

  Future<void> insertFrecuencia(Frecuencia frecuencia) async {
    final map = Map<String, Object?>.from(frecuencia.toJson());
    await db.insert('frecuencia', map);
  }
  
  Future<void> insertEquipoRelacion( EquipoRelacion e) async {
    final map = Map<String, dynamic>.from(e.toMap());
    await db.insert('equipo_relacion', map);
  }

}

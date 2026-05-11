import 'package:app_bitacora/models/bitacora_api.dart';
import 'package:app_bitacora/models/check_item.dart';
import 'package:app_bitacora/models/checklist_item.dart';
import 'package:app_bitacora/models/firma.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

class BitacoraAPIRepo {
  final Database db;
  static const String _table =
      'bitacorasAPI'; // O el nombre de tu tabla para BitacoraAPI

  BitacoraAPIRepo(this.db);

  Future<BitacoraAPI> insert(BitacoraAPI bitacora) async {
    final map = Map<String, Object?>.from(bitacora.toMap());
    map.remove('id');
    final id = await db.insert(_table, map);
    return BitacoraAPI(
        id: id,
        equipoId: bitacora.equipoId,
        itemMonday: bitacora.itemMonday,
        fecha: bitacora.fecha);
  }

  Future<int> update(BitacoraAPI bitacora) async {
    if (bitacora.id == null) {
      throw ArgumentError('BitacoraAPI.id is required for update');
    }
    return await db.update(
      _table,
      bitacora.toMap(),
      where: 'id = ?',
      whereArgs: [bitacora.id],
    );
  }

  Future<List<BitacoraAPI>> getAll({String orderBy = 'fecha DESC'}) async {
    final rows = await db.query(_table, orderBy: orderBy);
    return rows.map((r) => BitacoraAPI.fromMap(r)).toList();
  }

  Future<BitacoraAPI?> getById(int id) async {
    final rows = await db.query(
      _table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return BitacoraAPI.fromMap(rows.first);
  }

  Future<int> delete(int id) async {
    return await db.delete(
      _table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<ChecklistItem>> getChecklistForBitacora(
      int bitacoraId, int equipoId) async {
    // 1. Intentar buscar si ya existen respuestas guardadas para esta bitácora
    final List<Map<String, dynamic>> res = await db.query(
      'checklists_bitacora', // Tu tabla de resultados
      where: 'bitacora_id = ?',
      whereArgs: [bitacoraId],
    );

    if (res.isNotEmpty) {
      return res.map((m) => ChecklistItem.fromMap(m)).toList();
    }

    // 2. Si no hay resultados, traer los elementos configurados para ese Equipo (Plantilla)
    // Aquí usamos el equipoId para saber qué debe llevar el checklist
    final List<Map<String, dynamic>> plantilla = await db.rawQuery('''
    SELECT e.id as elemento_id, e.nombre, e.descripcion
    FROM elementos e
    INNER JOIN equipo_elementos re ON e.id = re.elemento_id
    WHERE re.equipo_id = ?
  ''', [equipoId]);

    // Convertimos la plantilla en items vacíos para la UI
    return plantilla
        .map((p) => ChecklistItem(
              id: p['id'] as int,
              bitacoraId: bitacoraId,
              elementoId: p['elemento_id'] as int,
              titulo: p['titulo'] as String,
              checked: (p['checked'] as int) == 1,
              observacion: p['observacion'] as String? ?? '',
              orden: p['orden'] as int,
            ))
        .toList();
  }

  Future<List<ChecklistItem>> getChecklistItemForId(int bitacoraId) async {
    final List<Map<String, dynamic>> rows = await db.query('checklist_items',
        where: 'bitacora_id = ?', whereArgs: [bitacoraId], orderBy: 'orden');

    if (kDebugMode) print('*********** getChecklistItemForId: =====>  $rows\n');

    return rows.map((e) {
      return ChecklistItem(
        id: e['id'] as int,
        bitacoraId: e['bitacora_id'] as int,
        elementoId: e['elemento_id'] as int,
        titulo: e['titulo'] as String,
        checked: (e['checked'] as int) == 1,
        observacion: e['observacion'] as String? ?? '',
        orden: e['orden'] as int,
      );
    }).toList();
  }

  Future<Firma?> getSignatureByBitacoraId(int bitacoraId) async {
    final res = await db.query(
      'signatures',
      where: 'bitacora_id = ?',
      whereArgs: [bitacoraId],
    );

    if (res.isEmpty) return null;

    return Firma.fromMap(res.first);
  }

  Future<List<CheckItem>> getCheckItemAPI(int equipoId) async {

    final List<Map<String, dynamic>> rows = await db.rawQuery('''
    SELECT  
      e.id,
      e.nombre AS nombre, 
      ee.orden AS orden
    FROM equipo_elemento_API ee 
    JOIN  elementosAPI e 
      ON e.id = ee.elemento_id 
    WHERE ee.equipo_id = ?
    ORDER BY ee.orden ASC;
    ''', [equipoId]);

if (kDebugMode) print('*********** getCheckItemAPI: =====>  $rows\n');
    return rows
        .map((e) => CheckItem(
            id: e['id'] as int,
            title: e['nombre'] as String,
            orden: e['orden'] as int))
        .toList();
  }

  Future<void> insertCheckList(ChecklistItem items) async {
    final map = Map<String, Object?>.from(items.toMap());
    await db.insert('checklist_items', map);
  }

}

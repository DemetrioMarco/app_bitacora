import 'package:app_bitacora/models/bitacora.dart';
import 'package:app_bitacora/models/checklist_item.dart';
import 'package:app_bitacora/models/firma.dart';
import 'package:sqflite/sqflite.dart';

class BitacoraRepo {
  final Database db;
  static const String _table = 'bitacoras';

  BitacoraRepo(this.db);

  Future<Bitacora> insert(Bitacora bitacora) async {
    final map = Map<String, Object?>.from(bitacora.toMap());
    map.remove('id');
    final id = await db.insert(_table, map);
    return Bitacora(
        id: id,
        fecha: bitacora.fecha,
        area: bitacora.area,
        equipo: bitacora.equipo,
        equipoId: bitacora.equipoId,
        tipoLimpieza: bitacora.tipoLimpieza,
        frecuencia: bitacora.frecuencia,
        linea: bitacora.linea);
  }

  Future<int> update(Bitacora bitacora) async {
    final map = Map<String, Object?>.from(bitacora.toMap());
    final id = map['id'] as int?;
    if (id == null) {
      throw ArgumentError('Bitacora.id is required for update');
    }
    map.remove('id');
    return await db.update(
      _table,
      map,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Bitacora>> getAll({String orderBy = 'fecha ASC'}) async {
    final rows = await db.query(_table, orderBy: orderBy);
    return rows.map((r) => Bitacora.fromMap(r)).toList();
  }

  Future<Bitacora> getForId(int id) async {
    final rows = await db.query(
      _table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return Bitacora.fromMap(rows.first);
  }

  Future<List<ChecklistItem>> getChecklistItemForId(int bitacoraId) async {
    final List<Map<String, dynamic>> rows = await db.query('checklist_items',
        where: 'bitacora_id = ?', whereArgs: [bitacoraId], orderBy: 'orden');

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

  Future<int> insertSignature(Firma s) async {
    final map = Map<String, Object?>.from(s.toMap());
    map.remove('id');
    return await db.insert('signatures', map);
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

  Future<int> updateSignature(Firma s) async {
    final map = Map<String, Object?>.from(s.toMap());
    final id = s.id;
    if (id == null) throw ArgumentError('Signature id is null for update');
    return await db.update('signatures', map, where: 'id = ?', whereArgs: [id]);
  }


  Future<int> validateSignature(int bitacoraId) async {
    final result = await db.rawQuery(
      '''
        SELECT COUNT(*) AS total FROM signatures WHERE bitacora_id = ? AND firma_verifico <> '';
      ''',
      [bitacoraId],
    );
    return result.first['total'] as int;
  }

  // Eliminar Bitacora
  Future<int> deleteBitacora( int bitacoraId) async {
    return await db.delete(
      'bitacoras',
      where: 'id = ?',
      whereArgs: [bitacoraId]
      );
  }
  
  Future<int> deleteSignature(int bitacoraId) async {
    return await db.delete(
      'signatures', 
      where: 'bitacora_id = ?', 
      whereArgs: [bitacoraId]
    );
  }

  Future<int> deleteChecklisItem(int bitacoraId) async {
     return await db.delete(
      'checklist_items',
      where: 'bitacora_id = ?',
      whereArgs: [bitacoraId]
      );
  }
}

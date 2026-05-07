import 'package:app_bitacora/models/bitacora_api.dart';
import 'package:sqflite/sqflite.dart';

class BitacoraAPIRepo {
  final Database db;
  static const String _table = 'bitacorasAPI'; // O el nombre de tu tabla para BitacoraAPI

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

  
}

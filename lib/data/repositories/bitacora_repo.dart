import 'package:app_bitacora/models/bitacora.dart';
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
      tipoLimpieza: bitacora.tipoLimpieza, 
      frecuencia: bitacora.frecuencia, 
      linea: bitacora.linea
    );
  }

  Future<int> update(Bitacora bitacora) async {
    final map = Map<String, Object?>.from(bitacora.toMap());
    final id = map['id'] as int?;
    if( id == null ){
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

}
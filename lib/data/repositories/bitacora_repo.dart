import 'package:app_bitacora/models/bitacora.dart';
import 'package:app_bitacora/models/signature.dart';
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

  Future<int> insertSignature(Signature s) async {
    final map = Map<String, Object?>.from(s.toMap());
    map.remove('id');
    return await db.insert('signatures', map);
  }

  Future<Signature?> getSignatureByBitacoraId(int bitacoraId)async{
    final res = await db.query(
      'signatures',
      where: 'bitacora_id = ?',
      whereArgs: [bitacoraId],
      limit: 1,
    );

    if(res.isEmpty) return null;
    return Signature.fromMap(res.first);
  }

  Future<List<Signature>> getSignaturesByBitacoraId(int bitacoraId)async{
    final res = await db.query(
      'signatures',
      where: 'bitacora_id = ?',
      whereArgs: [bitacoraId]
    );
    return res.map((r) => Signature.fromMap(r)).toList();
  }

  Future<int> updateSignature(Signature s)async{
    final map = Map<String, Object?>.from(s.toMap());
    final id = s.id;
    if(id == null) throw ArgumentError('Signature id is null for update');
    return await db.update(
      'signatures', 
      map, 
      where: 'id = ?',
      whereArgs: [id] );
  }

  Future<int> deleteSignature(int id) async {
    return await db.delete(
      'signatures',
      where: 'id = ?',
      whereArgs: [id]
    );
  }

}
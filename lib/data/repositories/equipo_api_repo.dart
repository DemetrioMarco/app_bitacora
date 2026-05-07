import 'package:sqflite/sqflite.dart';
import 'package:app_bitacora/models/equipo_api.dart';

class EquipoAPIRepo {
  final Database db;
  static const String _table = 'equiposAPI'; 

  EquipoAPIRepo(this.db);

  Future<void> insert(EquipoAPI equipo) async {
    await db.insert(
      _table,
      equipo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> update(EquipoAPI equipo) async {
    return await db.update(
      _table,
      equipo.toMap(),
      where: 'id = ?',
      whereArgs: [equipo.id],
    );
  }

  Future<List<EquipoAPI>> getAll() async {
    final rows = await db.query(_table);
    return rows.map((r) => EquipoAPI.fromMap(r)).toList();
  }

  Future<EquipoAPI?> getById(int id) async {
    final rows = await db.query(
      _table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return EquipoAPI.fromMap(rows.first);
  }

  Future<int> delete(int id) async {
    return await db.delete(
      _table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

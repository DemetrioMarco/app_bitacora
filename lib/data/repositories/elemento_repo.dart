import 'package:sqflite/sqflite.dart';
import 'package:app_bitacora/models/elemento.dart'; // Ajusta la ruta

class ElementoRepo {
  final Database db;
  static const String _table = 'elementosAPI';

  ElementoRepo(this.db);

  Future<void> insert(Elemento elemento) async {
    await db.insert(
      _table,
      elemento.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Elemento>> getAll() async {
    final rows = await db.query(_table);
    return rows.map((r) => Elemento.fromMap(r)).toList();
  }

  Future<int> update(Elemento elemento) async {
    return await db.update(
      _table,
      elemento.toMap(),
      where: 'id = ?',
      whereArgs: [elemento.id],
    );
  }

  Future<int> delete(int id) async {
    return await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }
}

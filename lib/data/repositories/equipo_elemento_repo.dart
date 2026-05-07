import 'package:sqflite/sqflite.dart';
import 'package:app_bitacora/models/equipo_elemento.dart';

class EquipoElementoRepo {
  final Database db;
  static const String _table = 'equipo_elemento_API';

  EquipoElementoRepo(this.db);

  Future<void> insert(EquipoElemento relacion) async {
    await db.insert(
      _table,
      relacion.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace, // Reemplaza si el par equipo-elemento ya existe
    );
  }

  Future<List<EquipoElemento>> getAll() async {
    final rows = await db.query(_table);
    return rows.map((r) => EquipoElemento.fromMap(r)).toList();
  }

  // Útil para limpiar relaciones viejas si fuera necesario
  Future<void> deleteAll() async {
    await db.delete(_table);
  }
}

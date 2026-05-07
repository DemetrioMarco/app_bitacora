import 'package:app_bitacora/data/local_db.dart';
import 'package:app_bitacora/data/repositories/equipo_elemento_repo.dart';
import 'package:app_bitacora/models/equipo_elemento.dart';

class EquipoElementoController {
  Future<void> saveRelacionLocal(EquipoElemento relacion) async {
    final db = await LocalDB.instance.db;
    final repo = EquipoElementoRepo(db);
    await repo.insert(relacion);
  }

  Future<List<EquipoElemento>> getAllRelacionesLocal() async {
    final db = await LocalDB.instance.db;
    final repo = EquipoElementoRepo(db);
    return await repo.getAll();
  }
}

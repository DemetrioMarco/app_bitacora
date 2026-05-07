import 'package:app_bitacora/data/local_db.dart';
import 'package:app_bitacora/data/repositories/equipo_api_repo.dart';
import 'package:app_bitacora/models/equipo_api.dart';

class EquipoAPIController {
  
  Future<void> saveEquipoLocal(EquipoAPI equipo) async {
    final db = await LocalDB.instance.db;
    final repo = EquipoAPIRepo(db);
    return await repo.insert(equipo);
  }

  Future<int> updateEquipoLocal(EquipoAPI equipo) async {
    final db = await LocalDB.instance.db;
    final repo = EquipoAPIRepo(db);
    return await repo.update(equipo);
  }

  Future<List<EquipoAPI>> getAllEquiposLocal() async {
    final db = await LocalDB.instance.db;
    final repo = EquipoAPIRepo(db);
    return await repo.getAll();
  }

  Future<EquipoAPI?> getEquipoLocalById(int id) async {
    final db = await LocalDB.instance.db;
    final repo = EquipoAPIRepo(db);
    return await repo.getById(id);
  }

  Future<int> deleteEquipoLocal(int id) async {
    final db = await LocalDB.instance.db;
    final repo = EquipoAPIRepo(db);
    return await repo.delete(id);
  }
}

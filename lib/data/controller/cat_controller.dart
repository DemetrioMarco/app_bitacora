
import '../../models/model.dart';


import '../local_db.dart';
import '../repositories/cat_repo.dart';


class CatalogController {
  late final CatalogRepo repo;

  CatalogController(){
    LocalDB.instance.db.then((db)=> repo = CatalogRepo(db));
  }

  Future<List<Equipo>> obtenerEquipos() async {
    final db = await LocalDB.instance.db;
    final repo = CatalogRepo(db);
    return await repo.getAllEquipos();
  }

  Future<Elemento> obtenerElemento(int id) async {
    final db = await LocalDB.instance.db;
    final repo = CatalogRepo(db);
    return await repo.getElemento(id);
  }

  Future<List<CheckItem>> obtenerCheckItem(int equipoId) async {
    final db = await LocalDB.instance.db;
    final repo = CatalogRepo(db);
    return await repo.getCheckItem(equipoId);
  }

  Future<void>guardarChecklist(List<ChecklistItem> items) async {
    final db = await LocalDB.instance.db;
    final repo =  CatalogRepo(db);

    for(final item in items){
      await repo.insertCheckList(item);
    }
  }

  Future<Bitacora?> crearBitacora(int equipoId, DateTime fecha, String itemId) async {
    final db = await LocalDB.instance.db;
    final repo = CatalogRepo(db);
    return await repo.getEquipoRelacion(equipoId, fecha, itemId);
  }

}
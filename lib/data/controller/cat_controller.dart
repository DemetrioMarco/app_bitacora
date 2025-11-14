import '../local_db.dart';
import '../repositories/cat_repo.dart';
import '../../models/equipo.dart';
import '../../models/elemento.dart';

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
}
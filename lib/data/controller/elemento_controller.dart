import 'package:app_bitacora/data/local_db.dart';
import 'package:app_bitacora/data/repositories/elemento_repo.dart';
import 'package:app_bitacora/models/elemento.dart';

class ElementoController {
  Future<void> saveElementoLocal(Elemento elemento) async {
    final db = await LocalDB.instance.db;
    final repo = ElementoRepo(db);
    await repo.insert(elemento);
  }

  Future<List<Elemento>> getAllElementosLocal() async {
    final db = await LocalDB.instance.db;
    final repo = ElementoRepo(db);
    return await repo.getAll();
  }

  Future<int> updateElementoLocal(Elemento elemento) async {
    final db = await LocalDB.instance.db;
    final repo = ElementoRepo(db);
    return await repo.update(elemento);
  }

  Future<int> deleteElementoLocal(int id) async {
    final db = await LocalDB.instance.db;
    final repo = ElementoRepo(db);
    return await repo.delete(id);
  }
}

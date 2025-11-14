import '../../models/bitacora.dart';
import '../repositories/bitacora_repo.dart';
import '../local_db.dart';

class BitacoraController {
  late final BitacoraRepo repo;

  BitacoraController() {
    // Obtiene la conexión del singleton de la base de datos
    LocalDB.instance.db.then((db) => repo = BitacoraRepo(db));
  }

  Future<Bitacora> guardar(Bitacora b) async {
    final db = await LocalDB.instance.db;
    final repo = BitacoraRepo(db);
    return await repo.insert(b);
  }

  Future<List<Bitacora>> obtenerTodas() async {
    final db = await LocalDB.instance.db;
    final repo = BitacoraRepo(db);
    return await repo.getAll();
  }

  Future<Bitacora> obtenerBitacora(int id) async {
    final db = await LocalDB.instance.db;
    final repo = BitacoraRepo(db);
    return await repo.getForId(id);
  }
}

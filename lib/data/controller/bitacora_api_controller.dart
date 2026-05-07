import 'package:app_bitacora/data/local_db.dart';
import 'package:app_bitacora/data/repositories/bitacora_api_repo.dart';
import 'package:app_bitacora/models/bitacora_api.dart';

class BitacoraAPIController {
  

  Future<BitacoraAPI> saveBitacoraLocal(BitacoraAPI bitacora) async {
    final db = await LocalDB.instance.db;
    final repo = BitacoraAPIRepo(db);
    return await repo.insert(bitacora);
  }

  Future<int> updateBitacoraLocal(BitacoraAPI bitacora) async {
    final db = await LocalDB.instance.db;
    final repo = BitacoraAPIRepo(db);
    return await repo.update(bitacora);
  }

  Future<List<BitacoraAPI>> getAllBitacorasLocal() async {
    final db = await LocalDB.instance.db;
    final repo = BitacoraAPIRepo(db);
    return await repo.getAll();
    
  }

  Future<BitacoraAPI?> getBitacoraLocalById(int id) async {
    final db = await LocalDB.instance.db;
    final repo = BitacoraAPIRepo(db);
    return await repo.getById(id);
  }

  Future<int> deleteBitacoraLocal(int id) async {
    final db = await LocalDB.instance.db;
    final repo = BitacoraAPIRepo(db);
    return await repo.delete(id);
  }

  
}

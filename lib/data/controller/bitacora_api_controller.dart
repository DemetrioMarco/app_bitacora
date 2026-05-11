import 'package:app_bitacora/data/local_db.dart';
import 'package:app_bitacora/data/repositories/bitacora_api_repo.dart';
import 'package:app_bitacora/models/bitacora_api.dart';
import 'package:app_bitacora/models/check_item.dart';
import 'package:app_bitacora/models/checklist_item.dart';
import 'package:app_bitacora/models/firma.dart';
import 'package:flutter/foundation.dart';

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

  Future<List<ChecklistItem>> obtenerChecklist(int bitacoraId, int equipoId) async {
    final db = await LocalDB.instance.db;
    final repo = BitacoraAPIRepo(db); // Tu nuevo repo
    return await repo.getChecklistForBitacora(bitacoraId, equipoId);
  }

  Future<List<ChecklistItem>> obtenerChecklistItem(int bitacoraId)async{
    if (kDebugMode) print('*********** obtenerChecklistItem: =====>  $bitacoraId\n');
    final db = await LocalDB.instance.db;
    final repo = BitacoraAPIRepo(db);
    return repo.getChecklistItemForId(bitacoraId);
  }

  Future<Firma?> obtenerSignature(int bitacoraId)async{
    final db = await LocalDB.instance.db;
    final repo = BitacoraAPIRepo(db);
    return await repo.getSignatureByBitacoraId(bitacoraId);
  }

  Future<List<CheckItem>> obtenerCheckItemTemplate(int equipoId) async {
    if (kDebugMode) print('*********** obtenerCheckItemTemplate: =====>  $equipoId\n');
    final db = await LocalDB.instance.db;
    final repo = BitacoraAPIRepo(db); // Tu nuevo repo
    return await repo.getCheckItemAPI(equipoId);
  }

  Future<void> guardarChecklist(List<ChecklistItem> items)async{
    final db = await LocalDB.instance.db;
    final repo = BitacoraAPIRepo(db);

    for(final item in items){
      await repo.insertCheckList(item);
    }
  }
}

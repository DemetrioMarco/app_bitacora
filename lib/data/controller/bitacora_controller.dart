import '../../models/model.dart';
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

  Future<int> guardarFirma(Firma s) async {
    final db = await LocalDB.instance.db;
    final repo = BitacoraRepo(db);
    return await repo.insertSignature(s);
  }

  Future<int> agregarFirma(Firma s) async{
    final db = await LocalDB.instance.db;
    final repo = BitacoraRepo(db);
    return await repo.updateSignature(s);
  }

  Future<Firma?> obtenerSignature(int bitacoraId)async{
    final db = await LocalDB.instance.db;
    final repo = BitacoraRepo(db);
    return await repo.getSignatureByBitacoraId(bitacoraId);
  }

  Future<List<ChecklistItem>> obtenerChecklistItem(int bitacoraId)async{
    final db = await LocalDB.instance.db;
    final repo = BitacoraRepo(db);
    return repo.getChecklistItemForId(bitacoraId);
  }

  Future<bool> tieneSignature(int bitacoraId) async {
    final db = await LocalDB.instance.db;
    final repo = BitacoraRepo(db);
    final count = await repo.validateSignature(bitacoraId);
    return count > 0;
  }

  Future<bool> eliminarBitacora(int bitacoraId) async {
    try {
      final db = await LocalDB.instance.db;
      final repo = BitacoraRepo(db);
      int deleteBitacora = await repo.deleteBitacora(bitacoraId);
      int deleteSignature = await repo.deleteSignature(bitacoraId);
      int deleteCheckList = await repo.deleteChecklisItem(bitacoraId);
      final total = deleteBitacora + deleteSignature + deleteCheckList;

      return total > 0;
    } catch (e) {
      return false;
    }
  }

  Future<int> actualizarBitacora(Bitacora bitacora) async {
    final db = await LocalDB.instance.db;
    final repo = BitacoraRepo(db);
    return await repo.update(bitacora);
  }

  
}

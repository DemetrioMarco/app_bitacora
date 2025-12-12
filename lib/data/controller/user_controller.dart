import 'package:app_bitacora/data/local_db.dart';
import 'package:app_bitacora/data/repositories/user_repo.dart';
import 'package:app_bitacora/models/app_user.dart';

class UserController {
  late final UserRepo repo;

  UserController(){
    LocalDB.instance.db.then((db)=> repo = UserRepo(db));
  }

  Future<AppUser?> obtenerUsuario(String username, String pass)async {
    final db = await LocalDB.instance.db;
    final repo = UserRepo(db);
    return await repo.getUser(username, pass);
  }

}
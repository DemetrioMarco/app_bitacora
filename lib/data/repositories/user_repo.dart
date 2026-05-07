import 'package:app_bitacora/models/app_user.dart';
import 'package:sqflite/sqflite.dart';

class UserRepo {
  final Database db;

  UserRepo(this.db);

  Future<void> insertUser( AppUser user) async {
    final map = Map<String, dynamic>.from(user.toMap());
    await db.insert('user', map);
  }

  Future<AppUser?> getUser( String username, String pass) async {
    final rows = await db.query(
      'user',
      where: 'username = ? AND pass = ?',
      whereArgs: [username,pass],
      limit: 1
      );

    if(rows.isEmpty) return null;
    return AppUser.fromJson(rows.first);
  }
}
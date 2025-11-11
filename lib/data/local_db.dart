// lib/data/local_db.dart (debug helper)
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDB {
  static final LocalDB _instance = LocalDB._internal();
  factory LocalDB() => _instance;
  LocalDB._internal();

  static Database? _db;
  static const _dbName = 'saferfs.db';
  static const _dbVersion = 2;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final path = join(await getDatabasesPath(), _dbName);
    
    return openDatabase(path, version: _dbVersion, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  Future<void> _onCreate(Database db, int version) async {
    const sql1 = '''
      CREATE TABLE catalogos_version (
        table_name TEXT PRIMARY KEY,
        version TEXT NOT NULL,
        updated_at TEXT
      )
    ''';
    if (kDebugMode) {
      print('Executing onCreate SQL1:\n$sql1');
    }
    await db.execute(sql1);

    const sql2 = '''
      CREATE TABLE areas (
        id TEXT PRIMARY KEY,
        nombre TEXT,
        activo INTEGER,
        fecha_creacion TEXT,
        fecha_actualizacion TEXT
      )
    ''';
    if (kDebugMode) {
      print('Executing onCreate SQL2:\n$sql2');
    }
    await db.execute(sql2);


    await db.execute('''
    CREATE TABLE IF NOT EXISTS tipos_limpieza (
      id INTEGER PRIMARY KEY,
      nombre TEXT,
      activo INTEGER,
      fecha_creacion TEXT
    )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldV, int newV) async {
    if (kDebugMode) {
      print('onUpgrade oldV=$oldV newV=$newV');
    }
    if (oldV < 2 && newV >= 2) {
      // migración simple: recrear tabla (o puedes copiar columnas como te di antes)
      await db.execute('DROP TABLE IF EXISTS areas');
      const sql = '''
        CREATE TABLE areas (
          id TEXT PRIMARY KEY,
          nombre TEXT,
          activo INTEGER,
          fecha_creacion TEXT,
          fecha_actualizacion TEXT
        )
      ''';
      if (kDebugMode) {
        print('Executing onUpgrade SQL:\n$sql');
      }
      await db.execute(sql);
    }
  }

  Future<void> close() async {
    final database = await db;
    await database.close();
    _db = null;
  }
}

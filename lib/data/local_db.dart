import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDB {
  static final LocalDB instance = LocalDB._internal();
  factory LocalDB() => instance;
  LocalDB._internal();

  static Database? _db;
  static const _dbName = 'saferfs.db';
  static const _dbVersion = 1;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final path = join(await getDatabasesPath(), _dbName);

    if (kDebugMode) {
      print('Path:\n$path');
      deleteDatabase(path);
     // print('Elimando BD');
    }

    
    return openDatabase(path,
        version: _dbVersion, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  Future<void> _onCreate(Database db, int version) async {

    
    const sql1 = '''
      CREATE TABLE catalogos_version (
        table_name TEXT PRIMARY KEY,
        version TEXT NOT NULL,
        updated_at TEXT
      )
    ''';
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
    await db.execute(sql2);

    const sqlSubArea = '''
      CREATE TABLE sub_area (
        id TEXT PRIMARY KEY,
        nombre TEXT,
        activo INTEGER,
        fecha_creacion TEXT,
        fecha_actualizacion TEXT
      )
    ''';
    await db.execute(sqlSubArea);

    await db.execute('''
    CREATE TABLE IF NOT EXISTS tipos_limpieza (
      id INTEGER PRIMARY KEY,
      nombre TEXT,
      activo INTEGER,
      fecha_creacion TEXT
    )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS frecuencia(
        id INTEGER PRIMARY KEY,
        nombre TEXT
      )
    ''');

    const sqlBitacora = '''
      CREATE TABLE IF NOT EXISTS bitacoras (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        equipo_id INTEGER NOT NULL,
        equipo TEXT NOT NULL,
        fecha TEXT NOT NULL,
        area TEXT NOT NULL,
        linea TEXT NOT NULL,
        tipo_limpieza TEXT NOT NULL,
        frecuencia TEXT NOT NULL,
        item_monday TEXT NOT NULL
      )
    ''';
    await db.execute(sqlBitacora);

    const sqlEquipo = '''
      CREATE TABLE IF NOT EXISTS equipos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL UNIQUE
      )
    ''';
    await db.execute(sqlEquipo);

    await db.execute('''
      CREATE TABLE IF NOT EXISTS elementos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS equipo_elemento (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        equipo_id INTEGER NOT NULL,
        elemento_id INTEGER NOT NULL,
        orden INTEGER NOT NULL,
        UNIQUE(equipo_id, elemento_id),
        FOREIGN KEY (equipo_id) REFERENCES equipos(id) ON DELETE CASCADE,
        FOREIGN KEY (elemento_id) REFERENCES elementos(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS equipo_relacion (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        equipo_id INTEGER NOT NULL,
        area_id INTEGER NOT NULL,
        sub_area_id INTEGER NOT NULL,
        frecuencia_id INTEGER NOT NULL,
        tipo_limpieza_id INTEGER NOT NULL,
        UNIQUE(equipo_id, area_id, sub_area_id, frecuencia_id, tipo_limpieza_id),
        FOREIGN KEY (equipo_id) REFERENCES equipos(id) ON DELETE CASCADE,
        FOREIGN KEY (area_id) REFERENCES areas(id) ON DELETE CASCADE,
        FOREIGN KEY (sub_area_id) REFERENCES sub_area(id) ON DELETE CASCADE,
        FOREIGN KEY (frecuencia_id) REFERENCES frecuencia(id) ON DELETE CASCADE,
        FOREIGN KEY (tipo_limpieza_id) REFERENCES tipos_limpieza(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS checklist_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bitacora_id INTEGER NOT NULL,
        elemento_id INTEGER NOT NULL,
        titulo TEXT NOT NULL,
        checked INTEGER NOT NULL DEFAULT 0,
        observacion TEXT,
        orden INTEGER,
        FOREIGN KEY (bitacora_id) REFERENCES bitacoras(id) ON DELETE CASCADE,
        FOREIGN KEY (elemento_id) REFERENCES elementos(id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS signatures (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bitacora_id INTEGER NOT NULL,
        ejecuto TEXT,
        firma_ejecuto TEXT,
        verifico TEXT,
        firma_verifico TEXT,
        libero TEXT,
        firma_libero TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS user(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT,
        role TEXT,
        pass TEXT
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

import 'package:app_bitacora/data/local_db.dart';
import 'package:app_bitacora/data/repositories/cat_repo.dart';
import 'package:app_bitacora/models/equipo.dart';
import 'package:app_bitacora/models/equipo_elemento.dart';
import 'package:sqflite/sqflite.dart';

import '../models/elemento.dart';

class SeedService {

  static Future<void> seedIfNeeded() async {
    final db = await LocalDB.instance.db;
    final CatalogRepo repo = CatalogRepo(db);

    // comprobar si ya hay equipos
    final countEquipos = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM equipos')) ?? 0;

    if (countEquipos == 0){
      // Crear equipos en memoria
      final equipos = <Equipo>[
        Equipo(nombre: 'Cernidor Crem102'),
        Equipo(nombre: 'Concha DUC')
      ];

      // Insertar equipo
      for (final e in equipos) {
        await repo.insertEquipo(e);
      }
    }


    final countElementos = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM elementos')) ?? 0;

    if(countElementos == 0 ) {
      // Crear elementos
      final elementos = [
        Elemento(nombre: 'Banco de apoyo, escalones y/o plataforma'),
        Elemento(nombre: 'Barandales (plataforma lateral)'),
        Elemento(nombre: 'Bisagra'),
        Elemento(nombre: 'Bombas'),
        Elemento(nombre: 'Brazo mecánico'),
        Elemento(nombre: 'Chimenea'),
        Elemento(nombre: 'Cuerpo'),
        Elemento(nombre: 'Cuerpo (tanque lateral)'),
        Elemento(nombre: 'Cuerpo inferior'),
        Elemento(nombre: 'Cuerpo superior'),
        Elemento(nombre: 'Hoja'),
        Elemento(nombre: 'Magneto'),
        Elemento(nombre: 'Mangueras'),
        Elemento(nombre: 'Manija'),
        Elemento(nombre: 'Marco'),
        Elemento(nombre: 'Mirilla'),
        Elemento(nombre: 'Motor'),
        Elemento(nombre: 'Motor inferior'),
        Elemento(nombre: 'Motor superior'),
        Elemento(nombre: 'Panel de control'),
        Elemento(nombre: 'Parte superior (Tanque lateral)'),
        Elemento(nombre: 'Peldaños (plataforma lateral)'),
        Elemento(nombre: 'Perifería'),
        Elemento(nombre: 'Plataforma lateral'),
        Elemento(nombre: 'Silo'),
        Elemento(nombre: 'Soporte estructural'),
        Elemento(nombre: 'Tanque lateral'),
        Elemento(nombre: 'Tapa superior'),
        Elemento(nombre: 'Tolvas'),
        Elemento(nombre: 'Tuberia inferior'),
        Elemento(nombre: 'Tuberia superior'),
        Elemento(nombre: 'Tuberias'),
        Elemento(nombre: 'Tapa'),
      ];

      // insertar elemento
      for (final e in elementos){
        await repo.insertElemento(e);
      }

    }

    final countEquipoElemento = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM equipo_elemento')) ?? 0;

    if(countEquipoElemento == 0){
      final checklist = <EquipoElemento>[
      // equipo 2
      EquipoElemento(equipoId: 2, elementoId: 1, orden: 1),
      EquipoElemento(equipoId: 2, elementoId: 17, orden: 2),
      EquipoElemento(equipoId: 2, elementoId: 32, orden: 3),
      EquipoElemento(equipoId: 2, elementoId: 13, orden: 4),
      EquipoElemento(equipoId: 2, elementoId: 28, orden: 5),
      EquipoElemento(equipoId: 2, elementoId: 7, orden: 6),
      EquipoElemento(equipoId: 2, elementoId: 21, orden: 7),
      EquipoElemento(equipoId: 2, elementoId: 8, orden: 8),
      EquipoElemento(equipoId: 2, elementoId: 26, orden: 9),
      EquipoElemento(equipoId: 2, elementoId: 27, orden: 10),

      // equipo 1
      EquipoElemento(equipoId: 1, elementoId: 24, orden: 1),
      EquipoElemento(equipoId: 1, elementoId: 2, orden: 2),
      EquipoElemento(equipoId: 1, elementoId: 22, orden: 3),
      EquipoElemento(equipoId: 1, elementoId: 25, orden: 4),
      EquipoElemento(equipoId: 1, elementoId: 32, orden: 5),
      EquipoElemento(equipoId: 1, elementoId: 13, orden: 6),
      EquipoElemento(equipoId: 1, elementoId: 4, orden: 7),
      EquipoElemento(equipoId: 1, elementoId: 29, orden: 8),
      EquipoElemento(equipoId: 1, elementoId: 33, orden: 9),
      EquipoElemento(equipoId: 1, elementoId: 14, orden: 10),
      EquipoElemento(equipoId: 1, elementoId: 10, orden: 11),
      EquipoElemento(equipoId: 1, elementoId: 6, orden: 12),
      EquipoElemento(equipoId: 1, elementoId: 9, orden: 13),
      EquipoElemento(equipoId: 1, elementoId: 19, orden: 14),
      EquipoElemento(equipoId: 1, elementoId: 31, orden: 15),
      EquipoElemento(equipoId: 1, elementoId: 20, orden: 16),
      EquipoElemento(equipoId: 1, elementoId: 18, orden: 17),
      EquipoElemento(equipoId: 1, elementoId: 30, orden: 18),
      EquipoElemento(equipoId: 1, elementoId: 12, orden: 19),
      ];

      for( final e in checklist ){
        await repo.insertEquipoElemento(e);
      }
    }

  }

  
}

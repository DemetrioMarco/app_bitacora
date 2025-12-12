import 'package:app_bitacora/data/local_db.dart';
import 'package:app_bitacora/data/repositories/cat_repo.dart';
import 'package:app_bitacora/data/repositories/user_repo.dart';
import 'package:app_bitacora/models/app_user.dart';
import 'package:app_bitacora/models/area.dart';
import 'package:app_bitacora/models/equipo.dart';
import 'package:app_bitacora/models/equipo_elemento.dart';
import 'package:app_bitacora/models/equipo_relacion.dart';
import 'package:app_bitacora/models/frecuencia.dart';
import 'package:app_bitacora/models/sub_area.dart';
import 'package:app_bitacora/models/tipo_limpieza.dart';
import 'package:sqflite/sqflite.dart';

import '../models/elemento.dart';

class SeedService {
  static Future<void> seedIfNeeded() async {
    final db = await LocalDB.instance.db;
    final CatalogRepo repo = CatalogRepo(db);
    final UserRepo userRepo = UserRepo(db);

    // comprobar si ya hay equipos
    final countEquipos = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM equipos')) ??
        0;

    if (countEquipos == 0) {
      final equipos = [
        Equipo(nombre: 'Conche CN-3310'),
        Equipo(nombre: 'Conche CN-3320'),
        Equipo(nombre: 'Conche CN-3330'),
        Equipo(nombre: 'Conche CN-3340'),
        Equipo(nombre: 'Conche CN-4310'),
        Equipo(nombre: 'Conche CN-4320'),
        Equipo(nombre: 'Conche CN-4330'),
        Equipo(nombre: 'Conche CN-4340'),
        Equipo(nombre: 'Conche DUC'),
        Equipo(nombre: 'Conche ELK01'),
        Equipo(nombre: 'Conche ELK02'),
        Equipo(nombre: 'Conche ELK09'),
        Equipo(nombre: 'Mezclador'),
        Equipo(nombre: 'Mezclador M1-3050'),
        Equipo(nombre: 'Mezclador de Molino'),
        Equipo(nombre: 'Plataforma'),
        Equipo(nombre: 'Plataforma (Nivel 1 y Nivel 3)'),
        Equipo(nombre: 'Plataforma (Nivel 1, Nivel 2 y Nivel 3)'),
        Equipo(nombre: 'Plataforma BM1'),
        Equipo(nombre: 'Plataforma BM2'),
        Equipo(nombre: 'Plataforma Cernedor CRF-169 y CRF-170'),
        Equipo(nombre: 'Plataforma Cernedor CRL01C2'),
        Equipo(nombre: 'Plataforma Cernedor CRMEL01'),
        Equipo(nombre: 'Plataforma Clover 1'),
        Equipo(nombre: 'Plataforma Conche DUC'),
        Equipo(nombre: 'Plataforma Conches'),
        Equipo(nombre: 'Plataforma de apoyo'),
        Equipo(nombre: 'Plataforma de azúcar'),
        Equipo(nombre: 'Plataforma de carga'),
        Equipo(nombre: 'Plataforma de cocoa'),
        Equipo(nombre: 'Plataforma de cruce'),
        Equipo(nombre: 'Plataforma de envasadora'),
        Equipo(nombre: 'Plataforma de leche'),
        Equipo(nombre: 'Plataforma L1 y L4'),
        Equipo(nombre: 'Plataforma Sanitaria(esclusa )'),
        Equipo(nombre: 'Plataforma salida de emergencia'),
        Equipo(nombre: 'Plataforma Tanque 1694 1695'),
        Equipo(nombre: 'Plataforma Tanque de acero INOX TAN-20'),
        Equipo(nombre: 'Plataforma Tanques'),
        Equipo(nombre: 'Plataforma Acceso'),
      ];

      // Insertar equipo
      for (final e in equipos) {
        await repo.insertEquipo(e);
      }
    }

    // Comprobar la tabla de subarea
    final countSubArea = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM sub_area')) ??
        0;

    if (countSubArea == 0) {
      final subAreas = <SubArea>[
        SubArea(
            id: 1,
            nombre: 'Polvos',
            activo: true,
            fechaCreacion: DateTime.now(),
            fechaActualizacion: DateTime.now()),
        SubArea(
            id: 2,
            nombre: 'L-1 / L-4',
            activo: true,
            fechaCreacion: DateTime.now(),
            fechaActualizacion: DateTime.now()),
        SubArea(
            id: 3,
            nombre: 'L-1',
            activo: true,
            fechaCreacion: DateTime.now(),
            fechaActualizacion: DateTime.now()),
        SubArea(
            id: 4,
            nombre: 'Fundición',
            activo: true,
            fechaCreacion: DateTime.now(),
            fechaActualizacion: DateTime.now()),
        SubArea(
            id: 5,
            nombre: 'L-4',
            activo: true,
            fechaCreacion: DateTime.now(),
            fechaActualizacion: DateTime.now()),
        SubArea(
            id: 6,
            nombre: 'L-2',
            activo: true,
            fechaCreacion: DateTime.now(),
            fechaActualizacion: DateTime.now()),
        SubArea(
            id: 7,
            nombre: 'BIB',
            activo: true,
            fechaCreacion: DateTime.now(),
            fechaActualizacion: DateTime.now()),
        SubArea(
            id: 8,
            nombre: 'Tanques Bauermeister',
            activo: true,
            fechaCreacion: DateTime.now(),
            fechaActualizacion: DateTime.now()),
        SubArea(
            id: 9,
            nombre: 'Tanques',
            activo: true,
            fechaCreacion: DateTime.now(),
            fechaActualizacion: DateTime.now()),
        SubArea(
            id: 10,
            nombre: 'MARS',
            activo: true,
            fechaCreacion: DateTime.now(),
            fechaActualizacion: DateTime.now()),
        SubArea(
            id: 11,
            nombre: 'Patio de carga',
            activo: true,
            fechaCreacion: DateTime.now(),
            fechaActualizacion: DateTime.now()),
        SubArea(
            id: 12,
            nombre: 'Granja de Tanques',
            activo: true,
            fechaCreacion: DateTime.now(),
            fechaActualizacion: DateTime.now()),
        SubArea(
            id: 13,
            nombre: 'Lloveras',
            activo: true,
            fechaCreacion: DateTime.now(),
            fechaActualizacion: DateTime.now()),
        SubArea(
            id: 14,
            nombre: 'MIK',
            activo: true,
            fechaCreacion: DateTime.now(),
            fechaActualizacion: DateTime.now()),
        SubArea(
            id: 15,
            nombre: 'Extruido',
            activo: true,
            fechaCreacion: DateTime.now(),
            fechaActualizacion: DateTime.now()),
        SubArea(
            id: 16,
            nombre: 'BM1',
            activo: true,
            fechaCreacion: DateTime.now(),
            fechaActualizacion: DateTime.now()),
        SubArea(
            id: 17,
            nombre: 'BM2',
            activo: true,
            fechaCreacion: DateTime.now(),
            fechaActualizacion: DateTime.now()),
        SubArea(
            id: 18,
            nombre: 'Planta piloto',
            activo: true,
            fechaCreacion: DateTime.now(),
            fechaActualizacion: DateTime.now()),
      ];

      for (final a in subAreas) {
        await repo.insertSubArea(a);
      }
    }

    // Comprobar la tabla de área
    final countArea = Sqflite.firstIntValue(
            await db.rawQuery("SELECT COUNT(*) FROM areas")) ??
        0;

    if (countArea == 0) {
      final areas = <Area>[
        Area(
            id: 1,
            nombre: 'Polvos',
            activo: true,
            fechaCreacion: DateTime.now(),
            fechaActualizacion: DateTime.now()),
        Area(
            id: 2,
            nombre: 'Líquidos',
            activo: true,
            fechaCreacion: DateTime.now(),
            fechaActualizacion: DateTime.now()),
        Area(
            id: 3,
            nombre: 'Shipping',
            activo: true,
            fechaCreacion: DateTime.now(),
            fechaActualizacion: DateTime.now()),
        Area(
            id: 4,
            nombre: 'Solidos',
            activo: true,
            fechaCreacion: DateTime.now(),
            fechaActualizacion: DateTime.now()),
        Area(
            id: 5,
            nombre: 'Vermicelli',
            activo: true,
            fechaCreacion: DateTime.now(),
            fechaActualizacion: DateTime.now()),
        Area(
            id: 6,
            nombre: 'Planta piloto',
            activo: true,
            fechaCreacion: DateTime.now(),
            fechaActualizacion: DateTime.now()),
      ];

      for (final a in areas) {
        await repo.insertArea(a);
      }
    }

    // tabla de frecuencia
    final countFrecuencia = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM frecuencia')) ??
        0;

    if (countFrecuencia == 0) {
      final frecuencias = [
        Frecuencia(nombre: 'Semanal'),
        Frecuencia(nombre: 'Quincenal'),
        Frecuencia(nombre: '2 veces por semana')
      ];

      for (final f in frecuencias) {
        await repo.insertFrecuencia(f);
      }
    }

    // Tabla de elementos
    final countElementos = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM elementos')) ??
        0;

    if (countElementos == 0) {
      // Crear elementos
      final elementos = [
        Elemento(nombre: 'Barandales'),
        Elemento(nombre: 'Barandeles (plataforma lateral)'),
        Elemento(nombre: 'Bombas'),
        Elemento(nombre: 'Chimenea'),
        Elemento(nombre: 'Cuerpo inferior'),
        Elemento(nombre: 'Cuerpo superior'),
        Elemento(nombre: 'Escalera'),
        Elemento(nombre: 'Escaleras'),
        Elemento(nombre: 'Escalones'),
        Elemento(nombre: 'Manija'),
        Elemento(nombre: 'Magneto'),
        Elemento(nombre: 'Mangueras'),
        Elemento(nombre: 'Motores aereos'),
        Elemento(nombre: 'Motor inferior'),
        Elemento(nombre: 'Motor lateral'),
        Elemento(nombre: 'Motor superior'),
        Elemento(nombre: 'Panel de control'),
        Elemento(nombre: 'Peldaños (plataforma lateral)'),
        Elemento(nombre: 'Plataforma'),
        Elemento(nombre: 'Plataforma lateral'),
        Elemento(nombre: 'Silo'),
        Elemento(nombre: 'Soportes estructurales'),
        Elemento(nombre: 'Tapa'),
        Elemento(nombre: 'Tolvas'),
        Elemento(nombre: 'Tubería de bajada'),
        Elemento(nombre: 'Tubería inferior'),
        Elemento(nombre: 'Tuberías'),
        Elemento(nombre: 'Tuberías superior'),
      ];

      // insertar elemento
      for (final e in elementos) {
        await repo.insertElemento(e);
      }
    }

    final countEquipoElemento = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM equipo_elemento')) ??
        0;

    if (countEquipoElemento == 0) {
      final checklist = [
// 1 Conche CN-3310
        EquipoElemento(
            equipoId: 1, elementoId: 13, orden: 1), // Motores aereos / Motor
        EquipoElemento(
            equipoId: 1, elementoId: 17, orden: 2), // Panel de control
        EquipoElemento(equipoId: 1, elementoId: 27, orden: 3), // Tuberías
        EquipoElemento(
            equipoId: 1, elementoId: 26, orden: 4), // Tubería inferior
        EquipoElemento(
            equipoId: 1, elementoId: 22, orden: 5), // Soportes estructurales
        EquipoElemento(equipoId: 1, elementoId: 3, orden: 6), // Bombas
        EquipoElemento(equipoId: 1, elementoId: 1, orden: 7), // Barandales

// 2 Conche CN-3320
        EquipoElemento(equipoId: 2, elementoId: 13, orden: 1),
        EquipoElemento(equipoId: 2, elementoId: 17, orden: 2),
        EquipoElemento(equipoId: 2, elementoId: 27, orden: 3),
        EquipoElemento(equipoId: 2, elementoId: 22, orden: 4),
        EquipoElemento(equipoId: 2, elementoId: 3, orden: 5),

// 3 Conche CN-3330
        EquipoElemento(equipoId: 3, elementoId: 13, orden: 1),
        EquipoElemento(equipoId: 3, elementoId: 17, orden: 2),
        EquipoElemento(equipoId: 3, elementoId: 27, orden: 3),
        EquipoElemento(equipoId: 3, elementoId: 22, orden: 4),

// 4 Conche CN-3340
        EquipoElemento(equipoId: 4, elementoId: 13, orden: 1),
        EquipoElemento(equipoId: 4, elementoId: 17, orden: 2),
        EquipoElemento(equipoId: 4, elementoId: 27, orden: 3),
        EquipoElemento(equipoId: 4, elementoId: 22, orden: 4),

// 5 Conche CN-4310
        EquipoElemento(equipoId: 5, elementoId: 13, orden: 1),
        EquipoElemento(equipoId: 5, elementoId: 17, orden: 2),
        EquipoElemento(equipoId: 5, elementoId: 27, orden: 3),
        EquipoElemento(equipoId: 5, elementoId: 22, orden: 4),

// 6 Conche CN-4320
        EquipoElemento(equipoId: 6, elementoId: 13, orden: 1),
        EquipoElemento(equipoId: 6, elementoId: 17, orden: 2),
        EquipoElemento(equipoId: 6, elementoId: 27, orden: 3),
        EquipoElemento(equipoId: 6, elementoId: 22, orden: 4),

// 7 Conche CN-4330
        EquipoElemento(equipoId: 7, elementoId: 13, orden: 1),
        EquipoElemento(equipoId: 7, elementoId: 17, orden: 2),
        EquipoElemento(equipoId: 7, elementoId: 27, orden: 3),
        EquipoElemento(equipoId: 7, elementoId: 22, orden: 4),

// 8 Conche CN-4340
        EquipoElemento(equipoId: 8, elementoId: 13, orden: 1),
        EquipoElemento(equipoId: 8, elementoId: 17, orden: 2),
        EquipoElemento(equipoId: 8, elementoId: 27, orden: 3),
        EquipoElemento(equipoId: 8, elementoId: 22, orden: 4),

// 9 Conche DUC
        EquipoElemento(equipoId: 9, elementoId: 13, orden: 1),
        EquipoElemento(equipoId: 9, elementoId: 17, orden: 2),
        EquipoElemento(equipoId: 9, elementoId: 27, orden: 3),
        EquipoElemento(equipoId: 9, elementoId: 22, orden: 4),

// 10 Conche ELK01
        EquipoElemento(equipoId: 10, elementoId: 13, orden: 1),
        EquipoElemento(equipoId: 10, elementoId: 17, orden: 2),
        EquipoElemento(equipoId: 10, elementoId: 27, orden: 3),

// 11 Conche ELK02
        EquipoElemento(equipoId: 11, elementoId: 13, orden: 1),
        EquipoElemento(equipoId: 11, elementoId: 17, orden: 2),
        EquipoElemento(equipoId: 11, elementoId: 27, orden: 3),

// 12 Conche ELK09
        EquipoElemento(equipoId: 12, elementoId: 13, orden: 1),
        EquipoElemento(equipoId: 12, elementoId: 17, orden: 2),
        EquipoElemento(equipoId: 12, elementoId: 27, orden: 3),

// 13 Mezclador
        EquipoElemento(equipoId: 13, elementoId: 13, orden: 1), // Motor
        EquipoElemento(
            equipoId: 13, elementoId: 17, orden: 2), // Panel de control
        EquipoElemento(equipoId: 13, elementoId: 24, orden: 3), // Tolvas
        EquipoElemento(equipoId: 13, elementoId: 27, orden: 4), // Tuberías
        EquipoElemento(equipoId: 13, elementoId: 3, orden: 5), // Bombas

// 14 Mezclador M1-3050
        EquipoElemento(equipoId: 14, elementoId: 13, orden: 1),
        EquipoElemento(equipoId: 14, elementoId: 17, orden: 2),
        EquipoElemento(equipoId: 14, elementoId: 24, orden: 3),
        EquipoElemento(equipoId: 14, elementoId: 27, orden: 4),

// 15 Mezclador de Molino
        EquipoElemento(equipoId: 15, elementoId: 13, orden: 1),
        EquipoElemento(equipoId: 15, elementoId: 17, orden: 2),
        EquipoElemento(equipoId: 15, elementoId: 27, orden: 3),
        EquipoElemento(equipoId: 15, elementoId: 3, orden: 4),

// 16 Plataforma
        EquipoElemento(equipoId: 16, elementoId: 19, orden: 1),
        EquipoElemento(equipoId: 16, elementoId: 1, orden: 2),
        EquipoElemento(equipoId: 16, elementoId: 7, orden: 3),
        EquipoElemento(equipoId: 16, elementoId: 9, orden: 4),

// 17 Plataforma (Nivel 1 y Nivel 3)
        EquipoElemento(equipoId: 17, elementoId: 19, orden: 1),
        EquipoElemento(equipoId: 17, elementoId: 1, orden: 2),
        EquipoElemento(equipoId: 17, elementoId: 7, orden: 3),
        EquipoElemento(equipoId: 17, elementoId: 18, orden: 4),

// 18 Plataforma (Nivel 1, Nivel 2 y Nivel 3)
        EquipoElemento(equipoId: 18, elementoId: 19, orden: 1),
        EquipoElemento(equipoId: 18, elementoId: 1, orden: 2),
        EquipoElemento(equipoId: 18, elementoId: 7, orden: 3),
        EquipoElemento(equipoId: 18, elementoId: 18, orden: 4),

// 19 Plataforma BM1
        EquipoElemento(equipoId: 19, elementoId: 19, orden: 1),
        EquipoElemento(equipoId: 19, elementoId: 1, orden: 2),
        EquipoElemento(equipoId: 19, elementoId: 7, orden: 3),

// 20 Plataforma BM2
        EquipoElemento(equipoId: 20, elementoId: 19, orden: 1),
        EquipoElemento(equipoId: 20, elementoId: 1, orden: 2),
        EquipoElemento(equipoId: 20, elementoId: 7, orden: 3),

// 21 Plataforma Cernedor CRF-169 y CRF-170
        EquipoElemento(equipoId: 21, elementoId: 19, orden: 1),
        EquipoElemento(equipoId: 21, elementoId: 17, orden: 2), // panel
        EquipoElemento(equipoId: 21, elementoId: 13, orden: 3), // motor
        EquipoElemento(equipoId: 21, elementoId: 27, orden: 4),

// 22 Plataforma Cernedor CRL01C2
        EquipoElemento(equipoId: 22, elementoId: 19, orden: 1),
        EquipoElemento(equipoId: 22, elementoId: 17, orden: 2),
        EquipoElemento(equipoId: 22, elementoId: 13, orden: 3),
        EquipoElemento(equipoId: 22, elementoId: 27, orden: 4),

// 23 Plataforma Cernedor CRMEL01
        EquipoElemento(equipoId: 23, elementoId: 19, orden: 1),
        EquipoElemento(equipoId: 23, elementoId: 17, orden: 2),
        EquipoElemento(equipoId: 23, elementoId: 13, orden: 3),
        EquipoElemento(equipoId: 23, elementoId: 27, orden: 4),

// 24 Plataforma Clover 1
        EquipoElemento(equipoId: 24, elementoId: 19, orden: 1),
        EquipoElemento(equipoId: 24, elementoId: 1, orden: 2),
        EquipoElemento(equipoId: 24, elementoId: 17, orden: 3),
        EquipoElemento(equipoId: 24, elementoId: 13, orden: 4),

// 25 Plataforma Conche DUC
        EquipoElemento(equipoId: 25, elementoId: 19, orden: 1),
        EquipoElemento(equipoId: 25, elementoId: 1, orden: 2),
        EquipoElemento(equipoId: 25, elementoId: 17, orden: 3),
        EquipoElemento(equipoId: 25, elementoId: 13, orden: 4),

// 26 Plataforma Conches
        EquipoElemento(equipoId: 26, elementoId: 19, orden: 1),
        EquipoElemento(equipoId: 26, elementoId: 1, orden: 2),
        EquipoElemento(equipoId: 26, elementoId: 17, orden: 3),
        EquipoElemento(equipoId: 26, elementoId: 13, orden: 4),

// 27 Plataforma de apoyo
        EquipoElemento(equipoId: 27, elementoId: 19, orden: 1),
        EquipoElemento(equipoId: 27, elementoId: 1, orden: 2),
        EquipoElemento(equipoId: 27, elementoId: 22, orden: 3),

// 28 Plataforma de azúcar
        EquipoElemento(equipoId: 28, elementoId: 1, orden: 1),
        EquipoElemento(equipoId: 28, elementoId: 19, orden: 2),
        EquipoElemento(equipoId: 28, elementoId: 7, orden: 3),

// 29 Plataforma de carga
        EquipoElemento(equipoId: 29, elementoId: 19, orden: 1),
        EquipoElemento(equipoId: 29, elementoId: 1, orden: 2),
        EquipoElemento(
            equipoId: 29, elementoId: 21, orden: 3), // silo (si aplica)
        EquipoElemento(equipoId: 29, elementoId: 22, orden: 4),

// 30 Plataforma de cocoa
        EquipoElemento(equipoId: 30, elementoId: 19, orden: 1),
        EquipoElemento(equipoId: 30, elementoId: 1, orden: 2),
        EquipoElemento(equipoId: 30, elementoId: 17, orden: 3),

// 31 Plataforma de cruce
        EquipoElemento(equipoId: 31, elementoId: 19, orden: 1),
        EquipoElemento(equipoId: 31, elementoId: 1, orden: 2),
        EquipoElemento(equipoId: 31, elementoId: 7, orden: 3),

// 32 Plataforma de envasadora
        EquipoElemento(equipoId: 32, elementoId: 19, orden: 1),
        EquipoElemento(equipoId: 32, elementoId: 1, orden: 2),
        EquipoElemento(equipoId: 32, elementoId: 17, orden: 3),

// 33 Plataforma de leche
        EquipoElemento(equipoId: 33, elementoId: 19, orden: 1),
        EquipoElemento(equipoId: 33, elementoId: 1, orden: 2),
        EquipoElemento(equipoId: 33, elementoId: 7, orden: 3),

// 34 Plataforma L1 y L4
        EquipoElemento(equipoId: 34, elementoId: 19, orden: 1),
        EquipoElemento(equipoId: 34, elementoId: 1, orden: 2),
        EquipoElemento(equipoId: 34, elementoId: 7, orden: 3),

// 35 Plataforma Sanitaria(esclusa )
        EquipoElemento(equipoId: 35, elementoId: 19, orden: 1),
        EquipoElemento(equipoId: 35, elementoId: 23, orden: 2), // tapa
        EquipoElemento(equipoId: 35, elementoId: 10, orden: 3), // manija

// 36 Plataforma salida de emergencia
        EquipoElemento(equipoId: 36, elementoId: 7, orden: 1),
        EquipoElemento(equipoId: 36, elementoId: 9, orden: 2),
        EquipoElemento(equipoId: 36, elementoId: 1, orden: 3),
        EquipoElemento(equipoId: 36, elementoId: 18, orden: 4),

// 37 Plataforma Tanque 1694 1695
        EquipoElemento(equipoId: 37, elementoId: 19, orden: 1),
        EquipoElemento(equipoId: 37, elementoId: 23, orden: 2), // tapa
        EquipoElemento(equipoId: 37, elementoId: 10, orden: 3), // manija
        EquipoElemento(equipoId: 37, elementoId: 22, orden: 4), // soportes

// 38 Plataforma Tanque de acero INOX TAN-20
        EquipoElemento(equipoId: 38, elementoId: 19, orden: 1),
        EquipoElemento(equipoId: 38, elementoId: 23, orden: 2),
        EquipoElemento(equipoId: 38, elementoId: 10, orden: 3),
        EquipoElemento(equipoId: 38, elementoId: 22, orden: 4),

// 39 Plataforma Tanques
        EquipoElemento(equipoId: 39, elementoId: 19, orden: 1),
        EquipoElemento(equipoId: 39, elementoId: 23, orden: 2),
        EquipoElemento(equipoId: 39, elementoId: 10, orden: 3),
        EquipoElemento(equipoId: 39, elementoId: 22, orden: 4),

// 40 Plataforma Acceso
        EquipoElemento(equipoId: 40, elementoId: 19, orden: 1),
        EquipoElemento(equipoId: 40, elementoId: 7, orden: 2),
        EquipoElemento(equipoId: 40, elementoId: 1, orden: 3),
        EquipoElemento(equipoId: 40, elementoId: 18, orden: 4),
      ];

      for (final e in checklist) {
        await repo.insertEquipoElemento(e);
      }
    }

    // Tipo limpieza
    final countTipoLimpieza = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM tipos_limpieza')) ??
        0;

    if (countTipoLimpieza == 0) {
      final tipoLimpieza = [
        TipoLimpieza(
            nombre: 'Rutina', activo: true, fechaCreacion: DateTime.now()),
      ];

      for (final t in tipoLimpieza) {
        await repo.insertTipoLimpieza(t);
      }
    }

    // Equipo Relacion
    final countEquipoRelacion = Sqflite.firstIntValue(
            await db.rawQuery('SElECT COUNT(*) FROM equipo_relacion')) ??
        0;

    if (countEquipoRelacion == 0) {
      final equipoRelaciones = [
        EquipoRelacion(
            equipoId: 28,
            areaId: 1,
            subAreaId: 1,
            frecuenciaId: 1,
            tipoLimpiezaId: 1),
        EquipoRelacion(
            equipoId: 33,
            areaId: 1,
            subAreaId: 1,
            frecuenciaId: 1,
            tipoLimpiezaId: 1),
        EquipoRelacion(
            equipoId: 31,
            areaId: 1,
            subAreaId: 1,
            frecuenciaId: 1,
            tipoLimpiezaId: 1),
        EquipoRelacion(
            equipoId: 30,
            areaId: 1,
            subAreaId: 1,
            frecuenciaId: 1,
            tipoLimpiezaId: 1),
        EquipoRelacion(
            equipoId: 35,
            areaId: 1,
            subAreaId: 1,
            frecuenciaId: 1,
            tipoLimpiezaId: 1),
        EquipoRelacion(
            equipoId: 34,
            areaId: 1,
            subAreaId: 1,
            frecuenciaId: 1,
            tipoLimpiezaId: 1),
        EquipoRelacion(
            equipoId: 17,
            areaId: 2,
            subAreaId: 2,
            frecuenciaId: 1,
            tipoLimpiezaId: 1),
        EquipoRelacion(
            equipoId: 13,
            areaId: 2,
            subAreaId: 3,
            frecuenciaId: 2,
            tipoLimpiezaId: 1),
        EquipoRelacion(
            equipoId: 10,
            areaId: 2,
            subAreaId: 3,
            frecuenciaId: 2,
            tipoLimpiezaId: 1),
        EquipoRelacion(
            equipoId: 11,
            areaId: 2,
            subAreaId: 3,
            frecuenciaId: 2,
            tipoLimpiezaId: 1),
        EquipoRelacion(
            equipoId: 12,
            areaId: 2,
            subAreaId: 3,
            frecuenciaId: 2,
            tipoLimpiezaId: 1),
        EquipoRelacion(
            equipoId: 23,
            areaId: 2,
            subAreaId: 4,
            frecuenciaId: 1,
            tipoLimpiezaId: 1),
        EquipoRelacion(
            equipoId: 24,
            areaId: 2,
            subAreaId: 5,
            frecuenciaId: 1,
            tipoLimpiezaId: 1),
        EquipoRelacion(
            equipoId: 26,
            areaId: 2,
            subAreaId: 5,
            frecuenciaId: 1,
            tipoLimpiezaId: 1),
        EquipoRelacion(
            equipoId: 37,
            areaId: 2,
            subAreaId: 5,
            frecuenciaId: 1,
            tipoLimpiezaId: 1),
        EquipoRelacion(
            equipoId: 26,
            areaId: 2,
            subAreaId: 3,
            frecuenciaId: 1,
            tipoLimpiezaId: 1),
        EquipoRelacion(
            equipoId: 25,
            areaId: 2,
            subAreaId: 3,
            frecuenciaId: 1,
            tipoLimpiezaId: 1),
        EquipoRelacion(
            equipoId: 9,
            areaId: 2,
            subAreaId: 3,
            frecuenciaId: 2,
            tipoLimpiezaId: 1),
        EquipoRelacion(
            equipoId: 18,
            areaId: 2,
            subAreaId: 6,
            frecuenciaId: 1,
            tipoLimpiezaId: 1),
        EquipoRelacion(
            equipoId: 14,
            areaId: 2,
            subAreaId: 6,
            frecuenciaId: 1,
            tipoLimpiezaId: 1),
        EquipoRelacion(
            equipoId: 26,
            areaId: 2,
            subAreaId: 6,
            frecuenciaId: 1,
            tipoLimpiezaId: 1),
        EquipoRelacion(
            equipoId: 1,
            areaId: 2,
            subAreaId: 6,
            frecuenciaId: 1,
            tipoLimpiezaId: 1),
        EquipoRelacion(
            equipoId: 2,
            areaId: 2,
            subAreaId: 6,
            frecuenciaId: 1,
            tipoLimpiezaId: 1),
        EquipoRelacion(
            equipoId: 3,
            areaId: 2,
            subAreaId: 6,
            frecuenciaId: 1,
            tipoLimpiezaId: 1),
        EquipoRelacion(
            equipoId: 4,
            areaId: 2,
            subAreaId: 6,
            frecuenciaId: 1,
            tipoLimpiezaId: 1),
        EquipoRelacion(
            equipoId: 13,
            areaId: 2,
            subAreaId: 5,
            frecuenciaId: 1,
            tipoLimpiezaId: 1),
        EquipoRelacion(
            equipoId: 21,
            areaId: 2,
            subAreaId: 4,
            frecuenciaId: 1,
            tipoLimpiezaId: 1),
        EquipoRelacion(
            equipoId: 13,
            areaId: 2,
            subAreaId: 4,
            frecuenciaId: 1,
            tipoLimpiezaId: 1),
        EquipoRelacion(
            equipoId: 15,
            areaId: 2,
            subAreaId: 4,
            frecuenciaId: 1,
            tipoLimpiezaId: 1),
        EquipoRelacion(
            equipoId: 38,
            areaId: 2,
            subAreaId: 7,
            frecuenciaId: 1,
            tipoLimpiezaId: 1),
        EquipoRelacion(
            equipoId: 29,
            areaId: 3,
            subAreaId: 11,
            frecuenciaId: 3,
            tipoLimpiezaId: 1),
        EquipoRelacion(
            equipoId: 36,
            areaId: 3,
            subAreaId: 11,
            frecuenciaId: 3,
            tipoLimpiezaId: 1),
        EquipoRelacion(
            equipoId: 31,
            areaId: 3,
            subAreaId: 12,
            frecuenciaId: 1,
            tipoLimpiezaId: 1),
        EquipoRelacion(
            equipoId: 13,
            areaId: 4,
            subAreaId: 13,
            frecuenciaId: 1,
            tipoLimpiezaId: 1),
        EquipoRelacion(
            equipoId: 32,
            areaId: 4,
            subAreaId: 13,
            frecuenciaId: 1,
            tipoLimpiezaId: 1),
        EquipoRelacion(
            equipoId: 32,
            areaId: 4,
            subAreaId: 14,
            frecuenciaId: 1,
            tipoLimpiezaId: 1),
        EquipoRelacion(
            equipoId: 27,
            areaId: 5,
            subAreaId: 15,
            frecuenciaId: 1,
            tipoLimpiezaId: 1),
        EquipoRelacion(
            equipoId: 19,
            areaId: 5,
            subAreaId: 16,
            frecuenciaId: 1,
            tipoLimpiezaId: 1),
        EquipoRelacion(
            equipoId: 20,
            areaId: 5,
            subAreaId: 17,
            frecuenciaId: 1,
            tipoLimpiezaId: 1),
        EquipoRelacion(
            equipoId: 16,
            areaId: 5,
            subAreaId: 15,
            frecuenciaId: 1,
            tipoLimpiezaId: 1),
        EquipoRelacion(
            equipoId: 16,
            areaId: 6,
            subAreaId: 18,
            frecuenciaId: 1,
            tipoLimpiezaId: 1),
      ];

      for(final er in equipoRelaciones){
        await repo.insertEquipoRelacion(er);
      }
    }

    // Usuarios
    final countUser = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM user')
    ) ?? 0;

    if( countUser == 0){
      final users = [
        AppUser(username: 'Operador 1', role: 'Operador', pass: '1234'),
        AppUser(username: 'Operador 2', role: 'Operador', pass: '5678'),
        AppUser(username: 'Operador 3', role: 'Operador', pass: '9874'),
        AppUser(username: 'Admin', role: 'Admin', pass: '2509')
      ];

      for(final u in users){
        await userRepo.insertUser(u);
      }
    }
  }
}

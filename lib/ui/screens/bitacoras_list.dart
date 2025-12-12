import 'dart:io';

import 'package:app_bitacora/data/controller/cat_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';

import '../../models/app_user.dart';
import '/data/controller/bitacora_controller.dart';
import '/services/pdf_service.dart';
import '../screens/login_screen.dart';
import '../screens/bitacora_form.dart';
import '../screens/widgets/bitacora_item.dart';
import '../../services/monday.service.dart';
import '../../models/model.dart';
import '../../provider/user_provider.dart';
import '../../provider/bitacora_provider.dart';

class BitacorasListScreen extends StatefulWidget {
  const BitacorasListScreen({super.key});

  @override
  State<BitacorasListScreen> createState() => _BitacorasListScreenState();
}

class _BitacorasListScreenState extends State<BitacorasListScreen> {
  final BitacoraController bitacoraController = BitacoraController();
  final CatalogController catController = CatalogController();

   final Map<int, File> _generatedPdfs = {};

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Cargar bitácoras después del primer frame para poder acceder al context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBitacoras();
    });
  }

  Future<void> _loadBitacoras() async {
    final provider = Provider.of<BitacoraProvider>(context, listen: false);
    await provider.cargarBitacoras();
  }

  Future<void> _refresh() async {
    final provider = Provider.of<BitacoraProvider>(context, listen: false);
    await provider.cargarBitacoras();
  }

  // Cargar actividades desde Monday
  Future<void> _cargarItems() async {
    setState(() => isLoading = true);
    final AppUser? user =
        Provider.of<UserProvider>(context, listen: false).user;
    try {
      final items = await MondayService.instance.fetchItemsByTurnoAndOperador(
        turno: '1er Turno',
        operador: user!.username,
      );

      if (items.isNotEmpty) {
        for (final i in items) {
          int idEquipo = int.parse(i['equipoId']);
          final fecha = DateTime.parse(i['date']);
          final itemId = i['itemId'];
          final newBitacora =
              await catController.crearBitacora(idEquipo, fecha, itemId);
          bitacoraController.guardar(newBitacora!);

          await MondayService.instance
              .changeItemStatus(itemId: itemId, status: 'Cargada');
        }
      }

      await _loadBitacoras();
    } catch (e) {
      print('Error: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // Crear update en Monday
  Future<void> _updateItem() async {}

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BitacoraProvider>(context);
    final List<Bitacora> bitacoras = provider.bitacoras;
    final BitacoraController bitacoraController = BitacoraController();
    final user = Provider.of<UserProvider>(context, listen: false).user;

    return Scaffold(
      appBar: AppBar(
        title: Text('Programa de visitas ${user?.role}'),
        actions: [
          IconButton(
              onPressed: () {
                Provider.of<UserProvider>(context, listen: false).logout();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()));
              },
              icon: const Icon(Icons.logout)),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _refresh,
            child: bitacoras.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                        SizedBox(height: 120),
                        Center(
                            child: Text(
                                'No hay bitácoras. Presiona + para crear una.')),
                      ])
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: bitacoras.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final b = bitacoras[i];
                      return FutureBuilder(
                          future: bitacoraController.tieneSignature(b.id!),
                          builder: (context, snapshot) {
                            final locked = snapshot.data ?? false;

                            if (user?.role == 'Admin') {
                              return Dismissible(
                                  key: ValueKey(b.id),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    color: Colors.red,
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    child: const Icon(Icons.delete,
                                        color: Colors.white),
                                  ),
                                  confirmDismiss: (direction) async {
                                    final bool? confirm = await showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                              title: const Text('Confirmar'),
                                              content: const Text(
                                                  '¿Desea eliminar esta bitácora'),
                                              actions: [
                                                TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(context)
                                                            .pop(false),
                                                    child:
                                                        const Text('Cancelar')),
                                                TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(context)
                                                            .pop(true),
                                                    child:
                                                        const Text('Eliminar')),
                                              ],
                                            ));
                                    return confirm ?? false;
                                  },
                                  onDismissed: (direction) async {
                                    final scaffold =
                                        ScaffoldMessenger.of(context);
                                    try {
                                      // 1) Intentar borrar en BD
                                      final success = await bitacoraController
                                          .eliminarBitacora(b.id!);

                                      if (success) {
                                        await provider.cargarBitacoras();

                                        scaffold.showSnackBar(
                                          SnackBar(
                                            backgroundColor: Colors.green,
                                            content: Text(
                                                'Se eliminó la bitácora ${b.id}'),
                                          ),
                                        );
                                      } else {
                                        // No se borró nada en BD
                                        scaffold.showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'No se pudo eliminar la bitácora ${b.id}')),
                                        );
                                        // Mantener consistencia recargando
                                        await provider.cargarBitacoras();
                                      }
                                    } catch (e, st) {
                                      scaffold.showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Error al eliminar la bitácora: $e\n$st')),
                                      );
                                      await provider.cargarBitacoras();
                                    }
                                  },
                                  child: BitacoraItem(
                                    bitacora: b,
                                    locked: locked,
                                    onTap: () {
                                      // abrir detalle/editar
                                    },
                                    onShare: locked
                                        ? null
                                        : () async {
                                            final result =
                                                await Navigator.of(context)
                                                    .push(
                                              MaterialPageRoute(
                                                  builder: (_) =>
                                                      BitacoraFormScreen(
                                                          bitacora: b)),
                                            );
                                            if (result != null &&
                                                result is Map) {
                                              await provider.cargarBitacoras();
                                            }
                                          },
                                    onEdit: () async {
                                      final scaffold =
                                          ScaffoldMessenger.of(context);

                                      List<ChecklistItem> checklist =
                                          await bitacoraController
                                              .obtenerChecklistItem(b.id!);
                                      Firma? firma = await bitacoraController
                                          .obtenerSignature(b.id!);

                                      if (firma == null) {
                                        scaffold.showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'No se encontró firma asociada a esta bitácora'),
                                          ),
                                        );
                                        return;
                                      }

                                      try {
                                        final File? file =
                                            await generarPdfBitacora(
                                                b, checklist, firma);
                                        if (file == null) {
                                          scaffold.showSnackBar(const SnackBar(
                                              content: Text(
                                                  'En web la descarga del PDF se maneja distinto')));
                                          return;
                                        }
                                        scaffold.showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'PDF generado, abriendo...')),
                                        );
                                        if (kDebugMode) {
                                          print(file.path);
                                        }
                                        await OpenFilex.open(file.path);
                                      } catch (e) {
                                        scaffold.showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Error al generar el PDF: $e'),
                                          ),
                                        );
                                      }
                                    },
                                  ));
                            } else {
                              return BitacoraItem(
                                bitacora: b,
                                locked: locked,
                                onTap: () async {},
                                onShare: locked
                                    ? null
                                    : () async {
                                        final result =
                                            await Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  BitacoraFormScreen(
                                                      bitacora: b)),
                                        );
                                        if (result != null && result is Map) {
                                          await provider.cargarBitacoras();
                                        }
                                      },
                                onEdit: () async {
                                  final scaffold =
                                      ScaffoldMessenger.of(context);

                                  List<ChecklistItem> checklist =
                                      await bitacoraController
                                          .obtenerChecklistItem(b.id!);
                                  Firma? firma = await bitacoraController
                                      .obtenerSignature(b.id!);

                                  if (firma == null) {
                                    scaffold.showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'No se encontró firma asociada a esta bitácora'),
                                      ),
                                    );
                                    return;
                                  }

                                  try {
                                    final File? file = await generarPdfBitacora(
                                        b, checklist, firma);
                                    if (file == null) {
                                      scaffold.showSnackBar(const SnackBar(
                                          content: Text(
                                              'En web la descarga del PDF se maneja distinto')));
                                      return;
                                    }
                                    scaffold.showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'PDF generado, abriendo...')),
                                    );

                                    if(mounted){
                                      setState(() {
                                        _generatedPdfs[b.id!] = file;
                                      });
                                    }
                                    if (kDebugMode) {
                                      print(file.path);
                                      print(_generatedPdfs);
                                    }
                                    await OpenFilex.open(file.path);
                                  } catch (e) {
                                    scaffold.showSnackBar(
                                      SnackBar(
                                        content:
                                            Text('Error al generar el PDF: $e'),
                                      ),
                                    );
                                  }
                                },
                                onSend: () async {
                                  final scaffold =
                                      ScaffoldMessenger.of(context);
                                  try {
                                    // Si crearUpdate devuelve algo, captúralo; si no, solo esperalo
                                    final result = await MondayService.instance
                                        .crearUpdate(
                                      itemId: b.itemMonday,
                                      body: 'Actualización desde la app',
                                    );

                                    scaffold.showSnackBar(
                                      const SnackBar(
                                          content:Text('Update enviado a Monday')),
                                    );

                                    // Si quieres refrescar lista o estado:
                                    await provider.cargarBitacoras();
                                  } catch (e) {
                                    scaffold.showSnackBar(SnackBar(
                                        content: Text(
                                            'Error al enviar update: $e')));
                                  }
                                },
                              );
                            }
                          });
                    },
                  ),
          ),
          if (isLoading)
            Positioned.fill(
                child: Container(
              color: Colors.black45,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text('Cargando...', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ))
        ],
      ),
      floatingActionButton: (user?.role == 'Operador' || user?.role == 'Admin')
          ? FloatingActionButton(
              onPressed: isLoading ? null : _cargarItems,
              child: isLoading
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : const Icon(Icons.add))
          : null,
    );
  }
}

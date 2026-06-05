import 'dart:io';

import 'package:app_bitacora/data/controller/bitacora_api_controller.dart';
import 'package:app_bitacora/models/bitacora_api.dart';
import 'package:app_bitacora/services/board_config_service.dart';
import 'package:app_bitacora/services/task_service.dart';
import 'package:app_bitacora/utils/network_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';

import '/services/services.dart';
import '/provider/provider.dart';
import '/models/model.dart';
import 'screens.dart';
import 'widgets/bitacora_item.dart';

class BitacorasListScreen extends StatefulWidget {
  const BitacorasListScreen({super.key});

  @override
  State<BitacorasListScreen> createState() => _BitacorasListScreenState();
}

class _BitacorasListScreenState extends State<BitacorasListScreen> {
  final BitacoraAPIController bitacoraController = BitacoraAPIController();

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

  Future<void> _cargarTareasApi() async {
    if (!mounted) return;

    // 1. Verificar internet antes de intentar
    bool connected = await NetworkInfo.hasConnection();

    if (!mounted) return;

    if (!connected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Sin conexión a internet. No se pueden descargar nuevas tareas.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await TaskService.instance.fetchTareasMovil();

      if (kDebugMode) {
        debugPrint('Sincronización de API completada con éxito');
      }

      // 2. ESTA ES LA PARTE QUE TE FALTABA:
      // Le decimos al Provider que lea la base de datos local y actualice la UI
      if (mounted) {
        await Provider.of<BitacoraProvider>(context, listen: false)
            .cargarBitacoras();
      }
    } on TaskServiceException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.message}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } catch (e, stack) {
      debugPrint('ERROR _cargarTareasApi: $e');
      debugPrintStack(stackTrace: stack);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error inesperado: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BitacoraProvider>(context);
    final List<BitacoraAPI> bitacoras = provider.bitacoras;
    final BitacoraAPIController bitacoraController = BitacoraAPIController();
    final user = Provider.of<UserProvider>(context, listen: false).user;

    return Scaffold(
        appBar: AppBar(
          title: Text('Programa de visitas ${user?.nombre}'),
          actions: [
            IconButton(
                onPressed: () async {
                  await Provider.of<UserProvider>(context, listen: false)
                      .logout();

                  if (!context.mounted) return;

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
                                  'No hay bitácoras. \nPresiona + \npara cargar una.')),
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
                              final bool locked = snapshot.data ?? false;
                              final bool canSend = (b.pdf?.isNotEmpty ?? false);

                              if (user?.rol == 'ADMIN') {
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
                                                      child: const Text(
                                                          'Cancelar')),
                                                  TextButton(
                                                      onPressed: () =>
                                                          Navigator.of(context)
                                                              .pop(true),
                                                      child: const Text(
                                                          'Eliminar')),
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
                                                await provider
                                                    .cargarBitacoras();
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
                                          } else {
                                            b.pdf = file.path;
                                            await bitacoraController
                                                .updateBitacoraLocal(b);
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
                                  canSend: canSend,
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
                                      final File? file =
                                          await generarPdfBitacora(
                                              b, checklist, firma);
                                      if (file == null) {
                                        scaffold.showSnackBar(const SnackBar(
                                            content: Text(
                                                'En web la descarga del PDF se maneja distinto')));
                                        return;
                                      } else {
                                        b.pdf = file.path;
                                        await bitacoraController
                                            .updateBitacoraLocal(b);
                                        await provider.cargarBitacoras();
                                      }
                                      scaffold.showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'PDF generado, abriendo...')),
                                      );

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
                                  onSend: !canSend
                                      ? null
                                      : () async {
                                          final scaffold =
                                              ScaffoldMessenger.of(context);

                                          bool connected =
                                              await NetworkInfo.hasConnection();

                                              if (!mounted) return;

                                          if (!connected) {
                                            scaffold.showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Se requiere internet para enviar la bitácora terminada.'),
                                                backgroundColor: Colors.orange,
                                              ),
                                            );
                                            return;
                                          }

                                          setState(() => isLoading = true);

                                          try {
                                            // 1. Validar PDF
                                            final String? fileToUpload = b.pdf;
                                            if (fileToUpload == null ||
                                                fileToUpload.isEmpty) {
                                              throw Exception(
                                                  'No existe PDF generado para id=${b.id}');
                                            }

                                            // 2. Validar Foto
                                            final String? photoToUpload =
                                                b.photo;
                                            if (photoToUpload == null ||
                                                photoToUpload.trim().isEmpty) {
                                              throw Exception(
                                                  'Es obligatorio tomar una foto de evidencia antes de enviar.');
                                            }

                                            // 3. Obtener BoardId desde el Store
                                            final int? boardId =
                                                await BoardConfigService
                                                    .instance
                                                    .getBoardId();
                                            if (boardId == null) {
                                              throw Exception(
                                                  'No se encontró el boardId Configurado. Cierre sesión y vuelva a entrar');
                                            }

                                            final String itemIdStr =
                                                b.itemMonday.toString();
                                            final String boardIdStr =
                                                boardId.toString();

                                            // 4. Subir archivos a nuestro backend
                                            final bool successUpload =
                                                await TaskService.instance
                                                    .uploadTareaArchivos(
                                              itemId: itemIdStr,
                                              pdfPath: fileToUpload,
                                              photoPath: b.photo ?? '',
                                            );

                                            if (successUpload) {
                                              // 5. Cambiar estatus a "Listo"
                                              await TaskService.instance.updateTaskStatus(boardId: boardIdStr,itemId: itemIdStr);
                                              await bitacoraController.eliminarBitacora(b.id!);
                                              scaffold.showSnackBar( const SnackBar( content: Text('Evidencia subida y tarea finalizada correctamente'),
                                                          backgroundColor: Colors.green));

                                              await provider.cargarBitacoras();
                                                
                                              
                                            }
                                          } on TaskServiceException catch (e) {
                                            scaffold.showSnackBar(
                                              SnackBar(
                                                content: Text(e.message),
                                                backgroundColor: Colors.orange,
                                                duration:
                                                    const Duration(seconds: 6),
                                              ),
                                            );
                                          } catch (e) {
                                            scaffold.showSnackBar(SnackBar(
                                              content: Text(
                                                  'Error al enviar update: $e'),
                                              backgroundColor: Colors.redAccent,
                                            ));
                                          } finally {
                                            setState(() {
                                              isLoading = false;
                                            });
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
                      Text('Cargando...',
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ))
          ],
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: isLoading ? null : _cargarTareasApi,
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Icon(Icons.add)));
  }
}

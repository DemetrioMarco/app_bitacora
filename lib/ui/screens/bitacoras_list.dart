import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';

import 'programar_visita_dialog.dart';
import '/data/controller/bitacora_controller.dart';
import '/services/pdf_service.dart';
import '/ui/screens/bitacora_form.dart';
import '../../models/model.dart';
import '../../provider/bitacora_provider.dart';
import '../screens/widgets/bitacora_item.dart';

class BitacorasListScreen extends StatefulWidget {
  const BitacorasListScreen({super.key});

  @override
  State<BitacorasListScreen> createState() => _BitacorasListScreenState();
}

class _BitacorasListScreenState extends State<BitacorasListScreen> {
  final BitacoraController bitacoraController = BitacoraController();

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

  Future<void> _openProgramarModal() async {
    final newBitacora = await showModalBottomSheet<Bitacora>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
      builder: (_) => const ProgramarVisitaForm(),
    );

    if (!mounted) return;

    if (newBitacora != null) {
      final provider = Provider.of<BitacoraProvider>(context, listen: false);
      await provider.cargarBitacoras();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Visita programada (guardada localmente)')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BitacoraProvider>(context);
    final List<Bitacora> bitacoras = provider.bitacoras;
    final BitacoraController bitacoraController = BitacoraController();

    return Scaffold(
      appBar: AppBar(title: const Text('Programa de visitas')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: bitacoras.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                    SizedBox(height: 120),
                    Center(
                      child: Text('No hay bitácoras. Presiona + para crear una.')
                    ),
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

                        return Dismissible(
                            key: ValueKey(b.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child:
                                  const Icon(Icons.delete, color: Colors.white),
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
                                              child: const Text('Cancelar')),
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(true),
                                              child: const Text('Eliminar')),
                                        ],
                                      ));
                              return confirm ?? false;
                            },
                            onDismissed: (direction) async {
                              final scaffold = ScaffoldMessenger.of(context);
                              try {
                                // 1) Intentar borrar en BD
                                final success = await bitacoraController
                                    .eliminarBitacora(b.id!);

                                if (success) {
                                  
                                  await provider.cargarBitacoras();

                                  scaffold.showSnackBar(
                                    SnackBar(
                                      backgroundColor: Colors.green,
                                      content: Text('Se eliminó la bitácora ${b.id}'),
                                    ),
                                  );
                                } else {
                                  // No se borró nada en BD
                                  scaffold.showSnackBar(
                                    SnackBar(
                                      content: Text('No se pudo eliminar la bitácora ${b.id}')),
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
                                // TODO: abrir detalle/editar
                              },
                              onShare: locked
                                  ? null
                                  : () async {
                                      final result =
                                          await Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (_) => BitacoraFormScreen(
                                                bitacora: b)),
                                      );
                                      if (result != null && result is Map) {
                                        
                                        await provider.cargarBitacoras();
                                        
                                      }
                                    },
                              onEdit: () async {
                                final scaffold = ScaffoldMessenger.of(context);

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
                                        content:
                                            Text('PDF generado, abriendo...')),
                                  );
                                  print(file.path);
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
                            ));
                      });
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: _openProgramarModal, child: const Icon(Icons.add)),
    );
  }
}

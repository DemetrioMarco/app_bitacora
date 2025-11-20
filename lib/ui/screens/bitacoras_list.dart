// lib/ui/screens/bitacoras_list.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';

import 'package:app_bitacora/data/controller/bitacora_controller.dart';
import 'package:app_bitacora/data/controller/cat_controller.dart';
import 'package:app_bitacora/services/pdf_service.dart';
import 'package:app_bitacora/ui/screens/bitacora_form.dart';
import '../../models/model.dart';
import '../../provider/bitacora_provider.dart';
import '../screens/widgets/bitacora_item.dart';
import 'programar_visita_dialog.dart';

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
    final CatalogController catalogController = CatalogController();

    return Scaffold(
      appBar: AppBar(title: const Text('Bitácoras')),
      body: RefreshIndicator(
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
                      future: catalogController.tieneChecklist(b.id!),
                      builder: (context, snapshot) {
                        final locked = snapshot.data ?? false;
                        return BitacoraItem(
                          bitacora: b,
                          locked: locked,
                          onTap: () {
                            // TODO: abrir detalle/editar
                          },
                          onShare: false //locked
                              ? null
                              : () async {
                                  final result =
                                      await Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            BitacoraFormScreen(bitacora: b)),
                                  );
                                  if (result != null && result is Map) {
                                    // Si el formulario devolvió cambios, recargamos la lista desde la BD
                                    await provider.cargarBitacoras();
                                    // Si quieres puedes buscar el índice y actualizar sólo ese elemento en memoria
                                    // pero recargar es simple y garantiza sincronía con la BD
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
                                    content: Text('PDF generado, abriendo...')),
                              );
                              print(file.path);
                              await OpenFilex.open(file.path);
                            } catch (e) {
                              scaffold.showSnackBar(
                                SnackBar(
                                  content: Text('Error al generar el PDF: $e'),
                                ),
                              );
                            }
                          },
                        );
                      });
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: _openProgramarModal, child: const Icon(Icons.add)),
    );
  }
}

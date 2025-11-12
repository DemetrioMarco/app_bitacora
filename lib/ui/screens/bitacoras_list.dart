// lib/ui/screens/bitacoras_list.dart
import 'package:app_bitacora/ui/screens/bitacora_form.dart';
import 'package:flutter/material.dart';
import '../../models/bitacora.dart';
import '../screens/widgets/bitacora_item.dart';
import 'programar_visita_dialog.dart';

class BitacorasListScreen extends StatefulWidget {
  const BitacorasListScreen({super.key});

  @override
  State<BitacorasListScreen> createState() => _BitacorasListScreenState();
}

class _BitacorasListScreenState extends State<BitacorasListScreen> {
  final List<Bitacora> _bitacoras = [];

  Future<void> _refresh() async {
    // TODO: reemplazar por bitacoraRepo.getAll()
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {});
  }

  Future<void> _openProgramarModal() async {
    final newBitacora = await showModalBottomSheet<Bitacora>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
      builder: (_) => const ProgramarVisitaForm(),
    );

    if (newBitacora != null) {
      // TODO: en vez de solo memoria: insertar en DB con bitacoraRepo.insertBitacora(...)
      setState(() => _bitacoras.insert(0, newBitacora));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Visita programada (guardada localmente)')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bitácoras')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: _bitacoras.isEmpty
            ? ListView(physics: const AlwaysScrollableScrollPhysics(), children: const [
                SizedBox(height: 120),
                Center(child: Text('No hay bitácoras. Presiona + para crear una.')),
              ])
            : ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: _bitacoras.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final b = _bitacoras[i];
                  return BitacoraItem(
                    bitacora: b,
                    onTap: () {
                      // TODO: abrir detalle/editar
                    },
                    onShare: () {
                      // TODO: implementar compartir
                    },
                    onEdit: () async {
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => BitacoraFormScreen(bitacora: b)),
                      );
                      if (result != null && result is Map) {
                        // result['bitacora'] -> objeto actualizado
                        // result['checklist'] -> lista de mapas de checklist
                        // TODO: persistir en DB con bitacoraRepo.updateBitacora(...) y saveChecklistItems(...)
                        setState(() {
                          // si guardas localmente en memoria: actualizar elemento en _bitacoras
                          _bitacoras[i] = result['bitacora'] as Bitacora;
                        });
  }
},
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: _openProgramarModal, child: const Icon(Icons.add)),
    );
  }
}

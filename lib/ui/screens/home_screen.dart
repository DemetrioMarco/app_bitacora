import 'package:flutter/material.dart';
import 'package:app_bitacora/data/repositories/cat_repo.dart';
import 'package:app_bitacora/services/sync_service.dart';
import 'package:app_bitacora/models/area.dart';
import 'package:app_bitacora/ui/screens/widgets/area_picker_modal.dart';

class HomeScreen extends StatefulWidget {
  final SyncService syncService;
  final CatalogRepo repo;

  const HomeScreen({super.key, required this.syncService, required this.repo});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Area? selectedArea;

  Future<void> _openAreaPicker() async {
    final Area? area = await showModalBottomSheet<Area>(
      context: context,
      isScrollControlled: true,
      builder: (_) => AreaPickerModal(syncService: widget.syncService, repo: widget.repo),
    );

    if (!mounted) return;

    if (area != null) {
      setState(() => selectedArea = area);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Área seleccionada: ${area.nombre}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: ListTile(
                leading: Icon(
                  selectedArea == null ? Icons.help_outline : Icons.location_on,
                  color: selectedArea == null ? Colors.grey : Colors.green,
                ),
                title: Text(selectedArea?.nombre ?? 'Seleccione un área'),
                subtitle: selectedArea?.fechaActualizacion != null
                    ? Text('Actualizado: ${selectedArea!.fechaActualizacion.toIso8601String()}')
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            const Text('Presiona + para abrir el catálogo de Áreas'),
            const Spacer(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAreaPicker,
        tooltip: 'Seleccionar Área',
        child: const Icon(Icons.add),
      ),
    );
  }
}

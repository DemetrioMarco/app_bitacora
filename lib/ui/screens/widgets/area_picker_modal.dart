import 'package:flutter/material.dart';
import 'package:app_bitacora/data/repositories/cat_repo.dart';
import 'package:app_bitacora/services/sync_service.dart';
import 'package:app_bitacora/models/area.dart';

class AreaPickerModal extends StatefulWidget {
  final SyncService syncService;
  final CatalogRepo repo;

  const AreaPickerModal({super.key, required this.syncService, required this.repo});

  @override
  State<AreaPickerModal> createState() => _AreaPickerModalState();
}

class _AreaPickerModalState extends State<AreaPickerModal> {
  bool _loading = true;
  bool _syncing = false;
  String? _error;
  final List<Area> _areas = [];

  @override
  void initState() {
    super.initState();
    _loadAreas();
  }

  Future<void> _loadAreas({bool forceSync = false}) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      if (forceSync) {
        setState(() => _syncing = true);
       // await widget.syncService.syncAreasIfNeeded();
        setState(() => _syncing = false);
      } else {
        // syncAreasIfNeeded hará la comprobación de versión y solo sincronizará si hace falta.
     //   await widget.syncService.syncAreasIfNeeded();
      }

    //  final local = await widget.repo.getAreas();
    //  setState(() => _areas = local);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _body() {
    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_error != null) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Error: $_error'),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: () => _loadAreas(forceSync: true), child: const Text('Reintentar (forzar)')),
        ]),
      );
    }

    if (_areas.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('No hay áreas disponibles'),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: () => _loadAreas(forceSync: true), child: const Text('Cargar catálogo')),
        ]),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: _areas.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final a = _areas[i];
        return ListTile(
          leading: Icon(a.activo ? Icons.check_circle : Icons.block, color: a.activo ? Colors.green : Colors.grey),
          title: Text(a.nombre),
          subtitle: Text(a.fechaActualizacion.toIso8601String()),
          onTap: () => Navigator.of(context).pop(a),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16),
                child: Row(children: [
                  const Expanded(child: Text('Seleccionar Área', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
                  if (_syncing) const SizedBox(width: 8),
                  if (_syncing) const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                  IconButton(onPressed: () => _loadAreas(forceSync: true), icon: const Icon(Icons.sync), tooltip: 'Forzar sincronización'),
                  IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
                ]),
              ),
              const Divider(height: 1),
              Expanded(child: _body()),
            ],
          ),
        ),
      ),
    );
  }
}

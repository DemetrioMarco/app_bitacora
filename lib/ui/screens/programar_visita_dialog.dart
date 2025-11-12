// lib/ui/screens/programar_visita_dialog.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/bitacora.dart';

class ProgramarVisitaForm extends StatefulWidget {
  const ProgramarVisitaForm({super.key});

  @override
  State<ProgramarVisitaForm> createState() => _ProgramarVisitaFormState();
}

class _ProgramarVisitaFormState extends State<ProgramarVisitaForm> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();
  String? _selectedArea;
  String? _selectedEquipo;
  String? _selectedTipo;
  String? _selectedFrecuencia;
  String? _selectedLinea;

  // Catálogos en duro (reemplazar por repo después)
  final List<String> _areas = ['Planta A', 'Planta B', 'Almacén'];
  final List<String> _equipos = ['Equipo 1', 'Equipo 2', 'Equipo 3'];
  final List<String> _tipos = ['Rutina', 'Correctiva', 'Inspección'];
  final List<String> _frecuencias = ['Diaria', 'Semanal', 'Quincenal', 'Mensual'];
  final List<String> _linea = ['1','2','3','4'];

  int _nextId() => DateTime.now().millisecondsSinceEpoch.remainder(1000000);

  @override
  void initState() {
    super.initState();
    _selectedArea = _areas.first;
    _selectedEquipo = _equipos.first;
    _selectedTipo = _tipos.first;
    _selectedFrecuencia = _frecuencias[2];
    _selectedLinea = _linea.first;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() => _selectedDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            _selectedDate.hour,
            _selectedDate.minute,
          ));
    }
  }

  void _onProgramar() {
    if (!_formKey.currentState!.validate()) return;

    final newBitacora = Bitacora(
      id: _nextId(),
      fecha: _selectedDate,
      area: _selectedArea!,
      equipo: _selectedEquipo!,
      tipoLimpieza: _selectedTipo!,
      frecuencia: _selectedFrecuencia!,
      linea: _selectedLinea!,
    );

    // Si quisieras: aquí insertar directamente en bitacoraRepo.insert(...)
    Navigator.of(context).pop(newBitacora);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 12,
          top: 12,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('Programar visita', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: Text('Fecha: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}')),
                TextButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Seleccionar'),
                  onPressed: _pickDate,
                )
              ]),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedEquipo,
                items: _equipos.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => _selectedEquipo = v),
                decoration: const InputDecoration(labelText: 'Seleccione equipo'),
                validator: (v) => v == null || v.isEmpty ? 'Seleccione equipo' : null,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedTipo,
                items: _tipos.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => _selectedTipo = v),
                decoration: const InputDecoration(labelText: 'Tipo de limpieza'),
                validator: (v) => v == null || v.isEmpty ? 'Seleccione tipo de limpieza' : null,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedFrecuencia,
                items: _frecuencias.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => _selectedFrecuencia = v),
                decoration: const InputDecoration(labelText: 'Frecuencia'),
                validator: (v) => v == null || v.isEmpty ? 'Seleccione frecuencia' : null,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedLinea,
                items: _linea.map( (e) => DropdownMenuItem(value: e, child: Text(e))).toList(), 
                onChanged: (v) => setState(() => _selectedLinea = v),
                decoration: const InputDecoration(labelText: 'Línea'),
                validator: (v) => v == null || v.isEmpty ? 'Seleccione línea' : null,
              ),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar'))),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton(onPressed: _onProgramar, child: const Text('Programar'))),
              ]),
              const SizedBox(height: 8),
            ]),
          ),
        ),
      ),
    );
  }
}


import 'package:app_bitacora/data/controller/cat_controller.dart';
import 'package:app_bitacora/data/controller/bitacora_controller.dart';
import 'package:app_bitacora/models/equipo.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// import '../../models/bitacora.dart';

class ProgramarVisitaForm extends StatefulWidget {
  const ProgramarVisitaForm({super.key});

  @override
  State<ProgramarVisitaForm> createState() => _ProgramarVisitaFormState();
}

class _ProgramarVisitaFormState extends State<ProgramarVisitaForm> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();
  Equipo? _selectedEquipo;
  // String? _selectedArea;
  // String? _selectedTipo;
  // String? _selectedFrecuencia;
  // String? _selectedLinea;

  // Repositorio
  final BitacoraController controller = BitacoraController();
  final CatalogController catController =  CatalogController();

  // Catálogos en duro (reemplazar por repo después)
  // final List<String> _areas = ['Líquidos', 'Planta', 'Almacén'];
  // final List<String> _tipos = ['Rutina', 'Correctiva', 'Inspección','Profunda'];
  // final List<String> _frecuencias = ['Por turno','Diaria', '2 veces a la semana', 'Semanal', 'Quincenal', 'Mensual','Trimestral', 'Semestral', 'Anual'];
  // final List<String> _linea = ['1','2','3','4'];
  List<Equipo> _equipos = [];


  @override
  void initState() {
    super.initState();
    // _selectedArea = _areas.first;
    // _selectedTipo = _tipos.first;
    // _selectedFrecuencia = _frecuencias[2];
    // _selectedLinea = _linea.first;
    _cargarEquipos();
  }

  Future<void> _cargarEquipos() async {
    final equipos = await catController.obtenerEquipos();
    setState(() {
      _equipos = equipos;
      _selectedEquipo = _equipos.isNotEmpty ? _equipos.first : null;
    });
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

  bool _saving = false;

  Future<void> _onProgramar() async {
    if(_saving) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    // final newBitacora = Bitacora(
    //   fecha: _selectedDate,
    //   equipoId: _selectedEquipo!.id ?? 1,
    //   equipo: _selectedEquipo!.nombre,
    //   area: _selectedArea!,
    //   tipoLimpieza: _selectedTipo!,
    //   frecuencia: _selectedFrecuencia!,
    //   linea: _selectedLinea!,
    // );

    try {
      final newBitacora = await catController.crearBitacora(_selectedEquipo!.id ?? 1, _selectedDate, '1');
      final saved = await controller.guardar(newBitacora!);
      if(!mounted) return;
      Navigator.of(context).pop(saved);
    } catch (e, st) {
      debugPrint('Error guardando bitácora: $e\n$st');

      if(!mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al guardar la visita'))
        );
      }
    } finally {
      if(mounted) setState(() => _saving = false );
    }

    

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
              DropdownButtonFormField<Equipo>(
                initialValue: _selectedEquipo,
                items: _equipos
                  .map((e) => DropdownMenuItem<Equipo>(
                    value: e, 
                    child: Text(e.nombre))
                  ).toList(),
                onChanged: (v) => setState(() => _selectedEquipo = v),
                decoration: const InputDecoration(labelText: 'Seleccione equipo'),
                validator: (v) => v == null ? 'Seleccione equipo' : null,
              ),

              // DropdownButtonFormField<String>(
              //   initialValue: _selectedArea,
              //   items: _areas
              //     .map((e) => DropdownMenuItem<String>(
              //       value: e, 
              //       child: Text(e))
              //     ).toList(),
              //   onChanged: (v) => setState(() => _selectedArea = v),
              //   decoration: const InputDecoration(labelText: 'Seleccione área'),
              //   validator: (v) => v == null ? 'Seleccione área' : null,
              // ),

              // const SizedBox(height: 8),
              // DropdownButtonFormField<String>(
              //   initialValue: _selectedLinea,
              //   items: _linea.map( (e) => DropdownMenuItem(value: e, child: Text(e))).toList(), 
              //   onChanged: (v) => setState(() => _selectedLinea = v),
              //   decoration: const InputDecoration(labelText: 'Sub-Area / Línea'),
              //   validator: (v) => v == null || v.isEmpty ? 'Seleccione Sub-área / línea' : null,
              // ),

              // const SizedBox(height: 8),
              // DropdownButtonFormField<String>(
              //   initialValue: _selectedTipo,
              //   items: _tipos.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              //   onChanged: (v) => setState(() => _selectedTipo = v),
              //   decoration: const InputDecoration(labelText: 'Tipo de limpieza'),
              //   validator: (v) => v == null || v.isEmpty ? 'Seleccione tipo de limpieza' : null,
              // ),

              // const SizedBox(height: 8),
              // DropdownButtonFormField<String>(
              //   initialValue: _selectedFrecuencia,
              //   items: _frecuencias.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              //   onChanged: (v) => setState(() => _selectedFrecuencia = v),
              //   decoration: const InputDecoration(labelText: 'Frecuencia'),
              //   validator: (v) => v == null || v.isEmpty ? 'Seleccione frecuencia' : null,
              // ),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar'))),
                const SizedBox(width: 12),
                Expanded(child: 
                  ElevatedButton(
                    onPressed: _saving ? null : _onProgramar, 
                    child: _saving
                      ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2,),)
                      : const Text('Programar'))),
              ]),
              const SizedBox(height: 8),
            ]),
          ),
        ),
      ),
    );
  }
}

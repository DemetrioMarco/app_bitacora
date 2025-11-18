// lib/ui/screens/bitacora_form.dart
import 'package:app_bitacora/data/controller/bitacora_controller.dart';
import 'package:app_bitacora/data/controller/cat_controller.dart';
import 'package:app_bitacora/models/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/bitacora.dart';
import '../../models/check_item.dart';
import '../screens/widgets/checklist_item.dart';
import 'observacion_dialog.dart';
import 'signature_screen.dart';



class BitacoraFormScreen extends StatefulWidget {
  final Bitacora bitacora;

  const BitacoraFormScreen({super.key, required this.bitacora});

  @override
  State<BitacoraFormScreen> createState() => _BitacoraFormScreenState();
}

class _BitacoraFormScreenState extends State<BitacoraFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _fecha;
  late String _area;
  late String _equipo;
  late int _equipoId;
  late String _tipoLimpieza;
  late String _frecuencia;
  late String _linea;
  final TextEditingController _ejecutaCtrl = TextEditingController();
  final TextEditingController _verificaCtrl = TextEditingController();
  final TextEditingController _liberaCtrl = TextEditingController();

  List<CheckItem> _checklist = [];
  final CatalogController catalogController = CatalogController( );
  final BitacoraController bitacoraController = BitacoraController();

  @override
  void initState() {
    super.initState();
    _fecha = widget.bitacora.fecha;
    _area = widget.bitacora.area;
    _equipo = widget.bitacora.equipo;
    _equipoId = widget.bitacora.equipoId;
    _tipoLimpieza = widget.bitacora.tipoLimpieza;
    _frecuencia = widget.bitacora.frecuencia;
    _linea = widget.bitacora.linea;

    _ejecutaCtrl.text = '';
    _verificaCtrl.text = '';
    _liberaCtrl.text = '';

    _loadChecklist();
  }

  void _loadChecklist() async {
  
    final items = await catalogController.obtenerCheckItem(widget.bitacora.equipoId);
    setState(() {
      _checklist = items;
    });
  }

  Future<void> _openObservacion(CheckItem item) async {
    final newObs = await showDialog<String?>(
      context: context,
      builder: (_) => ObservacionDialog(initialText: item.observacion),
    );

    if (newObs != null) {
      setState(() {
        item.observacion = newObs;
      });
    }
  }

  Future<void> _openSignature() async {
    final signatureData = await Navigator.of(context).push<String?>(
      MaterialPageRoute(builder: (_) => const SignatureScreen()),
    );

    if (signatureData != null) {
      // TODO: guardar signatureData en bitácora (ruta o base64)
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Firma guardada (temporal)')));
    }
  }

  void _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    final updated = Bitacora(
      id: widget.bitacora.id,
      fecha: _fecha,
      area: _area,
      equipo: _equipo,
      equipoId: _equipoId,
      tipoLimpieza: _tipoLimpieza,
      frecuencia: _frecuencia,
      linea: _linea,
    );

    // TODO: persistir updated y checklist en repo/DB
    final List<ChecklistItem> cli = _checklist.map((item){
      return ChecklistItem(
        bitacoraId: widget.bitacora.id!, 
        elementoId: item.id, 
        titulo: item.title,
        checked: item.checked,
        observacion: item.observacion,
        orden: item.orden
        );
    }).toList();


    await catalogController.guardarChecklist(cli);

    if(!mounted) return;

    Navigator.of(context).pop({
      'bitacora': updated,
      'checklist': _checklist.map((c) => c.toMap()).toList(),
    });
  }

  @override
  void dispose() {
    _ejecutaCtrl.dispose();
    _verificaCtrl.dispose();
    _liberaCtrl.dispose();
    super.dispose();
  }

  Widget _readOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.black54)),
        const SizedBox(width: 4),
        Text(value),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd/MM/yy').format(_fecha);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bitácora de limpieza'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _onSave,
            tooltip: 'Guardar',
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              LayoutBuilder(builder: (context, constraints) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _readOnlyField('Fecha:', dateStr),
                            const SizedBox(height: 10),
                            _readOnlyField('Equipo:', _equipo),
                          ],
                        ),
                    
                      const SizedBox(width: 10),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _readOnlyField('Área:', _area),
                            const SizedBox(height: 10),
                            _readOnlyField('Tipo de limpieza:', _tipoLimpieza),
                          ],
                        ),
                      const SizedBox(width: 10),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _readOnlyField('Línea:', _linea),
                            const SizedBox(height: 10),
                            _readOnlyField('Frecuencia:', _frecuencia),
                          ],
                        ),
                     
                    ],
                  )),
               const Divider(),
              ..._checklist.map((item) {
                return ChecklistItemWidget(
                  item: item,
                  onChanged: (checked) {
                    setState(() => item.checked = checked);
                  },
                  onEditObservacion: () => _openObservacion(item),
                );
              }).toList(),
              const Divider(),
              TextFormField(
                controller: _ejecutaCtrl,
                decoration: const InputDecoration(labelText: 'EJECUTÓ'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _verificaCtrl,
                decoration: const InputDecoration(labelText: 'VERIFICÓ'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _liberaCtrl,
                decoration: const InputDecoration(labelText: 'LIBERACIÓN'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _openSignature,
                    icon: const Icon(Icons.edit),
                    label: const Text('Firma'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancelar'),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _onSave,
                    child: const Text('Guardar'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

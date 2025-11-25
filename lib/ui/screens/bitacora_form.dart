import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/data/controller/bitacora_controller.dart';
import '/data/controller/cat_controller.dart';
import '/models/model.dart';
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

  bool _isReadOnly = false;

  final TextEditingController _ejecutaCtrl = TextEditingController();
  final TextEditingController _verificaCtrl = TextEditingController();
  final TextEditingController _liberaCtrl = TextEditingController();

  bool _ejecutaFirmado = false;
  bool _verificaFirmado = false;
  bool _liberaFirmado = false;

  String? _firmaEjecutoBase64;
  String? _firmaVerificoBase64;
  String? _firmaLiberaBase64;

  List<CheckItem> _checklist = [];
  final CatalogController catalogController = CatalogController();
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

    // _ejecutaCtrl.text = '';
    _verificaCtrl.text = '';
    _liberaCtrl.text = '';

    _loadChecklist();

    //Cargar firmas existentes (si las hay)
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSignatures());
  }

  Future<void> _loadSignatures() async {
    try {
      if (widget.bitacora.id == null) return;
      final int bitacoraId = widget.bitacora.id!;

      final dynamic result =
          await bitacoraController.obtenerSignature(bitacoraId);

      if (result == null) return;

      String? ejecuto;
      String? firmaEjecuto;
      String? verifico;
      String? firmaVerifico;
      String? firmaLibera;

      if (result is Map<String, dynamic>) {
       
        firmaEjecuto = result['firma_ejecuto'] as String?;
        firmaVerifico = result['firma_verifico'] as String?;
        firmaLibera = result['firma_libero'] as String?;
        ejecuto = result['ejecuto'] as String?;
        verifico = result['verifico'] as String?;
      } else {
        // Ajusta estos nombres a los de tu clase Signature
        ejecuto = result.ejecuto as String?;
        firmaEjecuto = result.firmaEjecuto as String?;
        verifico = result.verifico as String?;
        firmaVerifico = result.firmaVerifico as String?;
        firmaLibera = result.firmaLibero as String?;
      }

      setState(() {
        _ejecutaCtrl.text = ejecuto ?? '';
        _firmaEjecutoBase64 = firmaEjecuto;
        _verificaCtrl.text = verifico ?? '';
        _firmaVerificoBase64 = firmaVerifico;
        _firmaLiberaBase64 = firmaLibera;

        _ejecutaFirmado =
            (_firmaEjecutoBase64 != null && _firmaEjecutoBase64!.isNotEmpty);
        _verificaFirmado =
            (_firmaVerificoBase64 != null && _firmaVerificoBase64!.isNotEmpty);
        _liberaFirmado =
            (_firmaLiberaBase64 != null && _firmaLiberaBase64!.isNotEmpty);
      });
    } catch (e, st) {
      debugPrint('Error loading signatures: $e\n$st');
    }
  }

  void _loadChecklist() async {
    
    final List<ChecklistItem> result = await bitacoraController.obtenerChecklistItem(widget.bitacora.id!);

    if(result.isNotEmpty ){
 
      final items = result.map((item)=> CheckItem(
        id: item.id!, 
        title: item.titulo, 
        observacion: item.observacion,
        checked: item.checked,
        orden: item.orden!
        )).toList();

      setState(() {
          _checklist = items;
          _isReadOnly = true;
        });


    }else{
    final items =
        await catalogController.obtenerCheckItem(widget.bitacora.equipoId);

        setState(() {
          _checklist = items;
          _isReadOnly = false;
        });
    }

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

  Future<void> _openSignatureWithName({
    required String nombre,
    required String rol,
    required void Function(String base64) onSigned,
  }) async {
    final String? signatureBase64 = await Navigator.of(context).push<String?>(
      MaterialPageRoute(
        builder: (_) => SignatureScreen(
          nombre: nombre,
          rol: rol,
          bitacoraId: widget.bitacora.id!,
        ),
      ),
    );

    if (signatureBase64 == null) return;

    setState(() {
      onSigned(signatureBase64);
    });



    if(!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Firma de $nombre guardada')),
    );
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
    final List<ChecklistItem> cli = _checklist.map((item) {
      return ChecklistItem(
          bitacoraId: widget.bitacora.id!,
          elementoId: item.id,
          titulo: item.title,
          checked: item.checked,
          observacion: item.observacion,
          orden: item.orden);
    }).toList();

    await catalogController.guardarChecklist(cli);

    if (!mounted) return;

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
        Text(label, style: const TextStyle(color: Colors.black54)),
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
              LayoutBuilder(
                  builder: (context, constraints) => Row(
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
                              _readOnlyField(
                                  'Tipo de limpieza:', _tipoLimpieza),
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
                  onChanged: _isReadOnly
                  ? null
                  : (checked) {
                    setState(() => item.checked = checked);
                  },
                  onEditObservacion: _isReadOnly
                  ? null
                  : () => _openObservacion(item),
                );
              }).toList(),
              const Divider(),

              // EJECUTÓ
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ejecutaCtrl,
                      decoration: const InputDecoration(labelText: 'EJECUTÓ'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    color: _ejecutaFirmado ? Colors.green : Colors.grey,
                    onPressed: () {
                      _openSignatureWithName(
                        nombre: _ejecutaCtrl.text, 
                        rol: 'EJECUTO',
                        onSigned: (base64) {
                          _firmaEjecutoBase64 = base64;
                          _ejecutaFirmado = _firmaEjecutoBase64 != null &&
                              _firmaEjecutoBase64!.isNotEmpty;
                        },
                      );
                    },
                  ),
                ],
              ),

              // VERIFICÓ
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _verificaCtrl,
                      decoration: const InputDecoration(labelText: 'VERIFICÓ'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    color: _verificaFirmado ? Colors.green : Colors.grey,
                    onPressed: () {
                      _openSignatureWithName(
                        nombre: _verificaCtrl.text,
                        rol: 'VERIFICO',
                        onSigned: (base64) {
                          _firmaVerificoBase64 = base64;
                          _verificaFirmado = _firmaVerificoBase64 != null &&
                              _firmaVerificoBase64!.isNotEmpty;
                        },
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // LIBERACIÓN
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _liberaCtrl,
                      decoration:
                          const InputDecoration(labelText: 'LIBERACIÓN'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    color: _liberaFirmado ? Colors.green : Colors.grey,
                    onPressed: () {
                      _openSignatureWithName(
                        nombre: _liberaCtrl.text,
                        rol: 'LIBERO',
                        onSigned: (base64) {
                          _firmaLiberaBase64 = base64;
                          _liberaFirmado = _firmaLiberaBase64 != null &&
                              _firmaLiberaBase64!.isNotEmpty;
                        },
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
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

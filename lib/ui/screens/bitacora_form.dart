import 'package:app_bitacora/provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../screens/widgets/checklist_item.dart';

import '/data/controller/controller.dart';
import '/models/model.dart';
import 'widgets/observacion_dialog.dart';
import 'screens.dart';

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
  bool _photoTaken = false;
  final ImagePicker _picker = ImagePicker();
  String? _photoPath;

  final TextEditingController _ejecutaCtrl = TextEditingController();
  final TextEditingController _verificaCtrl = TextEditingController();

  bool _ejecutaFirmado = false;
  bool _verificaFirmado = false;

  String? _firmaEjecutoBase64;
  String? _firmaVerificoBase64;

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

    _loadChecklist();

    //Cargar firmas existentes (si las hay)
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSignatures());
  }


  Future<void> _takePhoto() async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        preferredCameraDevice: CameraDevice.rear
      );

      if(!mounted) return;

      if(picked == null){
        // Usuario canceló la cámara
        return;
      }

      setState(() {
        _photoTaken = true;
        _photoPath = picked.path;

        debugPrint(_photoPath);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto tomado correctametne'))
      );
    } catch (e, st) {
      debugPrint('Error al abrir cámara / tomar foto: $e\n$st');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al tomar la foto'))
      );
    }
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
    //  String? firmaLibera;

      if (result is Map<String, dynamic>) {
       
        firmaEjecuto = result['firma_ejecuto'] as String?;
        firmaVerifico = result['firma_verifico'] as String?;
    //    firmaLibera = result['firma_libero'] as String?;
        ejecuto = result['ejecuto'] as String?;
        verifico = result['verifico'] as String?;
      } else {
        // Ajusta estos nombres a los de tu clase Signature
        ejecuto = result.ejecuto as String?;
        firmaEjecuto = result.firmaEjecuto as String?;
        verifico = result.verifico as String?;
        firmaVerifico = result.firmaVerifico as String?;
    //    firmaLibera = result.firmaLibero as String?;
      }

      setState(() {
        _ejecutaCtrl.text = ejecuto ?? '';
        _firmaEjecutoBase64 = firmaEjecuto;
        _verificaCtrl.text = verifico ?? '';
        _firmaVerificoBase64 = firmaVerifico;
        // _firmaLiberaBase64 = firmaLibera;

        _ejecutaFirmado =
            (_firmaEjecutoBase64 != null && _firmaEjecutoBase64!.isNotEmpty);
        _verificaFirmado =
            (_firmaVerificoBase64 != null && _firmaVerificoBase64!.isNotEmpty);
        // _liberaFirmado =
        //     (_firmaLiberaBase64 != null && _firmaLiberaBase64!.isNotEmpty);
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

    if (!mounted) return;

    setState(() {
      onSigned(signatureBase64);
    });

    try {
      final bitProvider = Provider.of<BitacoraProvider>(context, listen: false);
      await bitProvider.cargarBitacoras();
    } catch (e, st) {
      if(kDebugMode) debugPrint('Error actualizando provider tras firma: $e\n$st');
    }


    if(!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Firma de $nombre guardada')),
    );
  }

  void _onSave() async {

    if (_isReadOnly) return;

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
      itemMonday: widget.bitacora.itemMonday,
      foto: _photoPath
    );

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
    await bitacoraController.actualizarBitacora(updated);

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
            onPressed: _isReadOnly ? null : _onSave,
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _readOnlyField('Fecha:', dateStr),
                                const SizedBox(height: 10),
                                _readOnlyField('Equipo:', _equipo),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _readOnlyField('Área:', _area),
                                const SizedBox(height: 10),
                                _readOnlyField(
                                    'Tipo de limpieza:', _tipoLimpieza),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _readOnlyField('Sub-área / Línea:', _linea),
                                const SizedBox(height: 10),
                                _readOnlyField('Frecuencia:', _frecuencia),
                              ],
                            ),
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

              Row(
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(), 
                    child: const Text('Cancelar')
                  ),
                 const Spacer(),
                 SizedBox(
                  width: 56,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      
                    ),
                    onPressed: _takePhoto,
                    child: Icon(Icons.camera_alt,
                      color: _photoTaken ? Colors.greenAccent : Colors.blue
                    ),
                  ),
                  ),            
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _isReadOnly ? null : _onSave,
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

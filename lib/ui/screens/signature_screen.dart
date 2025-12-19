import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import '/data/controller/bitacora_controller.dart';
import '../../models/model.dart';

class SignatureScreen extends StatefulWidget {
  final String nombre;
  final String rol;
  final int bitacoraId;

  const SignatureScreen({
    Key? key, 
    required this.nombre, 
    required this.rol, 
    required this.bitacoraId
  }) : super(key: key);

  @override
  State<SignatureScreen> createState() => _SignatureScreenState();
}

class _SignatureScreenState extends State<SignatureScreen> {
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  final BitacoraController controller = BitacoraController();

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
  }

  Future<void> _onSaveSignature() async {
    if (_signatureController.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay firma para guardar')),
      );
      return;
    }

    final bytes = await _signatureController.toPngBytes();
    if (bytes == null) {

      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo generar la imagen')),
      );
      return;
    }

    final String base64String = base64Encode(bytes);
    if(!mounted) return;

    final Firma? result = await controller.obtenerSignature(widget.bitacoraId);

    Firma firma;

    if( result == null ){
      // Crear una nueva Firma
      firma = Firma(
        bitacoraId:  widget.bitacoraId,
        ejecuto: widget.nombre,
        firmaEjecuto: base64String
      );
      await controller.guardarFirma(firma);
    }else{
      // Usar firma existente
      firma = result;

      switch(widget.rol){
        case 'VERIFICO':
          firma.verifico = widget.nombre;
          firma.firmaVerifico = base64String;
          await controller.agregarFirma(firma);
          break;
        
        default:
          debugPrint("Rol desconocido: ${widget.rol}");
          break;

      }

    }
    
    if(!mounted) return;
    Navigator.of(context).pop(base64String);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firma de ${widget.nombre}'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            Text(
              widget.nombre,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: 
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  color: Colors.white,
                ),
                child: Signature(
                  controller: _signatureController,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _signatureController.clear(),
                      child: const Text('Limpiar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _onSaveSignature,
                      child: const Text('Guardar'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

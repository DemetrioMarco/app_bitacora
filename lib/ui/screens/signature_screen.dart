// lib/ui/screens/signature_screen.dart
import 'package:flutter/material.dart';
// si vas a usar package:signature, descomenta las importaciones y el código
// import 'package:signature/signature.dart';

class SignatureScreen extends StatefulWidget {
  const SignatureScreen({super.key});

  @override
  State<SignatureScreen> createState() => _SignatureScreenState();
}

class _SignatureScreenState extends State<SignatureScreen> {
  // ejemplo con package:signature:
  // final SignatureController _controller = SignatureController(penStrokeWidth: 2);

  @override
  void dispose() {
    // _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // orientada landscape mejor en tu app: podrías forzar orientación aquí si quieres
      appBar: AppBar(title: const Text('Firma')),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Container(
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(border: Border.all(color: Colors.black26)),
                height: 300,
                child: const Center(child: Text('Área para dibujar la firma\n(implementa con package:signature)')),
                // si usas signature:
                // child: Signature(controller: _controller, backgroundColor: Colors.white),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text('Borrar'),
                  onPressed: () {
                    // _controller.clear();
                    // si usas signature: _controller.clear();
                  },
                ),
                const Spacer(),
                ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text('Guardar'),
                  onPressed: () async {
                    // si usas signature:
                    // final data = await _controller.toPngBytes();
                    // final base64 = base64Encode(data!);
                    // Navigator.of(context).pop(base64);
                    Navigator.of(context).pop('SIGNATURE_PLACEHOLDER');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

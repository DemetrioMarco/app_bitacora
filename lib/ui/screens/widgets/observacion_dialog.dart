// lib/ui/screens/observacion_dialog.dart
import 'package:flutter/material.dart';

class ObservacionDialog extends StatefulWidget {
  final String? initialText;
  const ObservacionDialog({super.key, this.initialText});

  @override
  State<ObservacionDialog> createState() => _ObservacionDialogState();
}

class _ObservacionDialogState extends State<ObservacionDialog> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialText ?? '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Observación'),
      content: SingleChildScrollView(
        child: TextFormField(
          controller: _ctrl,
          maxLines: 6,
          decoration: const InputDecoration(
            hintText: 'Escribe la observación...',
            border: OutlineInputBorder(),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
        ElevatedButton(onPressed: () => Navigator.of(context).pop(_ctrl.text.trim()), child: const Text('Guardar')),
      ],
    );
  }
}

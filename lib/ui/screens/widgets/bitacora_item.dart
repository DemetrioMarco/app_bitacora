import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '/../models/bitacora.dart';

class BitacoraItem extends StatelessWidget {
  final Bitacora bitacora;
  final VoidCallback? onTap;
  final VoidCallback? onShare;
  final VoidCallback? onEdit;
  final VoidCallback? onSend;
  final bool locked;
  final bool canSend;

  const BitacoraItem({
    super.key,
    required this.bitacora,
    this.onTap,
    this.onShare,
    this.onEdit,
    this.onSend,
    this.locked = false,
    this.canSend = false
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(DateFormat('dd/MM/yy').format(bitacora.fecha)),
        subtitle: Text('${bitacora.area} • ${bitacora.equipo}\n${bitacora.tipoLimpieza} • ${bitacora.frecuencia}'),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.check_circle, color: Colors.blue), onPressed: onShare),
            IconButton(icon: Icon(Icons.picture_as_pdf, color: locked ? Colors.green : Colors.grey), onPressed: onEdit),
            IconButton(icon: Icon(Icons.send, color: canSend ? Colors.blue : Colors.grey),onPressed: onSend)
          ],
        ),
      ),
    );
  }
}

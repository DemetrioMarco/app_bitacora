import 'package:app_bitacora/models/bitacora_api.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';



class BitacoraItem extends StatelessWidget {
  final BitacoraAPI bitacora;
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
        subtitle: Text('${bitacora.nombre} • ${bitacora.area}  \n${bitacora.tipoLimpieza} • ${bitacora.frecuencia}'),
        // subtitle: Text('Bitacora'),
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

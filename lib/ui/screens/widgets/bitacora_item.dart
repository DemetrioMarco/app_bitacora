// lib/ui/widgets/bitacora_item.dart
import 'package:flutter/material.dart';
import '/../models/bitacora.dart';
import 'package:intl/intl.dart';

class BitacoraItem extends StatelessWidget {
  final Bitacora bitacora;
  final VoidCallback? onTap;
  final VoidCallback? onShare;
  final VoidCallback? onEdit;

  const BitacoraItem({
    super.key,
    required this.bitacora,
    this.onTap,
    this.onShare,
    this.onEdit,
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
            IconButton(icon: const Icon(Icons.edit), onPressed: onShare),
            IconButton(icon: const Icon(Icons.check_circle), onPressed: onEdit),
          ],
        ),
      ),
    );
  }
}

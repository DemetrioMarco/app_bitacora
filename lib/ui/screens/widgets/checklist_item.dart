// lib/ui/widgets/checklist_item_widget.dart
import 'package:flutter/material.dart';
import '../../../models/check_item.dart';

typedef OnCheckedChanged = void Function(bool checked);

class ChecklistItemWidget extends StatelessWidget {
  final CheckItem item;
  final OnCheckedChanged? onChanged;
  final VoidCallback? onEditObservacion;

  const ChecklistItemWidget({
    super.key,
    required this.item,
    this.onChanged,
    this.onEditObservacion,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      leading: Checkbox(
        value: item.checked,
        onChanged: onChanged == null
          ? null
          : (v) => onChanged!(v ?? false),
      ),
      title: Text(item.title),
      subtitle: item.observacion != null && item.observacion!.isNotEmpty
          ? Text(item.observacion!, style: const TextStyle(color: Colors.black54))
          : null,
      trailing: IconButton(
        icon: Icon(Icons.edit, size: 20, color: onChanged == null ? Colors.grey : Colors.blueAccent,),
        onPressed: onEditObservacion,
      ),
    );
  }
}

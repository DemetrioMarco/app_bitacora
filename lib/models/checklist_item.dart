class ChecklistItem {
  final int? id;
  final int bitacoraId;
  final int elementoId;
  final String titulo;
  final bool checked;
  final String? observacion;
  final int? orden;

  ChecklistItem({
    this.id,
    required this.bitacoraId,
    required this.elementoId,
    required this.titulo,
    this.checked = false,
    this.observacion,
    this.orden,
  });

  factory ChecklistItem.fromMap(Map<String, dynamic> m) => ChecklistItem(
    id: m['id'] as int?,
    bitacoraId: m['bitacora_id'] as int,
    elementoId: m['elemento_id'] as int,
    titulo: m['titulo'] as String,
    checked: (m['checked'] as int) == 1,
    observacion: m['observacion'] as String?,
    orden: m['orden'] as int?,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'bitacora_id': bitacoraId,
    'elemento_id': elementoId,
    'titulo': titulo,
    'checked': checked ? 1 : 0,
    'observacion': observacion,
    'orden': orden,
  };
}
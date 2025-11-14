class EquipoElemento {
  final int? id;
  final int? equipoId;
  final int? elementoId;
  final int? orden;

  EquipoElemento({
    this.id, 
    required this.equipoId, 
    required this.elementoId, 
    required this.orden
  });

  factory EquipoElemento.fromMap(Map<String, dynamic> m) => EquipoElemento(
    id: m['id'] as int?,
    equipoId: m['equipo_id'] as int?,
    elementoId: m['elemento_id'] as int?,
    orden: m['orden'] as int?
  );

  Map<String, dynamic> toMap() => {
    'id':id,
    'equipo_id':equipoId,
    'elemento_id':elementoId,
    'orden':orden
  };

}
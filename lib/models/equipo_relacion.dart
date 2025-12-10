class EquipoRelacion {
  final int? id;
  final int? equipoId;
  final int? areaId;
  final int? subAreaId;
  final int? frecuenciaId;
  final int? tipoLimpiezaId;

  EquipoRelacion({
    this.id, 
    required this.equipoId, 
    required this.areaId, 
    required this.subAreaId, 
    required this.frecuenciaId, 
    required this.tipoLimpiezaId,
  });

  factory EquipoRelacion.fromMap(Map<String, dynamic> m) => EquipoRelacion(
    id: m['id'] as int?,
    equipoId: m['equipo_id'] as int?, 
    areaId: m['area_id'] as int?, 
    subAreaId: m['sub_area_id'] as int?, 
    frecuenciaId: m['frecuencia_id'] as int?, 
    tipoLimpiezaId: m['tipo_limpieza_id'] as int?
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'equipo_id': equipoId,
    'area_id': areaId,
    'sub_area_id': subAreaId,
    'frecuencia_id': frecuenciaId,
    'tipo_limpieza_id': tipoLimpiezaId
  };
}
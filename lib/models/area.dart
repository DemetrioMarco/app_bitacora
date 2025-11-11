class Area {
  final int id;
  final String nombre;
  final bool activo;
  final DateTime fechaCreacion;
  final DateTime fechaActualizacion;

  Area({
    required this.id,
    required this.nombre,
    required this.activo,
    required this.fechaCreacion,
    required this.fechaActualizacion,
  });

  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      nombre: json['nombre'] ?? '',
      activo: int.tryParse(json['activo']?.toString() ?? '0') == 1,
      fechaCreacion: json['fecha_creacion'] != null
          ? DateTime.parse(json['fecha_creacion'])
          : DateTime.now(),fechaActualizacion: json['fecha_actualizacion'] != null
          ? DateTime.parse(json['fecha_actualizacion'])
          : DateTime.now(),
    );
}


  Map<String, dynamic> toJson() {
  return {
    'id': id,
    'nombre': nombre,
    'activo': activo ? 1 : 0,
    'fecha_creacion': fechaCreacion.toIso8601String(),
    'fecha_actualizacion': fechaActualizacion.toIso8601String(),
  };
}

}

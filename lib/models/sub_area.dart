class SubArea {
  final int id;
  final String nombre;
  final bool activo;
  final DateTime fechaCreacion;
  final DateTime fechaActualizacion;

  SubArea({
    required this.id,
    required this.nombre,
    required this.activo,
    required this.fechaCreacion,
    required this.fechaActualizacion,
  });

  factory SubArea.fromJson(Map<String, dynamic> json) {
    return SubArea(
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
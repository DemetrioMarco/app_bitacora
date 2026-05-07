class EquipoAPI {
  final int id;
  final String nombre;
  final String? descripcion;
  final String? area;
  final String? subarea;
  final String? frecuencia;
  final String? tipo;
  final String? tipoLimpieza;

  EquipoAPI({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.area,
    this.subarea,
    this.frecuencia,
    this.tipo,
    this.tipoLimpieza,
  });

  // Mapeo EXACTO con las columnas de tu CREATE TABLE y el JSON
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'area': area,
      'subarea': subarea,
      'frecuencia': frecuencia,
      'tipo': tipo,
      'tipoLimpieza': tipoLimpieza,
    };
  }

  factory EquipoAPI.fromMap(Map<String, dynamic> map) {
    return EquipoAPI(
      id: int.parse(map['id'].toString()),
      nombre: map['nombre'] as String,
      descripcion: map['descripcion'] as String?,
      area: map['area'] as String?,
      subarea: map['subarea'] as String?,
      frecuencia: map['frecuencia'] as String?,
      tipo: map['tipo'] as String?,
      tipoLimpieza: map['tipoLimpieza'] as String?,
    );
  }
}

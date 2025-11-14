class Bitacora {
  final int? id;
  final DateTime fecha;
  final String area;
  final String equipo;
  final String tipoLimpieza;
  final String frecuencia;
  final String linea;

  Bitacora({
    this.id,
    required this.fecha,
    required this.area,
    required this.equipo,
    required this.tipoLimpieza,
    required this.frecuencia,
    required this.linea,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fecha': fecha.toIso8601String(),
      'area': area,
      'equipo': equipo,
      'tipo_limpieza': tipoLimpieza,
      'frecuencia': frecuencia,
      'linea':linea
    };
  }

  factory Bitacora.fromMap(Map<String, dynamic> m) {
    return Bitacora(
      id: m['id'] as int,
      fecha: DateTime.parse(m['fecha'] as String),
      area: m['area'] as String,
      equipo: m['equipo'] as String,
      tipoLimpieza: m['tipo_limpieza'] as String,
      frecuencia: m['frecuencia'] as String,
      linea: m['linea'] as String,
    );
  }
}

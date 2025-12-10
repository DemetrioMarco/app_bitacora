class TipoLimpieza {
    int? id;
    String nombre;
    bool activo;
    DateTime fechaCreacion;

    TipoLimpieza({
        this.id,
        required this.nombre,
        required this.activo,
        required this.fechaCreacion,
    });

    factory TipoLimpieza.fromJson(Map<String, dynamic> json) => TipoLimpieza(
        id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
        nombre: json["nombre"],
        activo: int.tryParse(json['activo']?.toString() ?? '0') == 1,
      fechaCreacion: DateTime.parse(json['fecha_creacion']),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "nombre": nombre,
        "activo": activo ? 1 : 0,
        "fecha_creacion": fechaCreacion.toIso8601String(),
    };
}

class CatalogoVersion {
    String id;
    String tablaNombre;
    String version;
    DateTime fechaActualizacion;

    CatalogoVersion({
        required this.id,
        required this.tablaNombre,
        required this.version,
        required this.fechaActualizacion,
    });

    factory CatalogoVersion.fromJson(Map<String, dynamic> json) => CatalogoVersion(
        id: json["id"],
        tablaNombre: json["tabla_nombre"],
        version: json["version"],
        fechaActualizacion: DateTime.parse(json["fecha_actualizacion"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "tabla_nombre": tablaNombre,
        "version": version,
        "fecha_actualizacion": fechaActualizacion.toIso8601String(),
    };
}
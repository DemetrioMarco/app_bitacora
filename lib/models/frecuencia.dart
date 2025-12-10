class Frecuencia{
  int? id;
  String nombre;
  
  Frecuencia({
    this.id,
    required this.nombre
  });

  factory Frecuencia.fromJson(Map<String, dynamic> json) => Frecuencia(
    id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
    nombre: json["nombre"]
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "nombre": nombre,
  };
}
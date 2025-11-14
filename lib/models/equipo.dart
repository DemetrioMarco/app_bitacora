class Equipo {
  final int? id;
  final String nombre;

  Equipo({
    this.id, 
    required this.nombre
  });

  factory Equipo.fromMap(Map<String, dynamic> m) => Equipo(
    id: m['id'] as int?, 
    nombre: m['nombre'] as String
  );

  Map<String, dynamic> toMap() => {
    'id': id, 
    'nombre': nombre
  };
}
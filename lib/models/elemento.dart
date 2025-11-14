class Elemento {
  final int? id;
  final String nombre;

  Elemento({
    this.id, 
    required this.nombre,
  });

  factory Elemento.fromMap(Map<String, dynamic> m) => Elemento(
    id: m['id'] as int?,
    nombre: m['nombre'] as String,
  );

  Map<String, dynamic> toMap() => {
    'id': id, 
    'nombre': nombre,
  };
}
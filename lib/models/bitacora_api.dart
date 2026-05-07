class BitacoraAPI {
  final int? id;
  final int equipoId;
  final DateTime fecha;
  final int itemMonday; 
  String? pdf; 
  String? photo; 

  BitacoraAPI({
    this.id,
    required this.equipoId,
    required this.itemMonday,
    required this.fecha,
    this.pdf,
    this.photo
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'equipo_id': equipoId,    // Coincide con SQL
      'item_monday': itemMonday, // Coincide con SQL
      'fecha': fecha.toIso8601String(),
      'pdf': pdf,                // Coincide con SQL
      'foto': photo,             // Coincide con SQL
    };
  }

  factory BitacoraAPI.fromMap(Map<String, dynamic> map) {
    return BitacoraAPI(
      id: map['id'] as int?,
      equipoId: map['equipo_id'] as int,
      fecha: DateTime.parse(map['fecha'] as String),
      itemMonday: int.parse(map['item_monday'].toString()),
      pdf: map['pdf'] as String?,
      photo: map['foto'] as String?,
    );
  }
}

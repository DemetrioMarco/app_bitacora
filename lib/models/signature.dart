class Signature {
  final int? id;
  final int bitacoraId;
  final String? firmaEjecuto;
  final String? firmaVerifico;
  final String? firmaLibero;

  Signature({
    this.id,
    required this.bitacoraId,
    this.firmaEjecuto,
    this.firmaVerifico,
    this.firmaLibero,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'bitacora_id': bitacoraId,
      'firma_ejecuto': firmaEjecuto,
      'firma_verifico': firmaVerifico,
      'firma_libero': firmaLibero
    };
  }

  factory Signature.fromMap(Map<String, Object?> m) {
    return Signature(
      id: m['id'] as int?,
      bitacoraId: m['bitacora_id'] as int,
      firmaEjecuto: m['firma_ejecuto'] as String?,
      firmaVerifico: m['firma_verifico'] as String?,
      firmaLibero: m['firma_libero'] as String?
    );
  }
}

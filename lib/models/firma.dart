class Firma {
  final int? id;
  final int bitacoraId;
  String? ejecuto;
  String? firmaEjecuto;
  String? verifico;
  String? firmaVerifico;

  Firma({
    this.id,
    required this.bitacoraId,
    this.ejecuto,
    this.firmaEjecuto,
    this.verifico,
    this.firmaVerifico
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'bitacora_id': bitacoraId,
      'ejecuto': ejecuto,
      'firma_ejecuto': firmaEjecuto,
      'verifico': verifico,
      'firma_verifico': firmaVerifico
    };
  }

  factory Firma.fromMap(Map<String, Object?> m) {
    return Firma(
      id: m['id'] as int?,
      bitacoraId: m['bitacora_id'] as int,
      ejecuto: m['ejecuto'] as String?,
      firmaEjecuto: m['firma_ejecuto'] as String?,
      verifico: m['verifico'] as String?,
      firmaVerifico: m['firma_verifico'] as String?
    );
  }
}

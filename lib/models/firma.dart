class Firma {
  final int? id;
  final int bitacoraId;
  String? ejecuto;
  String? firmaEjecuto;
  String? verifico;
  String? firmaVerifico;
  String? libero;
  String? firmaLibero;

  Firma({
    this.id,
    required this.bitacoraId,
    this.ejecuto,
    this.firmaEjecuto,
    this.verifico,
    this.firmaVerifico,
    this.libero,
    this.firmaLibero,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'bitacora_id': bitacoraId,
      'ejecuto': ejecuto,
      'firma_ejecuto': firmaEjecuto,
      'verifico': verifico,
      'firma_verifico': firmaVerifico,
      'libero':libero,
      'firma_libero': firmaLibero
    };
  }

  factory Firma.fromMap(Map<String, Object?> m) {
    return Firma(
      id: m['id'] as int?,
      bitacoraId: m['bitacora_id'] as int,
      ejecuto: m['ejecuto'] as String?,
      firmaEjecuto: m['firma_ejecuto'] as String?,
      verifico: m['verifico'] as String?,
      firmaVerifico: m['firma_verifico'] as String?,
      libero: m['libero'] as String?,
      firmaLibero: m['firma_libero'] as String?
    );
  }
}

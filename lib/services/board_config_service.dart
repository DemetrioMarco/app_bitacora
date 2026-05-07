import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BoardConfigService {
  BoardConfigService._();
  static final BoardConfigService instance = BoardConfigService._();

  static const _storage = FlutterSecureStorage();
  static const _kBoardId = 'monday_board_id';

  /// Guarda el boardId en el almacenamiento seguro.
  Future<void> saveBoardId(int boardId) async {
    await _storage.write(key: _kBoardId, value: boardId.toString());
  }

  /// Recupera el boardId del almacenamiento seguro.
  /// Retorna null si no se encuentra.
  Future<int?> getBoardId() async {
    final rawId = await _storage.read(key: _kBoardId);
    if (rawId == null) return null;
    return int.tryParse(rawId);
  }

  /// Elimina el boardId del almacenamiento seguro.
  Future<void> deleteBoardId() async {
    await _storage.delete(key: _kBoardId);
  }
}

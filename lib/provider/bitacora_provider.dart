import 'package:flutter/foundation.dart';
import '../models/bitacora.dart';
import '../data/controller/bitacora_controller.dart';


class BitacoraProvider extends ChangeNotifier {
  final BitacoraController _controller = BitacoraController();

  List<Bitacora> _bitacoras = [];
  Bitacora? _bitacoraSeleccionada;

  List<Bitacora> get bitacoras => _bitacoras;
  Bitacora? get bitacoraSeleccionada => _bitacoraSeleccionada;



  /// Carga todas las bitácoras desde la BD
  Future<void> cargarBitacoras() async {
    _bitacoras = await _controller.obtenerTodas();
    notifyListeners(); // 🔄 Actualiza la UI que escucha este provider
  }

  /// Selecciona una bitácora específica (por ejemplo, para checklist)
  void seleccionarBitacora(Bitacora bitacora) {
    _bitacoraSeleccionada = bitacora;
    notifyListeners();
  }

  /// Limpia la selección (opcional)
  void limpiarSeleccion() {
    _bitacoraSeleccionada = null;
    notifyListeners();
  }

  /// Guarda o actualiza una bitácora
  Future<void> guardarBitacora(Bitacora bitacora) async {
    await _controller.guardar(bitacora);
    await cargarBitacoras(); // recarga lista después de guardar
  }
}

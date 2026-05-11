import 'package:app_bitacora/data/controller/bitacora_api_controller.dart';
import 'package:app_bitacora/data/controller/equipo_api_controller.dart';
import 'package:app_bitacora/models/bitacora_api.dart';
import 'package:flutter/foundation.dart';

class BitacoraProvider extends ChangeNotifier {
  final BitacoraAPIController _controller = BitacoraAPIController();
  final EquipoAPIController _equipoAPIController = EquipoAPIController();

  List<BitacoraAPI> _bitacoras = [];
  BitacoraAPI? _bitacoraSeleccionada;

  List<BitacoraAPI> get bitacoras => _bitacoras;
  BitacoraAPI? get bitacoraSeleccionada => _bitacoraSeleccionada;


  /// Carga todas las bitácoras desde la BD
  Future<void> cargarBitacoras() async {
    final lista = await _controller.getAllBitacorasLocal();

    for(var b in lista){
      final equipo = await _equipoAPIController.getEquipoLocalById(b.equipoId);
      if(equipo != null){
        b.nombreEquipo = equipo.nombre;
        b.area = equipo.area;
        b.subarea = equipo.subarea;
        b.frecuencia = equipo.frecuencia;
        b.tipo = equipo.tipo;
        b.tipoLimpieza = equipo.tipoLimpieza;
      }
    }

    _bitacoras = lista;
    notifyListeners(); // 🔄 Actualiza la UI que escucha este provider
  }

  /// Selecciona una bitácora específica (por ejemplo, para checklist)
  void seleccionarBitacora(BitacoraAPI bitacora) {
    _bitacoraSeleccionada = bitacora;
    notifyListeners();
  }

  /// Limpia la selección (opcional)
  void limpiarSeleccion() {
    _bitacoraSeleccionada = null;
    notifyListeners();
  }

  /// Guarda o actualiza una bitácora
  Future<void> guardarBitacora(BitacoraAPI bitacora) async {
    if(bitacora.id == null){
      await _controller.saveBitacoraLocal(bitacora);
    }else{
      await _controller.updateBitacoraLocal(bitacora);
    }
    await cargarBitacoras();
  }
}

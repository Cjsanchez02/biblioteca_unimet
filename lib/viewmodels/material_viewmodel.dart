import 'package:biblioteca_unimet/services/servicio_material.dart';
import 'package:flutter/material.dart';

class MaterialViewModel extends ChangeNotifier {
  final servicioMaterial _service = servicioMaterial();

  String _query = "";
  String _criterio = "Título"; // Criterio por defecto

  void actualizarFiltro(String text) {
    _query = text.toLowerCase();
    notifyListeners();
  }

  void actualizarCriterio(String? nuevoCriterio) {
    if (nuevoCriterio != null) {
      _criterio = nuevoCriterio;
      notifyListeners();
    }
  }

  String get criterio => _criterio;

  List<Map<String, dynamic>> filtrarMateriales(List<Map<String, dynamic>> listaCompleta) {
    if (_query.isEmpty) return listaCompleta;

    return listaCompleta.where((m) {
      String campoABuscar = "";
      
      if (_criterio == "Título") campoABuscar = (m['titulo'] ?? '').toString().toLowerCase();
      if (_criterio == "Autor") campoABuscar = (m['autor'] ?? '').toString().toLowerCase();
      if (_criterio == "Materia") campoABuscar = (m['materia'] ?? '').toString().toLowerCase();

      return campoABuscar.contains(_query);
    }).toList();
  }


  Future<bool> guardarMaterial({
    String? id,
    required String tipo,
    required String titulo,
    required String autor,
    required String materia,
    required int stock,
  }) async {
    try {
      final data = {
        'tipo': tipo,
        'titulo': titulo,
        'autor': autor,
        'materia': materia,
        'stock': stock,
        // Al crear, la calificación promedio empieza en 0.0
        if (id == null) 'calificacionPromedio': 0.0
      };

      if (id == null) {
        await _service.agregarMaterial(data);
      } else {
        await _service.editarMaterial(id, data);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> borrarMaterial(String id) async {
    await _service.eliminarMaterial(id);
  }
}
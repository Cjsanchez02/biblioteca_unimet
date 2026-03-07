import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum ModoEstadistica {
  solicitudesCarrera,  // Vuelve la carrera
  solicitudesMateria,  // Vuelve la materia
  calificacionMateria,
  calificacionMaterial
}

class EstadisticasViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ModoEstadistica _modoActual = ModoEstadistica.solicitudesCarrera;
  ModoEstadistica get modoActual => _modoActual;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  Map<String, double> _datosProcesados = {};
  Map<String, double> get datosProcesados => _datosProcesados;

  EstadisticasViewModel() {
    cargarDatos();
  }

  void cambiarModo(ModoEstadistica nuevoModo) {
    _modoActual = nuevoModo;
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_modoActual == ModoEstadistica.solicitudesCarrera || 
          _modoActual == ModoEstadistica.solicitudesMateria) {
        QuerySnapshot snapshot = await _firestore.collection('prestamos').get();
        _calcularPorcentajesSolicitudes(snapshot);
      } else {
        QuerySnapshot snapshot = await _firestore.collection('material_academico').get();
        _calcularPromediosCalificacion(snapshot);
      }
    } catch (e) {
      print("Error cargando estadísticas: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  // LÓGICA 1: Porcentajes de Solicitudes (Ahora por Carrera y Materia)
  void _calcularPorcentajesSolicitudes(QuerySnapshot snapshot) {
    Map<String, double> conteo = {};
    int total = 0;

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      
      // Elegimos por qué campo agrupar dependiendo de lo que elija el bibliotecario
      String clave = _modoActual == ModoEstadistica.solicitudesCarrera 
          ? (data['carrera'] ?? 'Sin Carrera') 
          : (data['materia'] ?? 'Sin Materia');
      
      conteo[clave] = (conteo[clave] ?? 0) + 1;
      total++;
    }

    if (total == 0) {
      _datosProcesados = {};
      return;
    }

    var ordenados = conteo.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    Map<String, double> finales = {};
    double sumaOtros = 0;

    for (int i = 0; i < ordenados.length; i++) {
      double porcentaje = (ordenados[i].value / total) * 100;
      if (i < 5) {
        finales[ordenados[i].key] = double.parse(porcentaje.toStringAsFixed(1));
      } else {
        sumaOtros += porcentaje;
      }
    }
    if (sumaOtros > 0) finales['Otros'] = double.parse(sumaOtros.toStringAsFixed(1));
    _datosProcesados = finales;
  }

  // LÓGICA 2: Promedio de Calificaciones
  void _calcularPromediosCalificacion(QuerySnapshot snapshot) {
    Map<String, Map<String, dynamic>> sumatorias = {};

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      
      String clave = _modoActual == ModoEstadistica.calificacionMateria 
          ? (data['materia'] ?? 'General') 
          : (data['titulo'] ?? 'Desconocido');
      
      double estrellas = (data['calificacionPromedio'] ?? 0).toDouble();

      if (!sumatorias.containsKey(clave)) {
        sumatorias[clave] = {'suma': 0.0, 'conteo': 0};
      }
      sumatorias[clave]!['suma'] += estrellas;
      sumatorias[clave]!['conteo'] += 1;
    }

    Map<String, double> promedios = {};
    sumatorias.forEach((key, val) {
      if (val['conteo'] > 0) {
        promedios[key] = val['suma'] / val['conteo'];
      }
    });

    var ordenados = promedios.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    Map<String, double> finales = {};
    for (int i = 0; i < ordenados.length && i < 5; i++) {
      finales[ordenados[i].key] = double.parse(ordenados[i].value.toStringAsFixed(1));
    }
    _datosProcesados = finales;
  }
}
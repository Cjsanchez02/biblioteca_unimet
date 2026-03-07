import 'package:flutter/material.dart';
import 'package:biblioteca_unimet/services/servicio_calificaciones.dart';

class CalificacionViewModel extends ChangeNotifier {
  final ServicioCalificaciones _servicio = ServicioCalificaciones();
  
  // Variable observable para bloquear el botón mientras guarda
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<bool> enviarCalificacion({
    required String materialId,
    required String transaccionId,
    required double estrellasLibro,
    required double estrellasProceso,
    required String comentario,
    required BuildContext context,
  }) async {
    // Activamos la carga y notificamos a la Vista (Observer)
    _isLoading = true;
    notifyListeners();

    try {
      await _servicio.registrarCalificacionCompleta(
        materialId: materialId,
        transaccionId: transaccionId,
        estrellasLibro: estrellasLibro,
        estrellasProceso: estrellasProceso,
        comentario: comentario,
      );
      
      _isLoading = false;
      notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Gracias por tu opinión!'), 
          backgroundColor: Colors.green
        ),
      );
      return true;

    } catch (e) {
      _isLoading = false;
      notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al enviar: $e'), 
          backgroundColor: Colors.red
        ),
      );
      return false;
    }
  }
}
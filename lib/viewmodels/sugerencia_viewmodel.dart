import 'package:flutter/material.dart';
import 'package:biblioteca_unimet/services/servicio_sugerencias.dart';

// Le ponemos HomeViewModel para que coincida con HomeView
class HomeViewModel extends ChangeNotifier {
  final ServicioSugerencias _servicio = ServicioSugerencias();

  Future<bool> enviarSugerencia(String texto, BuildContext context) async {
    if (texto.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No puedes enviar una sugerencia vacía'), 
          backgroundColor: Colors.red
        ),
      );
      return false;
    }

    try {
      await _servicio.enviarSugerencia(texto);
      return true; 
    } catch (e) {
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
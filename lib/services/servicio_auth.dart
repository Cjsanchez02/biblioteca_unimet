import 'package:firebase_auth/firebase_auth.dart';

class ServicioAuth {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> cerrarSesion() async {
    try {
      await _auth.signOut();
    } catch (e) {
      // No imprimas, lanza la excepción para que la vista la capture
      throw Exception('Error al cerrar sesión en el servidor');
    }
  }
}

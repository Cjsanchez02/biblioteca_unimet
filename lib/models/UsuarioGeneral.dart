import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UsuarioGeneral {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static bool validarLogin(String password) {
    return password.length >= 6;
  }

  static bool validarRegistro(String password) {
    return password.length >= 6 &&
        password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[a-z]')) &&
        password.contains(RegExp(r'[-!@#$%^&*(),.?":{}|_<>]'));
  }

  static String mensajeErrorLogin =
      "La contraseña debe tener al menos 6 caracteres";

  static String mensajeErrorRegistro =
      "La contraseña debe tener al menos 6 caracteres, una mayúscula, una minúscula y un carácter especial";

  Future<User?> iniciarSesion(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No existe un usuario con ese correo.');
      } else if (e.code == 'wrong-password') {
        print('La contraseña es incorrecta.');
      } else if (e.code == 'invalid-email') {
        print('El formato del correo no es válido.');
      }

      rethrow;
    } catch (e) {
      print('Error inesperado: $e');
      return null;
    }
  }

  Future<void> cerrarSesion() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Error al cerrar sesión');
    }
  }

  String? obtenerCorreoActual() {
    return _auth.currentUser?.email;
  }

  Future<User?> registrarUsuario(
    String email,
    String password,
    String nombre,
  ) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        // Actualizar nombre en Firebase Auth
        await userCredential.user!.updateDisplayName(nombre);

        // Guardar datos en Firestore
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(userCredential.user!.uid)
            .set({
              'nombre': nombre,
              'email': email,
              'rol': 'estudiante', // Rol por defecto
            });
      }

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print("Error de Firebase en Registro: ${e.code}");
      rethrow;
    } catch (e) {
      return null;
    }
  }

  Future<String> obtenerRolUsuario(String uid) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return data['rol'] ?? 'estudiante';
      }
      return 'estudiante';
    } catch (e) {
      print("Error obteniendo rol: $e");
      return 'estudiante';
    }
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UsuarioGeneral {

  final FirebaseAuth _auth = FirebaseAuth.instance;

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

  Future<User?> registrarUsuario(String email, String password) async {
  try {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  } on FirebaseAuthException catch (e) {
    
    print("Error de Firebase en Registro: ${e.code}");
    rethrow; 
  } catch (e) {
    return null;
  }
}
  
}
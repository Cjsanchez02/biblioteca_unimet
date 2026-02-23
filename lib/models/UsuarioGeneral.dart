import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum RolUsuario { 
  estudiante,  
  administrador, 
  bibliotecario

class UsuarioGeneral {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>?> iniciarSesion(String email, String password) async {
    try {
    
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        
        var docUsuario = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(userCredential.user!.uid)
            .get();

       
        if (docUsuario.exists) {
          
          return docUsuario.data(); 
        } else {
         
          throw Exception("Este usuario no tiene datos en el sistema");
        }
      }
      return null;
      
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
      rethrow;
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
      final consultaDb = await FirebaseFirestore.instance
          .collection('usuarios')
          .where('email', isEqualTo: email)
          .get();

      if (consultaDb.docs.isNotEmpty) {
        
        final datosUsuario = consultaDb.docs.first.data();
        final String rolGuardado = datosUsuario['rol'] ?? 'estudiante';

        if (rolGuardado == 'administrador' || rolGuardado == 'bibliotecario') {
          throw Exception('El correo ya está registrado con un rol no permitido para el registro'); 
        } else {
          throw Exception('El correo ya está registrado');
        }
      }
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
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/sugerencia_model.dart';

class ServicioSugerencias {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> enviarSugerencia(String texto) async {
    // Como estamos en Home, SABEMOS que el usuario existe. Usamos "!"
    final usuarioActual = _auth.currentUser!; 

    final nuevaSugerencia = SugerenciaModel(
      id: '', // Firestore genera esto
      nombre: usuarioActual.displayName ?? 'Estudiante',
      rol: 'estudiante', // Por ahora lo dejamos fijo
      texto: texto,
      fecha: DateTime.now(),
    );

    // Se va directo a Firebase, sin try-catch (el ViewModel atrapará el error si se cae el internet)
    await _db.collection('sugerencias').add(nuevaSugerencia.toMap());
  }

  Stream<QuerySnapshot> obtenerSugerencias() {
    return _db
        .collection('sugerencias')
        .orderBy('fecha', descending: true) // Las sugerencias más recientes primero
        .snapshots();
  }
}
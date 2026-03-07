import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ServicioCalificaciones {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> registrarCalificacionCompleta({
    required String materialId,
    required String transaccionId,
    required double estrellasLibro,
    required double estrellasProceso,
    required String comentario,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    // 1. Buscamos la carrera del usuario en Firestore
    DocumentSnapshot userDoc = await _db.collection('usuarios').doc(user.uid).get();
    String carreraEstudiante = 'No especificada';
    if (userDoc.exists) {
      carreraEstudiante = (userDoc.data() as Map<String, dynamic>)['carrera'] ?? 'No especificada';
    }


    final docMaterialRef = _db.collection('material_academico').doc(materialId);
    final docCalificacionRef = docMaterialRef.collection('calificaciones').doc(user.uid); 

    // 2. Transacción para actualizar promedios de forma segura
    await _db.runTransaction((transaction) async {
      DocumentSnapshot materialSnap = await transaction.get(docMaterialRef);
      DocumentSnapshot votoAnteriorSnap = await transaction.get(docCalificacionRef);

      if (!materialSnap.exists) throw Exception('Material no encontrado');

      final dataMaterial = materialSnap.data() as Map<String, dynamic>;

      double promedioActual = (dataMaterial['calificacionPromedio'] as num?)?.toDouble() ?? 0.0;
      int totalVotos = (dataMaterial['totalVotos'] as num?)?.toInt() ?? 0;

      double nuevoPromedio;
      int nuevoTotalVotos = totalVotos;

      if (votoAnteriorSnap.exists) {
        final dataVotoAnterior = votoAnteriorSnap.data() as Map<String, dynamic>;
        double estrellasAnteriores = (dataVotoAnterior['estrellasLibro'] as num).toDouble();
        
        // Fórmula para actualizar el promedio sin sumar un voto extra
        double sumaCorregida = (promedioActual * totalVotos) - estrellasAnteriores + estrellasLibro;
        // Evitamos división por cero por si la BD estaba en un estado extraño
        nuevoPromedio = totalVotos > 0 ? sumaCorregida / totalVotos : estrellasLibro; 
      } else {
        // Voto totalmente nuevo
        nuevoTotalVotos += 1;
        nuevoPromedio = ((promedioActual * totalVotos) + estrellasLibro) / nuevoTotalVotos;
      }

      // Guardamos la calificación
      transaction.set(docCalificacionRef, {
        'estrellasLibro': estrellasLibro,
        'estrellasProceso': estrellasProceso,
        'comentario': comentario,
        'carrera': carreraEstudiante,
        'transaccionId': transaccionId,
        'fecha': FieldValue.serverTimestamp(),
      });

      // Actualizamos el libro
      transaction.update(docMaterialRef, {
        'calificacionPromedio': nuevoPromedio,
        'totalVotos': nuevoTotalVotos,
      });
    });
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/donacion.dart';

class ServicioDonaciones {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> guardarDonacion(double monto, String moneda) async {
    try {
      final User? user = _auth.currentUser;
      String nombre = user?.displayName ?? 'Anónimo';

      // Si el nombre no esta en Auth, lo buscamos en Firestore para estar seguros
      if (user != null &&
          (user.displayName == null || user.displayName!.isEmpty)) {
        final doc = await _firestore.collection('usuarios').doc(user.uid).get();
        if (doc.exists && doc.data() != null) {
          nombre = doc.get('nombre') ?? 'Anónimo';
        }
      }

      final donacion = Donacion(
        monto: monto,
        moneda: moneda,
        fecha: DateTime.now(),
        usuarioId: user?.uid,
        usuarioEmail: user?.email,
        nombreUsuario: nombre,
      );

      await _firestore.collection('donaciones').add(donacion.toMap());
    } catch (e) {
      throw Exception('Error al guardar la donación: $e');
    }
  }

  Stream<List<Donacion>> obtenerDonaciones() {
    return _firestore
        .collection('donaciones')
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Donacion.fromMap(doc.data(), doc.id))
              .toList();
        });
  }
}

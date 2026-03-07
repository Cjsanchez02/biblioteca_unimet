import 'package:cloud_firestore/cloud_firestore.dart';

class servicioMaterial {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _coleccion = 'material_academico';

  // AGREGAR: Recibe el mapa con los nuevos campos
  Future<void> agregarMaterial(Map<String, dynamic> data) async {
    await _db.collection(_coleccion).add(data);
  }

  // EDITAR: Actualiza campos específicos
  Future<void> editarMaterial(String id, Map<String, dynamic> data) async {
    await _db.collection(_coleccion).doc(id).update(data);
  }

  // ELIMINAR
  Future<void> eliminarMaterial(String id) async {
    await _db.collection(_coleccion).doc(id).delete();
  }

  // OBTENER TODOS (Stream)
  Stream<List<Map<String, dynamic>>> obtenerMateriales() {
    return _db
        .collection(_coleccion)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              'titulo':
                  data['titulo'] ?? 'Sin título', // Evita el crash si es null
              'autor': data['autor'] ?? 'Anónimo',
              'materia': data['materia'] ?? 'General',
              'tipo': data['tipo'] ?? 'Libro',
              'stock': data['stock'] ?? 0,
              'calificacionPromedio': (data['calificacionPromedio'] ?? 0.0)
                  .toDouble(),
            };
          }).toList(),
        );
  }
}

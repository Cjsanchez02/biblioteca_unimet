import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/Prestamo.dart';
import '../models/materialbibliografico.dart';

class BibliotecaService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Funcion para solicitar un préstamo
  Future<bool> solicitarPrestamo(String correoUsuario, MaterialBibliografico libro) async {
    try {
      // Verificación de préstamo activo para el mismo material
      final prestamosActivos = await _db.collection('prestamos')
          .where('correoSolicitante', isEqualTo: correoUsuario) // Filtramos por su correo
          .where('materialId', isEqualTo: libro.id)             // Filtramos por el ID del libro
          .get(); 

      // Verificacion
      if (prestamosActivos.docs.isNotEmpty) {
        print("Error: Ya tienes una copia de '${libro.titulo}' en préstamo.");
        return false; 
      }
      // Verificación de stock
      if (!libro.hayStock()) {
        print("Error: No hay stock disponible para este material.");
        return false; 
      }

      
      final nuevoPrestamo = Prestamo(
        id: '', // Firebase
        correoSolicitante: correoUsuario,
        fechaSolicitud: DateTime.now(),
        fechaDevolucion: DateTime.now().add(const Duration(days: 7)),
        materialId: libro.id,
        tituloMaterial: libro.titulo,
        estado: 'prestado',
      );

      
      WriteBatch batch = _db.batch();

      // Recibo
      DocumentReference prestamoRef = _db.collection('prestamos').doc();
      batch.set(prestamoRef, nuevoPrestamo.toMap());

      // Restamos 1 al stock del libro
      DocumentReference libroRef = _db.collection('materiales').doc(libro.id);
      batch.update(libroRef, {'stock': FieldValue.increment(-1)});

      // Ejecucion en paralelo
      await batch.commit();
      
      print("¡Préstamo exitoso!");
      return true;

    } catch (e) {
      print("Error al procesar el préstamo: $e");
      return false;
    }
  }
  
  Future<bool> extenderPrestamo(String prestamoId) async {
    try {
      // Buscar libro
      DocumentReference prestamoRef = _db.collection('prestamos').doc(prestamoId);
      DocumentSnapshot doc = await prestamoRef.get();

      if (doc.exists) {
        Timestamp timestampFirebase = doc['fechaSolicitud']; 
        DateTime fechaActual = timestampFirebase.toDate();
        
        // +7
        DateTime nuevaFecha = fechaActual.add(const Duration(days: 7));

        // a Firebase
        await prestamoRef.update({
          'fechaDevolucion': nuevaFecha, 
          'estado': 'prestado' 
        });

        print("Préstamo extendido con éxito.");
        return true;
      }
      return false;
    } catch (e) {
      print("Error al extender el préstamo: $e");
      return false;
    }
  }
  // Future<void> devolverLibro(...)
  
}
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/Prestamo.dart';
import '../models/MaterialBibliografico.dart';

class BibliotecaService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Funcion para solicitar un préstamo
  Future<bool> solicitarPrestamo(String correoUsuario, MaterialBibliografico libro) async {
    try {
      // Verificación de préstamo activo para el mismo material
      final prestamosActivos = await _db.collection('prestamos')
          .where('correoSolicitante', isEqualTo: correoUsuario) // Filtramos por su correo
          .where('materialId', isEqualTo: libro.id)             // Filtramos por el ID del libro
          .where('estado', isEqualTo: 'prestado')
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

      String carreraFinal = 'No especificada';

      final usuarioQuery = await _db.collection('usuarios')
          .where('email', isEqualTo: correoUsuario)
          .limit(1) // Solo necesitamos un resultado
          .get();

      if (usuarioQuery.docs.isNotEmpty) {
        // Extraemos los datos del documento del usuario
        Map<String, dynamic> userData = usuarioQuery.docs.first.data();
        String rolUsuario = userData['rol'] ?? 'estudiante';

        // Aplicamos tu condicional:
        if (rolUsuario == 'empleado' || rolUsuario == 'profesor') {
          carreraFinal = rolUsuario; // Si es empleado o profesor, se coloca eso
        } else {
          // Si es estudiante, tomamos su carrera de la base de datos
          // Asegúrate de que al registrar al estudiante le guardes un campo 'carrera'
          carreraFinal = userData['carrera'] ?? 'Sin carrera registrada';
        }
      }
      
      final nuevoPrestamo = Prestamo(
        id: '', // Firebase
        correoSolicitante: correoUsuario,
        fechaSolicitud: DateTime.now(),
        fechaDevolucion: DateTime.now().add(const Duration(days: 7)),
        materialId: libro.id,
        tituloMaterial: libro.titulo,
        carrera: carreraFinal,     
        materia: libro.materia,
        estado: 'solicitado',
      );

      
      WriteBatch batch = _db.batch();

      // Recibo
      DocumentReference prestamoRef = _db.collection('prestamos').doc();
      batch.set(prestamoRef, nuevoPrestamo.toMap());

      // Restamos 1 al stock del libro
      DocumentReference libroRef = _db.collection('material_academico').doc(libro.id);
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
    DocumentReference prestamoRef = _db.collection('prestamos').doc(prestamoId);
    DocumentSnapshot doc = await prestamoRef.get();

    if (doc.exists) {
      // Obtenemos la fecha actual
      Timestamp currentDevolucion = doc['fechaDevolucion']; 
      DateTime nuevaFecha = currentDevolucion.toDate().add(const Duration(days: 7));

      await prestamoRef.update({
        'fechaDevolucion': nuevaFecha, 
        'estado': 'aprobado' 
      });

      return true;
    }
    return false;
  } catch (e) {
    print("Error al extender: $e");
    return false;
  }
}
  
  Future<bool> aprobarPrestamo(String prestamoId) async {
    try {
     
      await _db.collection('prestamos').doc(prestamoId).update({
        'estado': 'aprobado',
        
      });
      print("¡Préstamo aprobado!");
      return true;
    } catch (e) {
      print("Error al aprobar préstamo: $e");
      return false;
    }
  }


  Future<bool> devolverPrestamo(String prestamoId, String materialId) async {
    try {
      WriteBatch batch = _db.batch();

      
      DocumentReference prestamoRef = _db.collection('prestamos').doc(prestamoId);
      batch.update(prestamoRef, {'estado': 'devuelto'});

      
      DocumentReference libroRef = _db.collection('material_academico').doc(materialId);
      batch.update(libroRef, {'stock': FieldValue.increment(1)});

      
      await batch.commit();
      
      print("¡Libro devuelto con éxito y stock actualizado!");
      return true;
    } catch (e) {
      print("Error al devolver el libro: $e");
      return false;
    }
  }
  Future<bool> rechazarPrestamo(String prestamoId, String materialId) async {
    try {
      WriteBatch batch = _db.batch();

      DocumentReference prestamoRef = _db.collection('prestamos').doc(prestamoId);
      batch.update(prestamoRef, {'estado': 'rechazado'});

      DocumentReference libroRef = _db.collection('material_academico').doc(materialId);
      batch.update(libroRef, {'stock': FieldValue.increment(1)});

      await batch.commit();
      
      return true;
    } catch (e) {
      return false;
    }
  }
  
}
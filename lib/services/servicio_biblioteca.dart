import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/Prestamo.dart';
import '../models/MaterialBibliografico.dart';

class BibliotecaService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Funcion para solicitar un préstamo
  Future<String> solicitarPrestamo(String correoUsuario, MaterialBibliografico libro) async {
    try {
      //Verificación de multa 
      final DateTime ahora = DateTime.now();
      final userQuery = await _db.collection('usuarios')
        .where('email', isEqualTo: correoUsuario).get();
    
    if (userQuery.docs.isNotEmpty) {
      var userData = userQuery.docs.first.data();
      Timestamp? fechaFin = userData['fechafinbloqueo'];
      if (fechaFin != null && fechaFin.toDate().isAfter(ahora)) {
        DateTime fin = fechaFin.toDate();
        return "Cuenta suspendida hasta el regresar  por retrasos previos.";
      }
    }
      // Verificación de préstamo activo para el mismo material
      final prestamosActivos = await _db.collection('prestamos')
          .where('correoSolicitante', isEqualTo: correoUsuario) // Filtramos por su correo
          .where('materialId', isEqualTo: libro.id)             // Filtramos por el ID del libro
          .where('estado', whereIn: ['aprobado', 'solicitado'])
          .get(); 

      // Verificacion
      if (prestamosActivos.docs.isNotEmpty) {
        return "Error: Ya tienes una copia de '${libro.titulo}' en préstamo o solicitado.";
      }
      // Verificación de stock
      if (!libro.hayStock()) {
        return "Error: No hay stock disponible para este material.";
      }

      String carreraFinal = 'No especificada';

      final usuarioQuery = await _db.collection('usuarios')
          .where('email', isEqualTo: correoUsuario)
          .limit(1) 
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
      
      return "¡Préstamo solicitado con éxito! Espera la aprobación del bibliotecario.";

    } catch (e) {
      return "Error en el servidor: ${e.toString()}";
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
    
    return false;
  }
}
  
  Future<bool> aprobarPrestamo(String prestamoId) async {
    try {
     
      await _db.collection('prestamos').doc(prestamoId).update({
        'estado': 'aprobado',
        
      });
      
      return true;
    } catch (e) {
    
      return false;
    }
  }


  Future<bool> devolverPrestamo(String prestamoId, String materialId) async {
    try {
      
      DocumentSnapshot prestamoDoc = await _db.collection('prestamos').doc(prestamoId).get();
      if (!prestamoDoc.exists) return false;

      final prestamoData = prestamoDoc.data() as Map<String, dynamic>;
      String? correo = prestamoData['correoSolicitante'];

      
      WriteBatch batch = _db.batch();

     
      DocumentReference prestamoRef = _db.collection('prestamos').doc(prestamoId);
      batch.update(prestamoRef, {'estado': 'devuelto'});

  
      DocumentReference libroRef = _db.collection('material_academico').doc(materialId);
      batch.update(libroRef, {'stock': FieldValue.increment(1)});

     
      if (correo != null) {
        final userQuery = await _db.collection('usuarios')
            .where('email', isEqualTo: correo)
            .get();

        if (userQuery.docs.isNotEmpty) {
          final usuarioId = userQuery.docs.first.id;
          DocumentReference usuarioRef = _db.collection('usuarios').doc(usuarioId);
        
          batch.update(usuarioRef, {'fechafinbloqueo': null});
        }
      }
      await batch.commit();      
      return true;
    } catch (e) {
      
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
  Future <String> perdonarMulta(String usuarioId) async {
    try {
      await _db.collection('usuarios').doc(usuarioId).update({
        'fechafinbloqueo': null,
      });
      return "Multa perdonada con éxito."; 
    } catch (e) {
      return "Error al perdonar multa."; 
    }
  }
  Future<void> escanearMultados() async {
    try {
      
      final activos = await _db
          .collection('prestamos')
          .where('estado', isEqualTo: 'aprobado')
          .get();

      final DateTime ahora = DateTime.now(); 
      for (var doc in activos.docs) {
        final data = doc.data();
        final correo = data['correoSolicitante'];
        Timestamp? fechaDevolucionTS = data['fechaDevolucion'];

        if (fechaDevolucionTS != null && fechaDevolucionTS.toDate().isBefore(ahora)) {
          
          if (correo != null) {
            final userQuery = await _db
                .collection('usuarios')
                .where('email', isEqualTo: correo)
                .get();

            if (userQuery.docs.isNotEmpty) {
              final usuarioId = userQuery.docs.first.id;
              final userData = userQuery.docs.first.data();
              
            
              Timestamp? fechaFin = userData['fechafinbloqueo'];

              if (fechaFin == null || fechaFin.toDate().year != 2099) {
                await _db.collection('usuarios').doc(usuarioId).update({
                  'fechafinbloqueo': Timestamp.fromDate(DateTime(2099, 12, 31)),
                });
                print("¡Usuario $correo multado con éxito por Flutter!");
              }
            }
          }
        }
      }
    } catch (e) {
      print("Error al escanear multados: $e");
    }
  }
}
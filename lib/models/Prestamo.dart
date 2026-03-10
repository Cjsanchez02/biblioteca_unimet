class Prestamo {
  String id;
  String correoSolicitante;
  String carrera;
  DateTime fechaSolicitud;
  DateTime fechaDevolucion;
  double multa;
  String materialId;
  String tituloMaterial;
  String materia;
  String
  estado; // "solicitado", "devuelto", "atrasado", "prestado"; "rechazado"

  Prestamo({
    required this.id,
    required this.correoSolicitante,
    required this.carrera,
    required this.fechaSolicitud,
    required this.fechaDevolucion,
    this.multa = 0.0,
    required this.materialId,
    required this.materia,
    required this.tituloMaterial,
    required this.estado,
  });

  double calcularMulta() {
    //terminar
    return multa;
  }

  // App a Firebase
  Map<String, dynamic> toMap() {
    return {
      'correoSolicitante': correoSolicitante,
      'fechaSolicitud': fechaSolicitud,
      'fechaDevolucion': fechaDevolucion,
      'carrera': carrera,
      'multa': multa,
      'materialId': materialId,
      'materia': materia,
      'tituloMaterial': tituloMaterial,
      'estado': estado,
    };
  }
}

class SugerenciaModel {
  final String id; // El ID único de ESTE mensaje de sugerencia
  final String nombre;
  final String rol;
  final String texto;
  final DateTime fecha;

  SugerenciaModel({
    required this.id, 
    required this.nombre,
    required this.rol,
    required this.texto,
    required this.fecha,
  });

  // Método para convertir a JSON y enviar a Firebase
  Map<String, dynamic> toMap() {
    return {
      "nombre": nombre,
      "rol": rol,
      "texto": texto,
      "fecha": fecha.toIso8601String(), 
    };
  }

  // Se usará Factory Method: Para leer desde Firebase
  factory SugerenciaModel.fromMap(Map<String, dynamic> map, String documentId) {
    return SugerenciaModel(
      id: documentId, // documentId vuelve a ser el ID único del mensaje
      nombre: map['nombre'] ?? 'Anónimo',
      rol: map['rol'] ?? 'Usuario',
      texto: map['texto'] ?? '',
      fecha: map['fecha'] != null ? DateTime.parse(map['fecha']) : DateTime.now(),
    );
  }
}
class MaterialBibliografico {
  String id;
  String titulo;
  String autor;
  String materia;
  int stock;
  double calificacionPromedio;

  MaterialBibliografico({
    required this.id,
    required this.titulo,
    required this.autor,
    required this.materia,
    required this.stock,
    this.calificacionPromedio = 0.0,
  });

  // Revisa si hay stock disponible
  bool hayStock() {
    return stock > 0;
  }
  // Actualiza el stock (puede ser positivo o negativo)
  void actualizarStock(int cantidad) {
    stock += cantidad;
  }

  // Firebase al App
  factory MaterialBibliografico.fromMap(Map<String, dynamic> map, String documentId) {
    return MaterialBibliografico(
      id: documentId,
      titulo: map['titulo'] ?? '',
      autor: map['autor'] ?? '',
      materia: map['categoria'] ?? 'OTRO',
      stock: map['stock'] ?? 0,
      calificacionPromedio: (map['calificacionPromedio'] ?? 0.0).toDouble(),
    );
  }

  // App a Firebase
  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'autor': autor,
      'materia': materia,
      'stock': stock,
      'calificacionPromedio': calificacionPromedio,
    };
  }
}
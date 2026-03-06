import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class DialogoCalificacion extends StatefulWidget {
  final String tituloLibro;
  // Pasamos la función que se comunicará con el ViewModel/Facade
  final Function(double estrellasLibro, double estrellasProceso, String comentario) onEnviar;

  const DialogoCalificacion({
    Key? key,
    required this.tituloLibro,
    required this.onEnviar,
  }) : super(key: key);

  @override
  State<DialogoCalificacion> createState() => _DialogoCalificacionState();
}

class _DialogoCalificacionState extends State<DialogoCalificacion> {
  double _puntosLibro = 3.0; // Valor por defecto
  double _puntosProceso = 3.0;
  final TextEditingController _comentarioController = TextEditingController();

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Retornamos un AlertDialog, que es el "cuadro desplegable" clásico
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: const Text(
        '¡Libro Devuelto!',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('¿Qué te pareció "${widget.tituloLibro}"?'),
            const SizedBox(height: 10),
            // Estrellas para el Libro
            RatingBar.builder(
              initialRating: 3,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
              itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
              onRatingUpdate: (rating) {
                setState(() => _puntosLibro = rating);
              },
            ),
            const Divider(height: 30),

            const Text('¿Cómo calificarías el proceso de préstamo?'),
            const SizedBox(height: 10),
            // Estrellas para el Proceso
            RatingBar.builder(
              initialRating: 3,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
              itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.blueAccent),
              onRatingUpdate: (rating) {
                setState(() => _puntosProceso = rating);
              },
            ),
            const SizedBox(height: 20),

            // Campo de texto para comentarios opcionales
            TextField(
              controller: _comentarioController,
              decoration: InputDecoration(
                hintText: 'Déjanos un comentario opcional...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(), // Botón para omitir/cerrar
          child: const Text('Omitir', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange, // El color naranja de la UMET
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () {
            // Ejecutamos la función que pasamos por parámetro
            widget.onEnviar(_puntosLibro, _puntosProceso, _comentarioController.text);
            Navigator.of(context).pop(); // Cerramos el cuadro
            
            // Aquí puedes mostrar un SnackBar de "¡Gracias por tu voto!"
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('¡Gracias por tu calificación!')),
            );
          },
          child: const Text('Enviar'),
        ),
      ],
    );
  }
}
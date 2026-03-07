import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:biblioteca_unimet/viewmodels/calificacion_viewmodel.dart';

class DialogoCalificacion extends StatefulWidget {
  final String materialId;
  final String transaccionId;
  final String tituloLibro;

  const DialogoCalificacion({
    Key? key,
    required this.materialId,
    required this.transaccionId,
    required this.tituloLibro,
  }) : super(key: key);

  @override
  State<DialogoCalificacion> createState() => _DialogoCalificacionState();
}

class _DialogoCalificacionState extends State<DialogoCalificacion> {
  // Instanciamos el ViewModel para conectar con Firebase
  final CalificacionViewModel _viewModel = CalificacionViewModel();
  
  double _puntosLibro = 3.0;
  double _puntosProceso = 3.0;
  final TextEditingController _comentarioController = TextEditingController();

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // El Patrón Observer: Escuchamos al ViewModel
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, child) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(
            '¡Devolviste "${widget.tituloLibro}"!',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          
          // Si está cargando, mostramos la ruedita de espera. Si no, el formulario.
          content: _viewModel.isLoading
              ? const SizedBox(
                  height: 100,
                  child: Center(child: CircularProgressIndicator(color: Colors.orange)),
                )
              : SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('¿Qué te pareció el libro?'),
                      const SizedBox(height: 8),
                      RatingBar.builder(
                        initialRating: 3,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemSize: 30, // Un poco más pequeñas para que quepan bien
                        itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                        onRatingUpdate: (rating) => _puntosLibro = rating,
                      ),
                      const Divider(height: 30),

                      const Text('¿Cómo calificarías el proceso?'),
                      const SizedBox(height: 8),
                      RatingBar.builder(
                        initialRating: 3,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemSize: 30,
                        itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.blueAccent),
                        onRatingUpdate: (rating) => _puntosProceso = rating,
                      ),
                      const SizedBox(height: 20),

                      TextField(
                        controller: _comentarioController,
                        maxLength: 600,
                        decoration: InputDecoration(
                          hintText: 'Comentario opcional...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                
          // Ocultamos los botones si se está enviando a Firebase
          actions: _viewModel.isLoading
              ? [] 
              : [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(), // Cierra sin hacer nada
                    child: const Text('Omitir', style: TextStyle(color: Colors.grey)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () async {
                      // Llamamos al ViewModel para guardar todo
                      bool exito = await _viewModel.enviarCalificacion(
                        materialId: widget.materialId,
                        transaccionId: widget.transaccionId,
                        estrellasLibro: _puntosLibro,
                        estrellasProceso: _puntosProceso,
                        comentario: _comentarioController.text,
                        context: context,
                      );
                      
                      // Si todo salió bien, cerramos el cuadro
                      if (exito && mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Enviar', style: TextStyle(color: Colors.white)),
                  ),
                ],
        );
      },
    );
  }
}
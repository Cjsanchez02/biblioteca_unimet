import 'package:biblioteca_unimet/services/servicio_biblioteca.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MisPrestamosView extends StatelessWidget {
  final String correoUsuario; // Para que muestre solo los préstamos de este usuario

  const MisPrestamosView({super.key, required this.correoUsuario});

  static const Color kOrange = Color(0xFFF7941D);
  static const Color kDarkGray = Color(0xFF333333);
  static const Color kLightGray = Color(0xFFF4F4F4);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Mi Material',
          style: TextStyle(color: kDarkGray, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1, 
        iconTheme: const IconThemeData(color: kDarkGray),
      ),
      //Para que siempre este conectado con firebase y muestre los prestamos en tiempo real
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('prestamos')
            .where('correoSolicitante', isEqualTo: correoUsuario)
            .snapshots(), // Cambios en tiempo real
        builder: (context, snapshot) {
          // Mientras carga
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: kOrange));
          }

          // Error
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar los préstamos.'));
          }

          // Sin prestamos
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.menu_book, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 20),
                  const Text(
                    'Estimado Usuario, no tienes préstamos activos.',
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                ],
              ),
            );
          }

          // Mostrar prestamos
          final prestamos = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: prestamos.length,
            itemBuilder: (context, index) {
              var data = prestamos[index].data() as Map<String, dynamic>;
              
            
              String prestamoId = prestamos[index].id; 
              
              String titulo = data['tituloMaterial'] ?? 'Libro desconocido';
              String estado = data['estado'] ?? 'solicitado';
              
              DateTime fecha = (data['fechaSolicitud'] as Timestamp).toDate();
              String fechaAcomodada = "${fecha.day}/${fecha.month}/${fecha.year}";

              return _buildTarjetaPrestamo(context, prestamoId, titulo, estado, fechaAcomodada);
            },
          );
        },
      ),
    );
  }

  // Para cada libro
  Widget _buildTarjetaPrestamo(BuildContext context, String id, String titulo, String estado, String fecha) {
    Color colorEstado;
    IconData iconoEstado;

    switch (estado.toLowerCase()) {
      case 'solicitado':
        colorEstado = Colors.blue;
        iconoEstado = Icons.hourglass_top;
        break;
      case 'devuelto':
        colorEstado = Colors.grey;
        iconoEstado = Icons.check_circle;
        break;
      case 'atrasado':
        colorEstado = Colors.red;
        iconoEstado = Icons.warning;
        break;
      case 'prestado':
      default:
        colorEstado = Colors.green;
        iconoEstado = Icons.menu_book;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: kLightGray,
      elevation: 0,
      
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(15),
            leading: CircleAvatar(
              backgroundColor: colorEstado.withOpacity(0.2),
              child: Icon(iconoEstado, color: colorEstado),
            ),
            title: Text(
              titulo,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text('Fecha: $fecha'),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colorEstado.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colorEstado),
              ),
              child: Text(
                estado.toUpperCase(),
                style: TextStyle(
                  color: colorEstado,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          
          
          if (estado.toLowerCase() == 'prestado' || estado.toLowerCase() == 'atrasado')
            Padding(
              padding: const EdgeInsets.only(right: 15, bottom: 10),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () async {
                  
                    final exito = await BibliotecaService().extenderPrestamo(id);
                    
                    if (exito && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('¡Préstamo extendido por 7 días!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.update, size: 18),
                  label: const Text('Extender 7 días'),
                  style: TextButton.styleFrom(
                    foregroundColor: kOrange,
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
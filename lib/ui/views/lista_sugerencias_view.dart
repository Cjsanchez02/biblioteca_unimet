import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:biblioteca_unimet/services/servicio_sugerencias.dart';

class ListaSugerenciasView extends StatelessWidget {
  const ListaSugerenciasView({super.key});

  @override
  Widget build(BuildContext context) {
    final ServicioSugerencias servicio = ServicioSugerencias();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Buzón de Sugerencias',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFFF7941D),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: servicio.obtenerSugerencias(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar las sugerencias'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay sugerencias por ahora.'));
          }

          final sugerencias = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sugerencias.length,
            itemBuilder: (context, index) {
              var datos = sugerencias[index].data() as Map<String, dynamic>;

              DateTime fecha = (datos['fecha'] as Timestamp).toDate();
              String fechaFormateada =
                  "${fecha.day}/${fecha.month}/${fecha.year}";

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            datos['nombre'] ?? 'Anónimo',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            fechaFormateada,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Carnet: ${datos['carnet'] ?? 'N/A'}",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const Divider(),
                      const SizedBox(height: 8),
                      Text(
                        datos['texto'] ?? '',
                        style: const TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

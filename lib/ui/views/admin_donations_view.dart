import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDonationsView extends StatelessWidget {
  const AdminDonationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donaciones de Usuarios'),
        backgroundColor: const Color(0xFFF7941D),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('usuarios').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFF7941D)),
            );
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar datos: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay usuarios registrados.'));
          }

          // Filtramos y aplanamos la lista para obtener un elemento por cada donacion
          final List<Map<String, dynamic>> donacionesExpandidas = [];

          for (var doc in snapshot.data!.docs) {
            final userData = doc.data() as Map<String, dynamic>;
            final historial = userData['historialDonaciones'] as List<dynamic>?;

            if (historial != null && historial.isNotEmpty) {
              final nombre = userData['nombre'] ?? 'Usuario sin nombre';
              final correo = userData['correo'] ?? userData['email'] ?? 'Sin correo';

              for (var donacion in historial) {
                if (donacion is Map<String, dynamic>) {
                  donacionesExpandidas.add({
                    'nombre': nombre,
                    'correo': correo,
                    ...donacion,
                  });
                }
              }
            }
          }

          if (donacionesExpandidas.isEmpty) {
            return const Center(child: Text('Nadie ha realizado donaciones aún.'));
          }

          // Opcional: Ordenar por fecha reciente
          donacionesExpandidas.sort((a, b) {
             final dateA = DateTime.tryParse(a['fecha'] ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
             final dateB = DateTime.tryParse(b['fecha'] ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
             return dateB.compareTo(dateA); // Descendente
          });

          return ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: donacionesExpandidas.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final donacion = donacionesExpandidas[index];

              final nombre = donacion['nombre'];
              final correo = donacion['correo'];
              final monto = donacion['monto'] ?? 0.0;
              final moneda = donacion['moneda'] ?? '';
              
              String fechaFormateada = 'Fecha desconocida';
              if (donacion['fecha'] != null) {
                final date = DateTime.tryParse(donacion['fecha']);
                if (date != null) {
                  fechaFormateada = "${date.day}/${date.month}/${date.year}";
                }
              }

              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFF4F4F4),
                  child: Icon(Icons.volunteer_activism, color: Color(0xFFF7941D)),
                ),
                title: Text(
                  nombre,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  correo,
                  style: const TextStyle(color: Colors.grey),
                ),
                // Alineado a la derecha como se pidio: monto y fecha.
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${monto.toStringAsFixed(2)} $moneda',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      fechaFormateada,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

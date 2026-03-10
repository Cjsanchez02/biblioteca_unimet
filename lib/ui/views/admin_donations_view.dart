import 'package:flutter/material.dart';
import '../../services/servicio_donaciones.dart';
import '../../models/donacion.dart';
import '../widgets/admin_navbar.dart';

class AdminDonationsView extends StatelessWidget {
  const AdminDonationsView({super.key});

  static const Color kOrange = Color(0xFFF7941D);
  static const Color kDarkGray = Color(0xFF333333);

  @override
  Widget build(BuildContext context) {
    final ServicioDonaciones servicio = ServicioDonaciones();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Donaciones Recibidas'),
        backgroundColor: kOrange,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          const AdminNavbar(activeTab: AdminTab.donaciones),
          const Divider(height: 1),
          Expanded(
            child: StreamBuilder<List<Donacion>>(
              stream: servicio.obtenerDonaciones(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final donaciones = snapshot.data ?? [];

                if (donaciones.isEmpty) {
                  return const Center(
                    child: Text(
                      'No hay donaciones registradas aún.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: donaciones.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final donacion = donaciones[index];
                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFFDECDA),
                        child: Icon(Icons.volunteer_activism, color: kOrange),
                      ),
                      title: Text(
                        donacion.nombreUsuario ?? 'Usuario Anónimo',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        donacion.usuarioEmail ?? 'Sin correo',
                        style: const TextStyle(color: Colors.black38),
                      ),
                      trailing: Text(
                        '${donacion.monto.toStringAsFixed(2)} ${donacion.moneda}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

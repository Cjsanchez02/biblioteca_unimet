import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:biblioteca_unimet/services/servicio_biblioteca.dart';
import '../widgets/admin_navbar.dart';
import '../widgets/custom_navbars.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LibrarianPrestamosView extends StatelessWidget {
  LibrarianPrestamosView({super.key})
  {_bibliotecaService.escanearMultados();}

  final BibliotecaService _bibliotecaService = BibliotecaService();
  

  static const Color kOrange = Color(0xFFF7941D);
  static const Color kDarkGray = Color(0xFF333333);
  static const Color kLightGray = Color(0xFFF4F4F4);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            _buildRoleNavbar(),
            const Divider(height: 1),
            const TabBar(
              labelColor: kOrange,
              unselectedLabelColor: kDarkGray,
              indicatorColor: kOrange,
              tabs: [
                Tab(text: "SOLICITUDES", icon: Icon(Icons.pending_actions)),
                Tab(text: "ENTREGADOS", icon: Icon(Icons.book_rounded)),
                Tab(text: "MULTADOS", icon: Icon(Icons.gavel)),
              ],
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  bool isDesktop = constraints.maxWidth > 800;
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 80.0 : 20.0,
                      vertical: 20.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: kDarkGray),
                            children: [
                              TextSpan(text: 'Gestión de '),
                              TextSpan(text: 'Préstamos', style: TextStyle(color: kOrange)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: TabBarView(
                            children: [
                              _buildListaFiltrada('solicitado'),
                              _buildListaFiltrada('aprobado'),
                              _buildListaMultados(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListaFiltrada(String estadoFiltro) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('prestamos')
          .where('estado', isEqualTo: estadoFiltro)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: kOrange));
        }

        if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              estadoFiltro == 'solicitado' 
                ? 'No hay solicitudes pendientes.' 
                : 'No hay libros prestados actualmente.',
              style: const TextStyle(fontSize: 18, color: Colors.black54),
            ),
          );
        }

        final solicitudes = snapshot.data!.docs;

        return ListView.builder(
          itemCount: solicitudes.length,
          itemBuilder: (context, index) {
            final solicitud = solicitudes[index];
            final data = solicitud.data() as Map<String, dynamic>;
            final prestamoId = solicitud.id;
            final materialId = data['materialId'];

            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: kLightGray,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.black12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                leading: const Icon(Icons.menu_book, color: kDarkGray, size: 30),
                title: Text(
                  data['tituloMaterial'] ?? 'Sin título',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                subtitle: Text('Solicitante: ${data['correoSolicitante']}'),
                trailing: estadoFiltro == 'solicitado'
                    ? _buildBotonesSolicitud(context, prestamoId, materialId)
                    : _buildBotonDevolucion(context, prestamoId, materialId),
              ),
            );
          },
        );
      },
    );
  }
  Widget _buildListaMultados() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('usuarios')
          // Usuarios cuya fecha de fin de bloqueo sea mayor al momento actual
          .where('fechafinbloqueo', isGreaterThan: Timestamp.now())
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: kOrange));
        }

        if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'No hay usuarios multados actualmente.',
              style: TextStyle(fontSize: 18, color: Colors.black54),
            ),
          );
        }

        final usuariosMultados = snapshot.data!.docs;

        return ListView.builder(
          itemCount: usuariosMultados.length,
          itemBuilder: (context, index) {
            final userDoc = usuariosMultados[index];
            final data = userDoc.data() as Map<String, dynamic>;

            final usuarioId = userDoc.id;

            Timestamp? fechaFin = data['fechafinbloqueo'];
            String fechaFormateada = '';
            if (fechaFin != null) {
              DateTime date = fechaFin.toDate();
              fechaFormateada = '${date.day}/${date.month}/${date.year}';
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: kLightGray,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.red.shade300, width: 1.5), 
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                leading: const Icon(Icons.person_off, color: Colors.red, size: 30),
                title: Text(
                  data['nombre'] ,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: Text(
                    'Correo: ${data['email']}\nSuspendido hasta: $fechaFormateada',
                    style: const TextStyle(height: 1.4),
                  ),
                ),
                isThreeLine: true,
                trailing: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, 
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text('Perdonar'),
                  onPressed: () async {
                    
                    String exito = await _bibliotecaService.perdonarMulta(usuarioId);
                    
                    if (exito.startsWith("Multa perdonada con éxito.") && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(exito),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                    else {                    
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(exito),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
                //
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBotonesSolicitud(BuildContext context, String pId, String mId) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: kOrange),
          onPressed: () async {
            await _bibliotecaService.aprobarPrestamo(pId);
          },
          child: const Text('Aprobar', style: TextStyle(color: Colors.white)),
        ),
        const SizedBox(width: 8),
        OutlinedButton(
          style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
          onPressed: () async {
            await _bibliotecaService.rechazarPrestamo(pId, mId);
          },
          child: const Text('Rechazar'),
        ),
      ],
    );
  }

  Widget _buildBotonDevolucion(BuildContext context, String pId, String mId) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
      onPressed: () async {
        bool exito = await _bibliotecaService.devolverPrestamo(pId, mId);
        if (exito && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Libro devuelto exitosamente')),
          );
        }
      },
      child: const Text('Marcar Devolución', style: TextStyle(color: Colors.white)),
    );
  }
  Widget _buildRoleNavbar() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('usuarios').doc(user.uid).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox(height: 80);
        final data = snapshot.data!.data() as Map<String, dynamic>?;
        final role = data?['rol'] ?? 'Usuario Normal';

        if (role == 'Administrador') {
          return const AdminNavbar(activeTab: AdminTab.prestamos);
        } else {
          return const LibrarianNavbar(activeTab: LibrarianTab.prestamos);
        }
      },
    );
  }
}
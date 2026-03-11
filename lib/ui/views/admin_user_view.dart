import 'package:biblioteca_unimet/ui/views/admin_user_form_view.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUsersView extends StatefulWidget {
  const AdminUsersView({super.key});

  @override
  State<AdminUsersView> createState() => _AdminUsersViewState();
}

class _AdminUsersViewState extends State<AdminUsersView> {
  String _busquedaEmail = "";
  String _filtroRol = "Todos";
  final List<String> _rolesFiltro = [
    "Todos",
    "estudiante",
    "bibliotecario",
    "admin",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestión de Usuarios"),
        backgroundColor: const Color(0xFFF7941D),
      ),
      body: Column(
        children: [
          _buildFiltros(),
          Expanded(child: _buildListaUsuarios()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFF9500),
        onPressed: () => _mostrarFormularioUsuario(context),
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Widget _buildFiltros() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.grey[100],
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: "Buscar por email...",
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              fillColor: Colors.white,
              filled: true,
            ),
            onChanged: (val) =>
                setState(() => _busquedaEmail = val.toLowerCase()),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: _filtroRol,
            decoration: const InputDecoration(labelText: "Filtrar por Rol"),
            items: _rolesFiltro
                .map(
                  (r) =>
                      DropdownMenuItem(value: r, child: Text(r.toUpperCase())),
                )
                .toList(),
            onChanged: (val) => setState(() => _filtroRol = val!),
          ),
        ],
      ),
    );
  }

  Widget _buildListaUsuarios() {
    Query query = FirebaseFirestore.instance.collection('usuarios');

    // Aplicar filtro de rol si no es "Todos"
    if (_filtroRol != "Todos") {
      query = query.where('rol', isEqualTo: _filtroRol);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        // Filtrado local para búsqueda por email (Firestore no permite "contains" fácilmente)
        var docs = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          String email = (data['email'] ?? '').toString().toLowerCase();
          return email.contains(_busquedaEmail);
        }).toList();

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final user = doc.data() as Map<String, dynamic>;
            final uid = doc.id;
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: _getRolColor(user['rol'] ?? 'estudiante'),
                child: const Icon(Icons.person, color: Colors.white),
              ),
              title: Text(user['nombre'] ?? 'Sin Nombre'),
              subtitle: Text(user['email'] ?? 'Sin Email'),
              trailing: Row(
                mainAxisSize: MainAxisSize
                    .min, // Importante para que no ocupe toda la pantalla
                children: [
                  Chip(label: Text(user['rol'] ?? 'estudiante')),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _mostrarFormularioEliminar(context, uid, user),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Color _getRolColor(String rol) {
    if (rol == 'admin') return Colors.red;
    if (rol == 'bibliotecario') return Colors.blue;
    return Colors.green;
  }

  // Mostrar formulario de crear usuario
  void _mostrarFormularioUsuario(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const Dialog(child: AdminUserFormView()),
    );
  }
  void _mostrarFormularioEliminar(BuildContext context, String uid, Map<String, dynamic> data) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      child: AdminUserFormView(
        esModoEliminar: true,
        uidParaEliminar: uid,
        datosIniciales: data,
      ),
    ),
  );
}
}

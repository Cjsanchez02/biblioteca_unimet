import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import '../../models/UsuarioGeneral.dart';
import '../widgets/admin_navbar.dart';

class AdminUsersView extends StatefulWidget {
  const AdminUsersView({super.key});

  static const Color kOrange = Color(0xFFF7941D);
  static const Color kDarkGray = Color(0xFF333333);
  static const Color kLightGray = Color(0xFFF4F4F4);

  @override
  State<AdminUsersView> createState() => _AdminUsersViewState();
}

class _AdminUsersViewState extends State<AdminUsersView> {
  String _filtroRol = 'Todos';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Administrar Usuarios'),
        backgroundColor: AdminUsersView.kOrange,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          const AdminNavbar(activeTab: AdminTab.usuarios),
          const Divider(height: 1),
          // Filtro por rol
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                const Text(
                  'Filtrar por rol: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: _filtroRol,
                  items: ['Todos', 'estudiante', 'bibliotecario', 'admin']
                      .map(
                        (r) => DropdownMenuItem(
                          value: r,
                          child: Text(r == 'Todos' ? 'Todos' : _rolLabel(r)),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => _filtroRol = val!),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminUsersView.kOrange,
                  ),
                  onPressed: () => _mostrarDialogoAgregar(context),
                  icon: const Icon(Icons.person_add, color: Colors.white),
                  label: const Text(
                    'Agregar Usuario',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Lista de usuarios
          Expanded(child: _buildListaUsuarios()),
        ],
      ),
    );
  }

  String _rolLabel(String rol) {
    switch (rol) {
      case 'estudiante':
        return 'Usuario Normal';
      case 'bibliotecario':
        return 'Bibliotecario';
      case 'admin':
        return 'Administrador';
      default:
        return rol;
    }
  }

  IconData _rolIcon(String rol) {
    switch (rol) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'bibliotecario':
        return Icons.local_library;
      default:
        return Icons.person;
    }
  }

  Color _rolColor(String rol) {
    switch (rol) {
      case 'admin':
        return Colors.red;
      case 'bibliotecario':
        return Colors.blue;
      default:
        return Colors.green;
    }
  }

  Widget _buildListaUsuarios() {
    Query query = FirebaseFirestore.instance.collection('usuarios');
    if (_filtroRol != 'Todos') {
      query = query.where('rol', isEqualTo: _filtroRol);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AdminUsersView.kOrange),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'No se encontraron usuarios.',
              style: TextStyle(fontSize: 18, color: Colors.black54),
            ),
          );
        }

        final usuarios = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(15),
          itemCount: usuarios.length,
          itemBuilder: (context, index) {
            final doc = usuarios[index];
            final data = doc.data() as Map<String, dynamic>;
            final nombre = data['nombre'] ?? 'Sin nombre';
            final email = data['email'] ?? 'Sin correo';
            final rol = data['rol'] ?? 'estudiante';

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: AdminUsersView.kLightGray,
              elevation: 0,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                leading: CircleAvatar(
                  backgroundColor: _rolColor(rol).withValues(alpha: 0.2),
                  child: Icon(_rolIcon(rol), color: _rolColor(rol)),
                ),
                title: Text(
                  nombre,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(email, style: const TextStyle(fontSize: 13)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _rolColor(rol).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _rolColor(rol)),
                      ),
                      child: Text(
                        _rolLabel(rol),
                        style: TextStyle(
                          fontSize: 11,
                          color: _rolColor(rol),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () =>
                      _confirmarEliminar(context, doc.id, nombre, email),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ── Diálogo para AGREGAR usuario ──
  void _mostrarDialogoAgregar(BuildContext context) {
    final nombreCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    final confirmarCtrl = TextEditingController();
    String rolSeleccionado = 'estudiante';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: const Row(
                children: [
                  Icon(Icons.person_add, color: AdminUsersView.kOrange),
                  SizedBox(width: 10),
                  Text('Agregar Usuario'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nombreCtrl,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))],
                      decoration: const InputDecoration(
                        labelText: 'Nombre completo',
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: emailCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: passwordCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: Icon(Icons.lock),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: confirmarCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Confirmar Contraseña',
                        prefixIcon: Icon(Icons.lock_clock_outlined),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Seleccionar Rol:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    RadioListTile<String>(
                      title: const Text('Usuario Normal'),
                      subtitle: const Text('Acceso básico al catálogo'),
                      value: 'estudiante',
                      groupValue: rolSeleccionado,
                      activeColor: AdminUsersView.kOrange,
                      onChanged: (val) {
                        setDialogState(() => rolSeleccionado = val!);
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('Bibliotecario'),
                      subtitle: const Text('Gestión de catálogo y préstamos'),
                      value: 'bibliotecario',
                      groupValue: rolSeleccionado,
                      activeColor: AdminUsersView.kOrange,
                      onChanged: (val) {
                        setDialogState(() => rolSeleccionado = val!);
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('Administrador'),
                      subtitle: const Text('Acceso total al sistema'),
                      value: 'admin',
                      groupValue: rolSeleccionado,
                      activeColor: AdminUsersView.kOrange,
                      onChanged: (val) {
                        setDialogState(() => rolSeleccionado = val!);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminUsersView.kOrange,
                  ),
                  onPressed: () async {
                    final nombre = nombreCtrl.text.trim();
                    final email = emailCtrl.text.trim();
                    final password = passwordCtrl.text.trim();
                    final confirmar = confirmarCtrl.text.trim();

                    if (nombre.isEmpty ||
                        email.isEmpty ||
                        password.isEmpty ||
                        confirmar.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Todos los campos son obligatorios.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    if (!email.endsWith('@correo.unimet.edu.ve') && !email.endsWith('@unimet.edu.ve')) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Solo se permiten correos @correo.unimet.edu.ve o @unimet.edu.ve',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    if (password != confirmar) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Las contraseñas no coinciden.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    if (!UsuarioGeneral.validarPassword(password)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(UsuarioGeneral.mensajeErrorPassword),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    try {
                      // Crear usuario en Firebase Auth
                      UserCredential cred = await FirebaseAuth.instance
                          .createUserWithEmailAndPassword(
                            email: email,
                            password: password,
                          );

                      // Guardar datos en Firestore
                      await FirebaseFirestore.instance
                          .collection('usuarios')
                          .doc(cred.user!.uid)
                          .set({
                            'nombre': nombre,
                            'email': email,
                            'rol': rolSeleccionado,
                          });

                      // Actualizar displayName
                      await cred.user!.updateDisplayName(nombre);

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Usuario "$nombre" creado como ${_rolLabel(rolSeleccionado)}.',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } on FirebaseAuthException catch (e) {
                      if (context.mounted) {
                        String mensaje;
                        switch (e.code) {
                          case 'email-already-in-use':
                            mensaje = 'Este correo ya está registrado.';
                            break;
                          case 'invalid-email':
                            mensaje = 'El correo no es válido.';
                            break;
                          case 'weak-password':
                            mensaje = 'La contraseña es muy débil.';
                            break;
                          default:
                            mensaje = 'Error: ${e.message}';
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(mensaje),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error inesperado: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text(
                    'Crear Usuario',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ── Confirmar ELIMINAR usuario ──
  void _confirmarEliminar(
    BuildContext context,
    String docId,
    String nombre,
    String email,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_outlined, color: Colors.red),
            SizedBox(width: 10),
            Text('Eliminar Usuario'),
          ],
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar a "$nombre" ($email)?\n\nEsta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.black),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                await FirebaseFirestore.instance
                    .collection('usuarios')
                    .doc(docId)
                    .delete();

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Usuario "$nombre" eliminado.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al eliminar: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

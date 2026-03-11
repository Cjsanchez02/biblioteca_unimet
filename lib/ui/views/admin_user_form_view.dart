import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/UsuarioGeneral.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUserFormView extends StatefulWidget {
  final bool esModoEliminar;
  final String? uidParaEliminar;
  final Map<String, dynamic>? datosIniciales;

  const AdminUserFormView({
    super.key,
    this.esModoEliminar = false,
    this.uidParaEliminar,
    this.datosIniciales,
  });

  @override
  State<AdminUserFormView> createState() => _AdminUserFormViewState();
}

class _AdminUserFormViewState extends State<AdminUserFormView> {
  final _nombreCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController(); // Nuevo controlador
  String _rolSeleccionado = "estudiante";
  final UsuarioGeneral _logica = UsuarioGeneral();
  String _mensajeError = "";

  @override
  void initState() {
    super.initState();
    if (widget.datosIniciales != null) {
      _nombreCtrl.text = widget.datosIniciales!['nombre'] ?? '';
      _emailCtrl.text = widget.datosIniciales!['email'] ?? '';
      _rolSeleccionado = widget.datosIniciales!['rol'] ?? 'estudiante';
    }
  }

  void _ejecutarAccion() async {
    if (widget.esModoEliminar) {
      _eliminarUsuario();
    } else {
      _validarYCrear();
    }
  }

  void _mostrarErrorLocal(String m) {
    setState(() {
      _mensajeError = m;
    });
    // Opcional: que el mensaje desaparezca tras 3 segundos
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _mensajeError = "");
    });
  }

  void _validarYCrear() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text.trim();
    final confirm = _confirmPassCtrl.text.trim();
    final nombre = _nombreCtrl.text.trim();

    // 1. Campos obligatorios
    if (email.isEmpty || pass.isEmpty || confirm.isEmpty || nombre.isEmpty) {
      _mostrarErrorLocal("Todos los campos son obligatorios");
      return;
    }

    // 2. Validación de dominio UNIMET
    if (!email.endsWith('@correo.unimet.edu.ve') &&
        !email.endsWith('@unimet.edu.ve')) {
      _mostrarErrorLocal(
        "Solo se permiten correos @correo.unimet.edu.ve o @unimet.edu.ve",
      );
      return;
    }

    // 3. Coincidencia de contraseñas
    if (pass != confirm) {
      _mostrarErrorLocal("Las contraseñas no coinciden");
      return;
    }

    // 4. Reglas de complejidad de contraseña
    if (pass.length < 6) {
      _mostrarErrorLocal("La contraseña debe tener al menos 6 caracteres");
      return;
    }
    if (!pass.contains(RegExp(r'[A-Z]'))) {
      _mostrarErrorLocal("La contraseña debe incluir al menos una mayúscula");
      return;
    }
    if (!pass.contains(RegExp(r'[a-z]'))) {
      _mostrarErrorLocal("La contraseña debe incluir al menos una minúscula");
      return;
    }
    if (!pass.contains(RegExp(r'[!@#$%^&*()_,\¿/.?"+-=:{}|<>]'))) {
      _mostrarErrorLocal("La contraseña debe incluir un carácter especial");
      return;
    }

    _mostrarCargando();

    try {
      await _logica.registrarUsuario(
        email,
        pass,
        nombre,
        rol: _rolSeleccionado,
      );
      if (mounted) Navigator.pop(context); // Quitar diálogo de carga
      if (mounted) Navigator.pop(context); // Quitar formulario
      _snack("¡Cuenta creada con éxito!", Colors.green);
    } catch (e) {
      if (mounted) Navigator.pop(context); // Quitar diálogo de carga
      _snack("Error: El correo ya existe o es inválido", Colors.red);
    }
  }

  void _eliminarUsuario() async {
    try {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(widget.uidParaEliminar)
          .delete();
      if (mounted) Navigator.pop(context);
      _snack("Usuario eliminado permanentemente", Colors.red);
    } catch (e) {
      _snack("Error al eliminar", Colors.red);
    }
  }

  void _snack(String m, Color c) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          m,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: c,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 20,
          right: 20,
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void _mostrarCargando() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFFF9500)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool modoEliminar = widget.esModoEliminar;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            modoEliminar ? "ELIMINAR USUARIO" : "CREAR NUEVO USUARIO",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: modoEliminar ? Colors.red : Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          _crearTextField(
            _nombreCtrl,
            "Nombre y Apellido",
            Icons.person,
            false,
            soloLetras: true,
            habilitado: !modoEliminar,
          ),
          const SizedBox(height: 10),
          _crearTextField(
            _emailCtrl,
            "Email",
            Icons.email,
            false,
            habilitado: !modoEliminar,
          ),

          if (!modoEliminar) ...[
            const SizedBox(height: 10),
            _crearTextField(_passCtrl, "Contraseña", Icons.lock, true),
            const SizedBox(height: 10),
            _crearTextField(
              _confirmPassCtrl,
              "Confirmar Contraseña",
              Icons.lock_clock,
              true,
            ),
          ],

          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _rolSeleccionado,
            items: [
              "estudiante",
              "bibliotecario",
              "admin",
            ].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
            onChanged: modoEliminar
                ? null
                : (val) => setState(() => _rolSeleccionado = val!),
            decoration: const InputDecoration(
              labelText: "Rol del Usuario",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 25),
          if (_mensajeError.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _mensajeError,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
          ],
          ElevatedButton(
            onPressed: _ejecutarAccion,
            style: ElevatedButton.styleFrom(
              backgroundColor: modoEliminar
                  ? Colors.red
                  : const Color(0xFFFF9500),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: Text(
              modoEliminar ? "CONFIRMAR ELIMINACIÓN" : "GUARDAR USUARIO",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (modoEliminar)
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancelar",
                style: TextStyle(color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }

  Widget _crearTextField(
    TextEditingController controller,
    String label,
    IconData icon,
    bool isPassword, {
    bool soloLetras = false,
    bool habilitado = true,
  }) {
    return TextField(
      controller: controller,
      enabled: habilitado,
      obscureText: isPassword,
      inputFormatters: soloLetras
          ? [
              FilteringTextInputFormatter.allow(
                RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]'),
              ),
            ]
          : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
        fillColor: habilitado ? Colors.transparent : Colors.grey[200],
        filled: !habilitado,
      ),
    );
  }
}

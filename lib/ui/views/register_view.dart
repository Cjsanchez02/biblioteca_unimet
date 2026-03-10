import 'package:flutter/material.dart';
import '../../models/UsuarioGeneral.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _confirmarController = TextEditingController();

  final UsuarioGeneral _logica = UsuarioGeneral();

  Future<void> _registrar() async {
    final email = _correoController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmarController.text.trim();
    final nombre = _nombreController.text.trim();

    if (email.isEmpty ||
        password.isEmpty ||
        confirm.isEmpty ||
        nombre.isEmpty) {
      _mostrarMensaje("Todos los campos son obligatorios", Colors.red);
      return;
    }

    if (!email.endsWith('@correo.unimet.edu.ve')) {
      _mostrarMensaje(
        "Solo se permiten correos @correo.unimet.edu.ve",
        Colors.red,
      );
      return;
    }

    if (password != confirm) {
      _mostrarMensaje("Las contraseñas no coinciden", Colors.red);
      return;
    }

    if (password.length < 6) {
      _mostrarMensaje(
        "La contraseña debe tener al menos 6 caracteres",
        Colors.red,
      );
      return;
    }

    _mostrarCargando();

    try {
      final nombre = _nombreController.text.trim();
      final usuario = await _logica.registrarUsuario(email, password, nombre);

      if (mounted) Navigator.pop(context);

      if (usuario != null) {
        _mostrarMensaje(
          "¡Cuenta creada con éxito! Disfruta de MetroShare",
          Colors.green,
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _mostrarMensaje("Error: El correo ya existe o es inválido", Colors.red);
    }
  }

  void _mostrarMensaje(String texto, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(texto), backgroundColor: color));
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/logometroshare.png', height: 100),
              const SizedBox(height: 30),
              const Text(
                "Registrarse",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              const Text(
                "Registrate con tu correo UNIMET",
                style: TextStyle(fontSize: 19, color: Color(0xFF666666)),
              ),
              const SizedBox(height: 30),

              //Nombre y Apellido
              _crearTextField(
                _nombreController,
                "Nombre y Apellido",
                Icons.person_outline,
                false,
              ),
              const SizedBox(height: 20),
              // Campo Correo
              _crearTextField(
                _correoController,
                "Email",
                Icons.email_outlined,
                false,
              ),
              const SizedBox(height: 20),

              // Campo Contrasena
              _crearTextField(
                _passwordController,
                "Contraseña",
                Icons.lock_outline,
                true,
              ),
              const SizedBox(height: 20),

              // Campo Confirmar Contrasena
              _crearTextField(
                _confirmarController,
                "Confirmar Contraseña",
                Icons.lock_clock_outlined,
                true,
              ),
              const SizedBox(height: 40),

              // Boton Registrarse
              ElevatedButton(
                onPressed: _registrar,
                style:
                    ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9500),
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ).copyWith(
                      backgroundColor: WidgetStateProperty.resolveWith<Color?>((
                        states,
                      ) {
                        if (states.contains(WidgetState.hovered)) {
                          return Colors.grey[300];
                        }
                        return const Color(0xFFFF9500);
                      }),
                    ),
                child: const Text(
                  "Registrarse",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _crearTextField(
    TextEditingController controller,
    String label,
    IconData icon,
    bool isPassword,
  ) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFD9D9D9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(icon),
      ),
    );
  }
}

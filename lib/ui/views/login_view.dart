import 'package:flutter/material.dart';
import '../../models/UsuarioGeneral.dart';
import 'register_view.dart';
import 'home_view.dart';
import 'admin_view.dart';
import 'librarian_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final UsuarioGeneral _logica = UsuarioGeneral();

  Future<void> _iniciarSesion() async {
    final email = _correoController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _notificar("Por favor, llena los campos", Colors.red);
      return;
    }

    if (!UsuarioGeneral.validarPassword(password)) {
      _notificar(UsuarioGeneral.mensajeErrorPassword, Colors.red);
      return;
    }

    if (!email.endsWith('@correo.unimet.edu.ve') && !email.endsWith('@unimet.edu.ve')) {
      _notificar("Solo se permiten correos @correo.unimet.edu.ve o @unimet.edu.ve", Colors.red);
      return;
    }

    _mostrarCargando();

    try {
      final usuario = await _logica.iniciarSesion(email, password);

      if (mounted) Navigator.pop(context);

      if (usuario != null) {
        // Obtener el rol del usuario
        final rol = await _logica.obtenerRolUsuario(usuario.uid);

        _notificar("¡Éxito! Bienvenido ($rol)", Colors.green);

        if (mounted) {
          Widget nextView;

          if (rol == 'admin') {
            nextView = const AdminView();
          } else if (rol == 'bibliotecario') {
            nextView = const LibrarianView();
          } else {
            nextView = const HomeView();
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => nextView),
          );
        }
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _notificar("Error: Datos incorrectos", Colors.red);
    }
  }

  void _notificar(String msj, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msj), backgroundColor: color));
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

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //Logo
              Image.asset('assets/images/logometroshare.png', height: 120),

              const SizedBox(height: 40),
              const Text(
                "Inicio de Sesión",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              const Text(
                "Inicia sesión con tu correo @correo.unimet.edu.ve o @unimet.edu.ve",
                style: TextStyle(fontSize: 19, color: Color(0xFF666666)),
              ),
              const SizedBox(height: 30),

              //Correo
              TextField(
                controller: _correoController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  filled: true,
                  fillColor: const Color(0xFFD9D9D9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
              ),

              const SizedBox(height: 20),

              //Contrasena
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  filled: true,
                  fillColor: const Color(0xFFD9D9D9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 40),
              //Iniciar Sesion
              ElevatedButton(
                onPressed: _iniciarSesion,
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
                        Set<WidgetState> states,
                      ) {
                        if (states.contains(WidgetState.hovered)) {
                          return Colors.grey[300];
                        }
                        return const Color(0xFFFF9500);
                      }),
                    ),
                child: const Text(
                  'Iniciar Sesión',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterView(),
                    ),
                  );
                },
                child: const Text(
                  "¿No tienes cuenta? Regístrate",
                  style: TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

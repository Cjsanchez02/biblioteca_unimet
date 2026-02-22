import 'package:flutter/material.dart';
import '../models/UsuarioGeneral.dart';
import 'registerscreen.dart';
import '../ui/views/home_view.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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

    _mostrarCargando();

    try {
      final usuario = await _logica.iniciarSesion(email, password);

      if (mounted) Navigator.pop(context);

      if (usuario != null) {
        _notificar("¡Éxito! Bienvenido", Colors.green);
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeView()),
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
                "Inicia sesión con tu correo UNIMET",
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
                      builder: (context) => const RegisterScreen(),
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

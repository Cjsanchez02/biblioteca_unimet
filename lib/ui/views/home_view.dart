import 'package:biblioteca_unimet/ui/views/donation_view.dart';
import 'package:flutter/material.dart';
import 'package:biblioteca_unimet/viewmodels/auth_viewmodel.dart';
import 'package:biblioteca_unimet/ui/views/edit_profile_view.dart';
import 'package:biblioteca_unimet/viewmodels/sugerencia_viewmodel.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  static const Color kOrange = Color(0xFFF7941D);
  static const Color kDarkGray = Color(0xFF333333);
  static const Color kLightGray = Color(0xFFF4F4F4);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // Construye la estructura principal
  final TextEditingController _sugerenciaController = TextEditingController();
  final HomeViewModel _viewModel = HomeViewModel();

  @override
  void dispose() {
    _sugerenciaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isDesktop = constraints.maxWidth > 800;

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildNavbar(isDesktop, context),
                const SizedBox(height: 40),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 80.0 : 20.0,
                  ),
                  child: Column(
                    children: [
                      _buildHeroSection(isDesktop),
                      const SizedBox(height: 80),
                      _buildActionSection(context, isDesktop),
                      const SizedBox(height: 60),
                      const Divider(thickness: 1, color: Colors.black12),
                      const SizedBox(height: 60),
                      _buildFooterSection(isDesktop),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Genera la barra de navegacion superior
  Widget _buildNavbar(bool isDesktop, BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80.0 : 20.0,
        vertical: 20,
      ),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Biblioteca Unimet',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: HomeView.kDarkGray,
            ),
          ),
          if (isDesktop)
            Row(
              children: [
                _navItem('Inicio', () {}),
                _navItem('Servicios', () {}),
                _navItem('Contactanos', () {}),
                _navItem('Editar Perfil', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfileView(),
                    ),
                  );
                }),

                _navItem('Cerrar Sesión', () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return _dialogoCerrarSesion(context);
                    },
                  );
                }),
              ],
            )
          else
            const Icon(Icons.menu, color: HomeView.kDarkGray),
        ],
      ),
    );
  }

  // Crea un enlace de texto individual para el menu
  Widget _navItem(String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(left: 30),
      child: TextButton(
        onPressed: onTap,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: HomeView.kDarkGray,
          ),
        ),
      ),
    );
  }

  // Construye la seccion principal con el mensaje de bienvenida y la primera imagen
  Widget _buildHeroSection(bool isDesktop) {
    Widget textContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: HomeView.kDarkGray,
              height: 1.1,
            ),
            children: [
              TextSpan(text: 'Un Puente entre\nsiglos de '),
              TextSpan(
                text: 'saber',
                style: TextStyle(color: HomeView.kOrange),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Accede a miles de recursos academicos, gestiona tus prestamos y contribuye con el desarrollo estudiantil a traves de donaciones.',
          style: TextStyle(fontSize: 18, color: Colors.black54, height: 1.5),
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: HomeView.kOrange,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {},
          child: const Text(
            'Explorar Biblioteca',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ],
    );

    Widget imageContent = Container(
      height: 400,
      width: double.infinity,
      decoration: BoxDecoration(
        color: HomeView.kLightGray,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          'assets/images/biblioteca_2.jpg',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(flex: 5, child: textContent),
          const SizedBox(width: 60),
          Expanded(flex: 5, child: imageContent),
        ],
      );
    } else {
      return Column(
        children: [imageContent, const SizedBox(height: 40), textContent],
      );
    }
  }

  // Renderiza los bloques de accion rapida (Catalogo, Prestamos, Donaciones)
  Widget _buildActionSection(BuildContext context, bool isDesktop) {
    List<Widget> actions = [
      _actionBlock(Icons.menu_book, 'Catalogo', () {}),
      _actionBlock(Icons.bookmark_added, 'Gestion y Prestamos', () {}),
      _actionBlock(Icons.volunteer_activism, 'Donaciones', () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: const Text('Redirección a página de pagos'),
              content: const Text(
                'Está a punto de ser redirigido a la plataforma de PayPal para continuar con su donación.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context), // Cierra el pop-up
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: HomeView.kOrange),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DonationView(),
                      ),
                    );
                  },
                  child: const Text('Continuar'),
                ),
              ],
            );
          },
        );
      }),
    ];

    if (isDesktop) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: actions
            .map(
              (a) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: a,
                ),
              ),
            )
            .toList(),
      );
    } else {
      return Column(
        children: actions
            .map(
              (a) =>
                  Padding(padding: const EdgeInsets.only(bottom: 30), child: a),
            )
            .toList(),
      );
    }
  }

  // Crea el diseno individual de cada boton de accion con su icono
  Widget _actionBlock(IconData icon, String title, VoidCallback onTap) {
    return Column(
      children: [
        Icon(icon, size: 60, color: Colors.black),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: HomeView.kOrange,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: onTap,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Construye la seccion inferior que contiene la segunda imagen
  Widget _buildFooterSection(bool isDesktop) {
    Widget imageContent = Container(
      height: 350,
      width: double.infinity,
      decoration: BoxDecoration(
        color: HomeView.kLightGray,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          'assets/images/pasillobiblioteca.jpg',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );

    Widget formContent = Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '¿Necesitas ayuda?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: HomeView.kDarkGray,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Habla con nuestro bibliotecario.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 30),
              // 1. La caja de texto conectada al controlador y con límite de 500
              TextField(
                controller: _sugerenciaController, // Conectamos el controlador
                maxLines: 4,
                maxLength: 500, // ¡Flutter pone el contador 0/500 automáticamente!
                decoration: InputDecoration(
                  hintText: 'Escribe tu mensaje aqui...',
                  hintStyle: const TextStyle(color: Colors.black38),
                  filled: true,
                  fillColor: HomeView.kLightGray, // Ajusté la constante por si marca error
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 2. El botón conectado a tu ViewModel
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HomeView.kOrange, // Ajusté la constante
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    // Llamamos a tu lógica limpia
                    bool exito = await _viewModel.enviarSugerencia(
                      _sugerenciaController.text, 
                      context
                    );
                    
                    // Si Firebase lo guardó bien, vaciamos la caja y avisamos
                    if (exito) {
                      _sugerenciaController.clear();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('¡Sugerencia enviada con éxito!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text(
                    'Enviar mensaje',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: -20,
          right: -20,
          child: CircleAvatar(
            radius: 30,
            backgroundColor: HomeView.kDarkGray,
            child: const Text(
              '?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(flex: 5, child: imageContent),
          const SizedBox(width: 60),
          Expanded(flex: 5, child: formContent),
        ],
      );
    } else {
      return Column(
        children: [formContent, const SizedBox(height: 40), imageContent],
      );
    }
  }

  Widget _dialogoCerrarSesion(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: const Row(
        children: [
          Icon(Icons.warning_amber_outlined, color: HomeView.kOrange),
          SizedBox(width: 10),
          Text('Cerrar Sesión'),
        ],
      ),
      content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar', style: TextStyle(color: Colors.black)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: HomeView.kOrange),
          onPressed: () async {
            Navigator.pop(context);
            final vm = AuthViewModel();
            await vm.cerrarSesion(context);
          },
          child: const Text(
            'Cerrar Sesión',
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }
}


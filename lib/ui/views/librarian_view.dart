import 'package:biblioteca_unimet/ui/views/donation_view.dart';
import 'package:flutter/material.dart';
import 'package:biblioteca_unimet/viewmodels/auth_viewmodel.dart';
import 'package:biblioteca_unimet/ui/views/edit_profile_view.dart';

class LibrarianView extends StatelessWidget {
  const LibrarianView({super.key});

  static const Color kOrange = Color(0xFFF7941D);
  static const Color kDarkGray = Color(0xFF333333);
  static const Color kLightGray = Color(0xFFF4F4F4);

  // Construye la estructura principal
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
            'MetroShare - Bibliotecario',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: kDarkGray,
            ),
          ),
          if (isDesktop)
            Row(
              children: [
                _navItem('Inicio', () {}),
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
            const Icon(Icons.menu, color: kDarkGray),
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
            color: kDarkGray,
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
              color: kDarkGray,
              height: 1.1,
            ),
            children: [
              TextSpan(text: 'Panel de\nGestión '),
              TextSpan(
                text: 'Bibliotecaria',
                style: TextStyle(color: kOrange),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Administra con eficiencia el corazón de la Universidad Metropolitana. Desde este panel, tienes las herramientas necesarias para supervisar el flujo de conocimiento: gestiona el catálogo completo, monitorea los préstamos activos de los estudiantes, analiza las métricas de uso y asegura que cada recurso esté al alcance de nuestra comunidad académica.',
          style: TextStyle(fontSize: 20, color: Colors.black54, height: 1.6),
        ),
      ],
    );

    Widget imageContent = Container(
      height: 400,
      width: double.infinity,
      decoration: BoxDecoration(
        color: kLightGray,
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

  // Renderiza los bloques de accion rapida (Catalogo, Prestamos, Donaciones, Estadisticas)
  Widget _buildActionSection(BuildContext context, bool isDesktop) {
    List<Widget> actions = [
      _actionBlock(Icons.menu_book, 'Catálogo', () {}),
      _actionBlock(Icons.bookmark_added, 'Gestión y Préstamos', () {}),
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
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: kOrange),
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
      _actionBlock(Icons.bar_chart, 'Estadísticas', () {
        // Botón no funcional por ahora.
      }),
    ];

    if (isDesktop) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: actions
            .map(
              (a) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
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
              backgroundColor: kOrange,
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
  // y el formulario de contacto

  Widget _buildFooterSection(bool isDesktop) {
    Widget imageContent = Container(
      height: 350,
      width: double.infinity,
      decoration: BoxDecoration(
        color: kLightGray,
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
                'Consultas Técnicas',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: kDarkGray,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Reporta problemas con el catálogo o el sistema.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 30),
              TextField(
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Escribe tu reporte aquí...',
                  hintStyle: const TextStyle(color: Colors.black38),
                  filled: true,
                  fillColor: kLightGray,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kOrange,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text(
                    'Enviar reporte',
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
            backgroundColor: kDarkGray,
            child: const Icon(Icons.support_agent, color: Colors.white),
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

  Widget _dialogoCerrCerrarSesion(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: const Row(
        children: [
          Icon(Icons.warning_amber_outlined, color: kOrange),
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
          style: ElevatedButton.styleFrom(backgroundColor: kOrange),
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

  Widget _dialogoCerrarSesion(BuildContext context) {
    return _dialogoCerrCerrarSesion(context);
  }
}

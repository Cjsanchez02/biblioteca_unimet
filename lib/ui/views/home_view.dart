import 'package:biblioteca_unimet/ui/views/donation_view.dart';
import 'package:biblioteca_unimet/ui/views/user_catalog_view.dart';
import 'package:biblioteca_unimet/ui/views/mymaterial_view.dart';
import 'package:flutter/material.dart';
import 'package:biblioteca_unimet/viewmodels/auth_viewmodel.dart';
import 'package:biblioteca_unimet/ui/views/edit_profile_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:biblioteca_unimet/viewmodels/sugerencia_viewmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:biblioteca_unimet/ui/widgets/dialog_calification.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // Construye la estructura principal
  final TextEditingController _sugerenciaController = TextEditingController();
  final HomeViewModel _viewModel = HomeViewModel();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final usuarioActual = FirebaseAuth.instance.currentUser;
      if (usuarioActual != null && usuarioActual.email != null) {
        _verificarCalificacionesPendientes(context, usuarioActual.email!);
      }
    });
  }

  // La función que busca en Firebase y lanza el pop-up
  Future<void> _verificarCalificacionesPendientes(
    BuildContext context,
    String correoUsuario,
  ) async {
    final db = FirebaseFirestore.instance;

    // Buscamos los préstamos de este estudiante marcados como 'devuelto'
    final pendientes = await db
        .collection('prestamos')
        .where('correoSolicitante', isEqualTo: correoUsuario)
        .where('estado', isEqualTo: 'devuelto')
        .get();

    for (var doc in pendientes.docs) {
      final data = doc.data();

      // Verificamos si ya existe la bandera 'calificado' y si es true
      bool yaFueCalificado = data.containsKey('calificado')
          ? data['calificado']
          : false;

      // Si no ha sido calificado, mostramos el Dialog
      if (!yaFueCalificado && context.mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => DialogoCalificacion(
            materialId: data['materialId'],
            transaccionId: doc.id,
            tituloLibro: data['tituloMaterial'],
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _sugerenciaController.dispose();
    super.dispose();
  }

  static const Color kOrange = Color(0xFFF7941D);
  static const Color kDarkGray = Color(0xFF333333);
  static const Color kLightGray = Color(0xFFF4F4F4);

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
              color: _HomeViewState.kDarkGray,
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
            const Icon(Icons.menu, color: _HomeViewState.kDarkGray),
        ],
      ),
    );
  }

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
            color: _HomeViewState.kDarkGray,
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(bool isDesktop) {
    Widget textContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: _HomeViewState.kDarkGray,
              height: 1.1,
            ),
            children: [
              TextSpan(text: 'Un Puente entre\nsiglos de '),
              TextSpan(
                text: 'saber',
                style: TextStyle(color: _HomeViewState.kOrange),
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
        _HomeActionCard(
          title: 'Explorar Biblioteca',
          icon: Icons.search,
          onTap: () {},
          isSmall: true,
          paddingHorizontal: 40,
        ),
      ],
    );

    Widget imageContent = Container(
      height: 400,
      width: double.infinity,
      decoration: BoxDecoration(
        color: _HomeViewState.kLightGray,
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

  Widget _buildActionSection(BuildContext context, bool isDesktop) {
    List<Widget> actions = [
      _HomeActionCard(
        icon: Icons.menu_book,
        title: 'Catalogo',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UserCatalogView()),
          );
        },
      ),
      _HomeActionCard(
        icon: Icons.bookmark_added,
        title: 'Gestion y Prestamos',
        onTap: () {
          final usuario = FirebaseAuth.instance.currentUser;
          if (usuario != null && usuario.email != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    MisPrestamosView(correoUsuario: usuario.email!),
              ),
            );
          }
        },
      ),
      _HomeActionCard(
        icon: Icons.volunteer_activism,
        title: 'Donaciones',
        onTap: () {
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
        },
      ),
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

  Widget _buildFooterSection(bool isDesktop) {
    Widget imageContent = Container(
      height: 350,
      width: double.infinity,
      decoration: BoxDecoration(
        color: _HomeViewState.kLightGray,
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
                color: Colors.black.withValues(alpha: 0.05),
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
                  color: _HomeViewState.kDarkGray,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Habla con nuestro bibliotecario.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ],
          ),
        ),
        Positioned(
          top: -20,
          right: -20,
          child: CircleAvatar(
            radius: 30,
            backgroundColor: _HomeViewState.kDarkGray,
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
          Icon(Icons.warning_amber_outlined, color: _HomeViewState.kOrange),
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
          style: ElevatedButton.styleFrom(
            backgroundColor: _HomeViewState.kOrange,
          ),
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

class _HomeActionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isSmall;
  final double paddingHorizontal;

  const _HomeActionCard({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isSmall = false,
    this.paddingHorizontal = 0,
  });

  @override
  State<_HomeActionCard> createState() => _HomeActionCardState();
}

class _HomeActionCardState extends State<_HomeActionCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          transform: Matrix4.identity()..scale(_isHovered ? 1.05 : 1.0),
          curve: Curves.easeOutBack,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!widget.isSmall) ...[
                Icon(
                  widget.icon,
                  size: 50,
                  color: _isHovered ? _HomeViewState.kOrange : Colors.black,
                ),
                const SizedBox(height: 15),
              ],
              Container(
                width: widget.paddingHorizontal > 0 ? null : double.infinity,
                padding: EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: widget.paddingHorizontal,
                ),
                decoration: BoxDecoration(
                  color: _isHovered
                      ? _HomeViewState.kDarkGray
                      : _HomeViewState.kOrange,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: _isHovered
                      ? [
                          BoxShadow(
                            color: _HomeViewState.kOrange.withValues(
                              alpha: 0.3,
                            ),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
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
      ),
    );
  }
}

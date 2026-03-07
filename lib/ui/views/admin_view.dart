import 'package:biblioteca_unimet/ui/views/admin_catalog_view.dart';
import 'package:biblioteca_unimet/ui/views/donation_view.dart';
import 'package:biblioteca_unimet/ui/views/admin_users_view.dart';
import 'package:biblioteca_unimet/ui/views/admin_donations_view.dart';

import 'package:flutter/material.dart';
import 'package:biblioteca_unimet/viewmodels/auth_viewmodel.dart';
import 'package:biblioteca_unimet/ui/views/edit_profile_view.dart';
import 'package:biblioteca_unimet/ui/views/estadisticas_view.dart';

class AdminView extends StatelessWidget {
  const AdminView({super.key});

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
                      _buildFooterSection(isDesktop, context),
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
            'MetroShare - Administrador',
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
                text: 'Global',
                style: TextStyle(color: kOrange),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Toma el control total del ecosistema digital de la biblioteca. Como administrador principal, supervisas la integridad de los datos, gestionas los permisos de usuarios y bibliotecarios, y evalúas el impacto estratégico de la plataforma mediante estadísticas globales detalladas, garantizando una experiencia educativa de excelencia para toda la UNIMET.',
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

  Widget _buildActionSection(BuildContext context, bool isDesktop) {
    List<Widget> actions = [
      _actionBlock(Icons.menu_book, 'Catálogo', () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AdminCatalogView()),
        );
      }),
      _actionBlock(Icons.bookmark_added, 'Gestión y Préstamos', () {}),
      _actionBlock(Icons.volunteer_activism, 'Donaciones', () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: const Text('Qué acción desea realizar?'),
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
      _actionBlock(Icons.manage_accounts, 'Administrar Usuarios', () {}),
      _actionBlock(Icons.bar_chart, 'Estadísticas', () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EstadisticasView()),
        );
      }),
      _AdminActionCard(icon: Icons.menu_book, title: 'Catálogo', onTap: () {}),
      _AdminActionCard(
        icon: Icons.bookmark_added,
        title: 'Gestión y Préstamos',
        onTap: () {},
      ),
      _AdminActionCard(
        icon: Icons.volunteer_activism,
        title: 'Ver Donaciones',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AdminDonationsView()),
          );
        },
      ),
      _AdminActionCard(
        icon: Icons.manage_accounts,
        title: 'Administrar Usuarios',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AdminUsersView()),
          );
        },
      ),
      _AdminActionCard(
        icon: Icons.query_stats,
        title: 'Estadísticas Globales',
        onTap: () {},
      ),
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

  Widget _buildFooterSection(bool isDesktop, BuildContext context) {
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

    Widget formContent = Container(
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
            'Panel de Administración',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: kDarkGray,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Gestiona todos los aspectos del sistema bibliotecario.',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      ),
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
}

class _AdminActionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _AdminActionCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  State<_AdminActionCard> createState() => _AdminActionCardState();
}

class _AdminActionCardState extends State<_AdminActionCard> {
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
            children: [
              Icon(
                widget.icon,
                size: 38,
                color: _isHovered ? AdminView.kOrange : Colors.black,
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _isHovered ? AdminView.kDarkGray : AdminView.kOrange,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: _isHovered
                        ? [
                            BoxShadow(
                              color: AdminView.kOrange.withOpacity(0.3),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

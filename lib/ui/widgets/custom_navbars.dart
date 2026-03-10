import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../views/general_users_view.dart';
import '../views/home_view.dart';
import '../views/librarian_view.dart';
import '../views/login_view.dart';
import '../views/user_catalog_view.dart';
import '../views/librarian_catalog_view.dart';
import '../views/librarian_prestamos_view.dart';
import '../views/mymaterial_view.dart';
import '../views/donation_view.dart';
import '../views/edit_profile_view.dart';
import '../views/estadisticas_view.dart';
import '../../viewmodels/auth_viewmodel.dart';

enum HomeTab { inicio, login }

enum UserTab { inicio, catalogo, prestamos, donaciones, perfil, salir }

enum LibrarianTab { inicio, catalogo, prestamos, estadisticas, perfil, salir }

class HomeNavbar extends StatelessWidget {
  final HomeTab activeTab;
  const HomeNavbar({super.key, required this.activeTab});

  @override
  Widget build(BuildContext context) {
    return _BaseNavbar(
      items: [
        _NavbarItemConfig(
          icon: Icons.home,
          label: 'Inicio',
          isActive: activeTab == HomeTab.inicio,
          onTap: () => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const GeneralUsersView()),
            (route) => false,
          ),
        ),
        _NavbarItemConfig(
          icon: Icons.login,
          label: 'Iniciar Sesión',
          isActive: activeTab == HomeTab.login,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginView()),
          ),
        ),
      ],
    );
  }
}

class UserNavbar extends StatelessWidget {
  final UserTab activeTab;
  const UserNavbar({super.key, required this.activeTab});

  @override
  Widget build(BuildContext context) {
    return _BaseNavbar(
      items: [
        _NavbarItemConfig(
          icon: Icons.home,
          label: 'Inicio',
          isActive: activeTab == UserTab.inicio,
          onTap: () => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeView()),
            (route) => false,
          ),
        ),
        _NavbarItemConfig(
          icon: Icons.menu_book,
          label: 'Catálogo',
          isActive: activeTab == UserTab.catalogo,
          onTap: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const UserCatalogView()),
          ),
        ),
        _NavbarItemConfig(
          icon: Icons.bookmark_added,
          label: 'Mis Préstamos',
          isActive: activeTab == UserTab.prestamos,
          onTap: () {
            final user = FirebaseAuth.instance.currentUser;
            if (user?.email != null) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      MisPrestamosView(correoUsuario: user!.email!),
                ),
              );
            }
          },
        ),
        _NavbarItemConfig(
          icon: Icons.volunteer_activism,
          label: 'Donaciones',
          isActive: activeTab == UserTab.donaciones,
          onTap: () => _mostrarDialogoDonacion(context),
        ),
        _NavbarItemConfig(
          icon: Icons.person,
          label: 'Perfil',
          isActive: activeTab == UserTab.perfil,
          onTap: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const EditProfileView()),
          ),
        ),
        _NavbarItemConfig(
          icon: Icons.logout,
          label: 'Salir',
          isActive: activeTab == UserTab.salir,
          onTap: () => _mostrarDialogoCerrarSesion(context),
        ),
      ],
    );
  }
}

class LibrarianNavbar extends StatelessWidget {
  final LibrarianTab activeTab;
  const LibrarianNavbar({super.key, required this.activeTab});

  @override
  Widget build(BuildContext context) {
    return _BaseNavbar(
      items: [
        _NavbarItemConfig(
          icon: Icons.home,
          label: 'Inicio',
          isActive: activeTab == LibrarianTab.inicio,
          onTap: () => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LibrarianView()),
            (route) => false,
          ),
        ),
        _NavbarItemConfig(
          icon: Icons.menu_book,
          label: 'Catálogo',
          isActive: activeTab == LibrarianTab.catalogo,
          onTap: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const LibrarianCatalogView(),
            ),
          ),
        ),
        _NavbarItemConfig(
          icon: Icons.bookmark_added,
          label: 'Préstamos',
          isActive: activeTab == LibrarianTab.prestamos,
          onTap: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LibrarianPrestamosView()),
          ),
        ),
        _NavbarItemConfig(
          icon: Icons.query_stats,
          label: 'Estadísticas',
          isActive: activeTab == LibrarianTab.estadisticas,
          onTap: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const EstadisticasView()),
          ),
        ),
        _NavbarItemConfig(
          icon: Icons.person,
          label: 'Perfil',
          isActive: activeTab == LibrarianTab.perfil,
          onTap: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const EditProfileView()),
          ),
        ),
        _NavbarItemConfig(
          icon: Icons.logout,
          label: 'Salir',
          isActive: activeTab == LibrarianTab.salir,
          onTap: () => _mostrarDialogoCerrarSesion(context),
        ),
      ],
    );
  }
}

// ── Widget Base ──
class _BaseNavbar extends StatelessWidget {
  final List<_NavbarItemConfig> items;
  const _BaseNavbar({required this.items});

  static const Color kOrange = Color(0xFFF7941D);
  static const Color kDarkGray = Color(0xFF333333);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.map((config) => _NavIconItem(config: config)).toList(),
      ),
    );
  }
}

class _NavbarItemConfig {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  _NavbarItemConfig({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });
}

class _NavIconItem extends StatefulWidget {
  final _NavbarItemConfig config;
  const _NavIconItem({required this.config});

  @override
  State<_NavIconItem> createState() => _NavIconItemState();
}

class _NavIconItemState extends State<_NavIconItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final Color color = widget.config.isActive
        ? _BaseNavbar.kDarkGray
        : (_isHovered
              ? _BaseNavbar.kOrange.withValues(alpha: 0.7)
              : _BaseNavbar.kOrange);

    return MouseRegion(
      onEnter: (_) {
        if (!widget.config.isActive) setState(() => _isHovered = true);
      },
      onExit: (_) {
        if (!widget.config.isActive) setState(() => _isHovered = false);
      },
      cursor: widget.config.isActive
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.config.isActive ? null : widget.config.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()..scale(_isHovered ? 1.15 : 1.0),
          curve: Curves.easeOutBack,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.config.icon,
                color: color,
                size: widget.config.isActive ? 32 : (_isHovered ? 30 : 28),
              ),
              const SizedBox(height: 4),
              Text(
                widget.config.label,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: widget.config.isActive
                      ? FontWeight.bold
                      : (_isHovered ? FontWeight.bold : FontWeight.normal),
                ),
              ),
              if (widget.config.isActive)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  height: 2,
                  width: 20,
                  color: _BaseNavbar.kDarkGray,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Diálogos Comunes ──
void _mostrarDialogoDonacion(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Redirección a página de pagos'),
        content: const Text(
          'Está a punto de ser redirigido a la plataforma de PayPal para continuar con su donación.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF7941D),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DonationView()),
              );
            },
            child: const Text('Continuar'),
          ),
        ],
      );
    },
  );
}

void _mostrarDialogoCerrarSesion(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_outlined, color: Color(0xFFF7941D)),
            SizedBox(width: 10),
            Text('Cerrar Sesión'),
          ],
        ),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
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
              backgroundColor: const Color(0xFFF7941D),
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
    },
  );
}

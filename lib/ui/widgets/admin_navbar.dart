import 'package:flutter/material.dart';
import '../views/admin_view.dart';
import '../views/admin_donations_view.dart';
import '../views/admin_users_view.dart';
import '../views/general_users_view.dart';
import '../views/librarian_prestamos_view.dart';
import '../views/estadisticas_view.dart';

enum AdminTab { inicio, donaciones, usuarios, catalogo, prestamos, estadisticas }

class AdminNavbar extends StatelessWidget {
  final AdminTab activeTab;

  const AdminNavbar({super.key, required this.activeTab});

  static const Color kOrange = Color(0xFFF7941D);
  static const Color kDarkGray = Color(0xFF333333);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavIconItem(
            icon: Icons.home,
            label: 'Inicio',
            isActive: activeTab == AdminTab.inicio,
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const AdminView()),
                (route) => false,
              );
            },
          ),
          _NavIconItem(
            icon: Icons.volunteer_activism,
            label: 'Donaciones',
            isActive: activeTab == AdminTab.donaciones,
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminDonationsView(),
                ),
              );
            },
          ),
          _NavIconItem(
            icon: Icons.manage_accounts,
            label: 'Usuarios',
            isActive: activeTab == AdminTab.usuarios,
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminUsersView(),
                ),
              );
            },
          ),
          _NavIconItem(
            icon: Icons.menu_book,
            label: 'Catálogo',
            isActive: activeTab == AdminTab.catalogo,
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const GeneralUsersView(),
                ),
              );
            },
          ),
          _NavIconItem(
            icon: Icons.bookmark_added,
            label: 'Préstamos',
            isActive: activeTab == AdminTab.prestamos,
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => LibrarianPrestamosView(),
                ),
              );
            },
          ),
          _NavIconItem(
            icon: Icons.query_stats,
            label: 'Estadísticas',
            isActive: activeTab == AdminTab.estadisticas,
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const EstadisticasView(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _NavIconItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const _NavIconItem({
    required this.icon,
    required this.label,
    required this.isActive,
    this.onTap,
  });

  @override
  State<_NavIconItem> createState() => _NavIconItemState();
}

class _NavIconItemState extends State<_NavIconItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final Color color = widget.isActive
        ? AdminNavbar.kDarkGray
        : (_isHovered
              ? AdminNavbar.kOrange.withValues(alpha: 0.7)
              : AdminNavbar.kOrange);

    return MouseRegion(
      onEnter: (_) {
        if (!widget.isActive) setState(() => _isHovered = true);
      },
      onExit: (_) {
        if (!widget.isActive) setState(() => _isHovered = false);
      },
      cursor: widget.isActive
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.isActive ? null : widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()..scale(_isHovered ? 1.15 : 1.0),
          curve: Curves.easeOutBack,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                color: color,
                size: widget.isActive ? 32 : (_isHovered ? 30 : 28),
              ),
              const SizedBox(height: 4),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: widget.isActive
                      ? FontWeight.bold
                      : (_isHovered ? FontWeight.bold : FontWeight.normal),
                ),
              ),
              if (widget.isActive)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  height: 2,
                  width: 20,
                  color: AdminNavbar.kDarkGray,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

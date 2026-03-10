import 'package:flutter/material.dart';
import 'admin_view.dart';
import 'admin_donations_view.dart';

class AdminUsersView extends StatelessWidget {
  const AdminUsersView({super.key});

  static const Color kOrange = Color(0xFFF7941D);
  static const Color kDarkGray = Color(0xFF333333);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Administrar Usuarios'),
        backgroundColor: kOrange,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildNavbar(context),
          const Divider(height: 1),
          const Expanded(
            child: Center(
              child: Text(
                'Panel de Gestión de Usuarios\n(Próximamente)',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavbar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavIconItem(
            icon: Icons.home,
            label: 'Inicio',
            isActive: false,
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
            isActive: false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminDonationsView(),
                ),
              );
            },
          ),
          const _NavIconItem(
            icon: Icons.manage_accounts,
            label: 'Usuarios',
            isActive: true,
          ),

          const _NavIconItem(
            icon: Icons.menu_book,
            label: 'Catálogo',
            isActive: false,
          ),
          const _NavIconItem(
            icon: Icons.bookmark_added,
            label: 'Préstamos',
            isActive: false,
          ),
          const _NavIconItem(
            icon: Icons.query_stats,
            label: 'Estadísticas',
            isActive: false,
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
        ? AdminUsersView.kDarkGray
        : (_isHovered
              ? AdminUsersView.kOrange.withOpacity(0.7)
              : AdminUsersView.kOrange);

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
                  color: AdminUsersView.kDarkGray,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

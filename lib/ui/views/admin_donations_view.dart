import 'package:flutter/material.dart';
import '../../services/servicio_donaciones.dart';
import '../../models/donacion.dart';
import 'admin_users_view.dart';

import 'admin_view.dart';

class AdminDonationsView extends StatelessWidget {
  const AdminDonationsView({super.key});

  static const Color kOrange = Color(0xFFF7941D);
  static const Color kDarkGray = Color(0xFF333333);

  @override
  Widget build(BuildContext context) {
    final ServicioDonaciones servicio = ServicioDonaciones();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Donaciones Recibidas'),
        backgroundColor: kOrange,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildNavbar(context),
          const Divider(height: 1),
          Expanded(
            child: StreamBuilder<List<Donacion>>(
              stream: servicio.obtenerDonaciones(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final donaciones = snapshot.data ?? [];

                if (donaciones.isEmpty) {
                  return const Center(
                    child: Text(
                      'No hay donaciones registradas aún.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: donaciones.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final donacion = donaciones[index];
                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFFDECDA),
                        child: Icon(Icons.volunteer_activism, color: kOrange),
                      ),
                      title: Text(
                        donacion.nombreUsuario ?? 'Usuario Anónimo',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        donacion.usuarioEmail ?? 'Sin correo',
                        style: const TextStyle(color: Colors.black38),
                      ),
                      trailing: Text(
                        '${donacion.monto.toStringAsFixed(2)} ${donacion.moneda}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    );
                  },
                );
              },
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
          const _NavIconItem(
            icon: Icons.volunteer_activism,
            label: 'Donaciones',
            isActive: true,
          ),
          _NavIconItem(
            icon: Icons.manage_accounts,
            label: 'Usuarios',
            isActive: false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminUsersView()),
              );
            },
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
        ? AdminDonationsView.kDarkGray
        : (_isHovered
              ? AdminDonationsView.kOrange.withOpacity(0.7)
              : AdminDonationsView.kOrange);

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
                  color: AdminDonationsView.kDarkGray,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

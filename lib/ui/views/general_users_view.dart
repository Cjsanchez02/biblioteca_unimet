import 'package:biblioteca_unimet/ui/views/donation_view.dart';
import 'package:biblioteca_unimet/ui/views/user_catalog_view.dart';
import 'package:flutter/material.dart';
import 'package:biblioteca_unimet/ui/views/login_view.dart';

class GeneralUsersView extends StatefulWidget {
  const GeneralUsersView({super.key});

  @override
  State<GeneralUsersView> createState() => _GeneralUsersViewState();
}

class _GeneralUsersViewState extends State<GeneralUsersView> {
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
              color: kDarkGray,
            ),
          ),
          if (isDesktop)
            Row(
              children: [
                _navItem('Inicio', () {}),
                _navItem('Iniciar Sesión', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginView()),
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
            style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: kDarkGray, height: 1.1),
            children: [
              TextSpan(text: 'Un Puente entre\nsiglos de '),
              TextSpan(text: 'saber', style: TextStyle(color: kOrange)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Accede a miles de recursos academicos, gestiona tus prestamos y contribuye con el desarrollo estudiantil a traves de donaciones.',
          style: TextStyle(fontSize: 18, color: Colors.black54, height: 1.5),
        ),
        const SizedBox(height: 40),
        _GeneralUsersActionCard(
          title: 'Explorar Biblioteca',
          icon: Icons.search,
          onTap: () {
             Navigator.push(context, MaterialPageRoute(builder: (context) => const UserCatalogView()));
          },
          isSmall: true,
          paddingHorizontal: 40,
        ),
      ],
    );

    Widget imageContent = Container(
      height: 400,
      width: double.infinity,
      decoration: BoxDecoration(color: kLightGray, borderRadius: BorderRadius.circular(20)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset('assets/images/biblioteca_2.jpg', fit: BoxFit.cover, width: double.infinity, height: double.infinity),
      ),
    );

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [Expanded(flex: 5, child: textContent), const SizedBox(width: 60), Expanded(flex: 5, child: imageContent)],
      );
    } else {
      return Column(children: [imageContent, const SizedBox(height: 40), textContent]);
    }
  }

  Widget _buildActionSection(BuildContext context, bool isDesktop) {
    List<Widget> actions = [
      _GeneralUsersActionCard(
        icon: Icons.menu_book,
        title: 'Catalogo',
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const UserCatalogView()));
        },
      ),
      _GeneralUsersActionCard(
        icon: Icons.volunteer_activism,
        title: 'Donaciones',
        onTap: () => _mostrarDialogoDonacion(context),
      ),
    ];

    if (isDesktop) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: actions.map((a) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 15), child: a))).toList(),
      );
    } else {
      return Column(children: actions.map((a) => Padding(padding: const EdgeInsets.only(bottom: 30), child: a)).toList());
    }
  }

  void _mostrarDialogoDonacion(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text('Redirección a página de pagos'),
          content: const Text('Está a punto de ser redirigido a la plataforma de PayPal para continuar con su donación.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: kOrange),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const DonationView()));
              },
              child: const Text('Continuar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFooterSection(bool isDesktop) {
    Widget imageContent = Container(
      height: 350,
      width: double.infinity,
      decoration: BoxDecoration(color: kLightGray, borderRadius: BorderRadius.circular(20)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset('assets/images/pasillobiblioteca.jpg', fit: BoxFit.cover, width: double.infinity, height: double.infinity),
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
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('¿Necesitas ayuda?', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: kDarkGray)),
              SizedBox(height: 10),
              Text('¿Buscas un libro específico? Inicia sesión para solicitarlo a nuestro bibliotecario.', style: TextStyle(fontSize: 16, color: Colors.black54)),
            ],
          ),
        ),
        Positioned(
          top: -20,
          right: -20,
          child: CircleAvatar(radius: 30, backgroundColor: kDarkGray, child: const Text('?', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))),
        ),
      ],
    );

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [Expanded(flex: 5, child: imageContent), const SizedBox(width: 60), Expanded(flex: 5, child: formContent)],
      );
    } else {
      return Column(children: [formContent, const SizedBox(height: 40), imageContent]);
    }
  }
}

class _GeneralUsersActionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isSmall;
  final double paddingHorizontal;

  const _GeneralUsersActionCard({required this.icon, required this.title, required this.onTap, this.isSmall = false, this.paddingHorizontal = 0});

  @override
  State<_GeneralUsersActionCard> createState() => _GeneralUsersActionCardState();
}

class _GeneralUsersActionCardState extends State<_GeneralUsersActionCard> {
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
                Icon(widget.icon, size: 50, color: _isHovered ? _GeneralUsersViewState.kOrange : Colors.black),
                const SizedBox(height: 15),
              ],
              Container(
                width: widget.paddingHorizontal > 0 ? null : double.infinity,
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: widget.paddingHorizontal),
                decoration: BoxDecoration(
                  color: _isHovered ? _GeneralUsersViewState.kDarkGray : _GeneralUsersViewState.kOrange,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: _isHovered ? [BoxShadow(color: _GeneralUsersViewState.kOrange.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))] : [],
                ),
                child: Center(
                  child: Text(widget.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

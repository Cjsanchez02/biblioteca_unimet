import 'package:flutter/material.dart';
import '../widgets/custom_navbars.dart';
import 'package:biblioteca_unimet/services/servicio_material.dart';
import 'package:biblioteca_unimet/viewmodels/material_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:biblioteca_unimet/services/servicio_biblioteca.dart';
import 'package:biblioteca_unimet/models/MaterialBibliografico.dart';

class UserCatalogView extends StatefulWidget {
  const UserCatalogView({super.key});

  @override
  State<UserCatalogView> createState() => _UserCatalogViewState();
}

class _UserCatalogViewState extends State<UserCatalogView> {
  final Color kOrange = const Color(0xFFF7941D);
  final MaterialViewModel _viewModel = MaterialViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const UserNavbar(activeTab: UserTab.catalogo),
          const Divider(height: 1),
          _buildSearchHeader(),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LADO IZQUIERDO: Resultados
                Expanded(flex: 3, child: _buildResultadosList()),

                // LADO DERECHO: Filtros
                Container(
                  width: 250,
                  margin: const EdgeInsets.all(15),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC4C4C4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _buildPanelFiltros(),
                ),
              ],
            ),
          ),
        ],
      ),
      // Nota: No hay FloatingActionButton aquí ya que el usuario no agrega material
    );
  }

// Construye el encabezado de búsqueda
  Widget _buildSearchHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          const Text("Búsqueda :", style: TextStyle(fontSize: 13)),
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 45,
                  child: TextField(
                    onChanged: (val) => _viewModel.setTextoTemporal(val),
                    decoration: InputDecoration(
                      hintText: "Contiene...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                height: 45,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: TextButton.icon(
                  onPressed: () => _viewModel.aplicarFiltro(),
                  icon: const Icon(Icons.search, color: Colors.black, size: 20),
                  label: Text("BUSCAR", style: TextStyle(color: kOrange, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

// Construye la lista de resultados usando StreamBuilder para escuchar cambios en la base de datos
  Widget _buildResultadosList() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: servicioMaterial().obtenerMateriales(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final materiales = _viewModel.filtrarMateriales(snapshot.data!);

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: materiales.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) => _itemMaterialBarra(materiales[index], index + 1),
        );
      },
    );
  }

// Construye los items, mostrando información relevante
  Widget _itemMaterialBarra(Map<String, dynamic> material, int index) {
    bool disponible = (material['stock'] ?? 0) > 0;
    String tipo = material['tipo'] ?? 'Libro'; // Obtenemos el tipo
    IconData iconoTipo;
  switch (tipo) {
    case 'Guía':
      iconoTipo = Icons.assignment;
      break;
    case 'Revista':
      iconoTipo = Icons.auto_stories;
      break;
    case 'Tesis':
      iconoTipo = Icons.school;
      break;
    case 'Libro':
    default:
      iconoTipo = Icons.book;
      break;
  }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$index", style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 10),
          Container(
            width: 60, height: 80, color: Colors.black,
            child: Icon(iconoTipo, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("MATERIAL ACADÉMICO", style: TextStyle(fontSize: 10, color: Colors.grey)),
                Text(
                  material['titulo'],
                  style: const TextStyle(color: Color(0xFF005581), fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                ),
                Text("Autor: ${material['autor']}", style: const TextStyle(fontSize: 12)),
                Text("Materia: ${material['materia']}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(
                  disponible 
                  ? "Disponible en MetroShare, ${material['stock']} en stock" 
                  : "No disponible",
                  style: TextStyle(
                    fontSize: 12, 
                    color: disponible ? Colors.green : Colors.red,
                    fontWeight: disponible ? FontWeight.normal : FontWeight.bold
                  ),
                ),
              ],
            ),
          ),
          // SECCIÓN DE ESTRELLAS Y BOTÓN DE SOLICITUD
          Column(
            children: [
              Row(
                children: List.generate(5, (i) => Icon(
                  Icons.star, size: 15, 
                  color: i < (material['calificacionPromedio'] ?? 0) ? Colors.amber : Colors.grey[300]
                )),
              ),
              const SizedBox(height: 10),
              // BOTÓN DE SOLICITAR (Solo habilitado si hay stock)
              ElevatedButton(
                onPressed: disponible ? () async {
                  final usuarioActual = FirebaseAuth.instance.currentUser;
                  
                  if (usuarioActual != null && usuarioActual.email != null) {
                    String correo = usuarioActual.email!;

                   
                    MaterialBibliografico libroSolicitado = MaterialBibliografico.fromMap(
                      material, 
                      material['id'] ?? '',
                    );

                    
                    String exito = await BibliotecaService().solicitarPrestamo(correo, libroSolicitado);

                    if (context.mounted) {
                      if ( exito.startsWith("¡Préstamo solicitado con éxito!")) {
                        ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(
                            content: Text(exito),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(
                            content: Text(exito),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Inicia sesión para pedir libros.'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                } : null, // Apagado si no hay stock
                
                style: ElevatedButton.styleFrom(
                  backgroundColor: disponible ? kOrange : Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)
                ),
                child: Text(disponible ? "SOLICITAR" : "AGOTADO"),
              ),
            ],
          ),
        ],
      ),
    );
  }

// Panel lateral de filtros
  Widget _buildPanelFiltros() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.filter_alt, size: 18),
            SizedBox(width: 5),
            Text("Filtros", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 15),
        _buildDropdownFiltro(),
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton.icon(
            onPressed: () => _viewModel.aplicarFiltro(),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, fixedSize: const Size(180, 40)),
            icon: const Icon(Icons.filter_list, color: Colors.black),
            label: const Text("Aplicar filtros", style: TextStyle(color: Colors.black)),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownFiltro() {
    return DropdownButtonFormField<String>(
      initialValue: _viewModel.criterio,
      decoration: const InputDecoration(filled: true, fillColor: Colors.white70, isDense: true),
      items: ["Título", "Autor", "Materia"].map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 12)))).toList(),
      onChanged: _viewModel.actualizarCriterio,
    );
  }
}
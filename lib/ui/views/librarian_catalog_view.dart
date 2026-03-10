import 'package:flutter/material.dart';
import '../widgets/custom_navbars.dart';
import 'package:biblioteca_unimet/services/servicio_material.dart';
import 'package:biblioteca_unimet/viewmodels/material_viewmodel.dart';

class LibrarianCatalogView extends StatefulWidget {
  const LibrarianCatalogView({super.key});

  @override
  State<LibrarianCatalogView> createState() => _LibrarianCatalogViewState();
}

class _LibrarianCatalogViewState extends State<LibrarianCatalogView> {
  final Color kOrange = const Color(0xFFF7941D);
  final MaterialViewModel _viewModel = MaterialViewModel();

  @override
  void initState() {
    super.initState();
    // Escucha al ViewModel para actualizar la UI cuando se apliquen filtros
    _viewModel.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const LibrarianNavbar(activeTab: LibrarianTab.catalogo),
          const Divider(height: 1),
          _buildSearchHeader(),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Listado de materiales
                Expanded(flex: 3, child: _buildResultadosList()),

                //Panel de filtros
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
      // Sin FloatingActionButton: El bibliotecario no añade registros
    );
  }

  // Construye el encabezado de búsqueda
  Widget _buildSearchHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "CRITERIOS DE BÚSQUEDA",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 45,
                  child: TextField(
                    onChanged: (val) => _viewModel.setTextoTemporal(
                      val,
                    ), // Guarda el texto sin filtrar aún
                    decoration: InputDecoration(
                      hintText: "Consultar campo...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
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
                  onPressed: () =>
                      _viewModel.aplicarFiltro(), // Ejecuta la búsqueda
                  icon: const Icon(Icons.search, color: Colors.black, size: 20),
                  label: Text(
                    "BUSCAR",
                    style: TextStyle(
                      color: kOrange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        final materiales = _viewModel.filtrarMateriales(snapshot.data!);

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: materiales.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) =>
              _itemMaterialBarra(materiales[index], index + 1),
        );
      },
    );
  }

  // Construye los items, mostrando información relevante
  Widget _itemMaterialBarra(Map<String, dynamic> material, int index) {
    int stockActual = material['stock'] ?? 0;
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
            width: 60,
            height: 80,
            color: Colors.black,
            child: Icon(iconoTipo, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "VISTA DE BIBLIOTECARIO",
                  style: TextStyle(fontSize: 10, color: Colors.blueGrey),
                ),
                Text(
                  material['titulo'],
                  style: const TextStyle(
                    color: Color(0xFF005581),
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
                Text(
                  "Autor: ${material['autor']}",
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  "Materia: ${material['materia']}",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  stockActual > 0
                      ? "Stock actual: $stockActual unidades"
                      : "No disponible",
                  style: TextStyle(
                    fontSize: 12,
                    color: stockActual > 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Estrellas de calificación (Solo visual)
          Column(
            children: [
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    Icons.star,
                    size: 15,
                    color: i < (material['calificacionPromedio'] ?? 0)
                        ? Colors.amber
                        : Colors.grey[300],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Icon(
                Icons.visibility_outlined,
                color: Colors.grey,
                size: 20,
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
            Icon(Icons.inventory_2_outlined, size: 18),
            SizedBox(width: 5),
            Text(
              "Inventario",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 15),
        DropdownButtonFormField<String>(
          initialValue: _viewModel.criterio,
          decoration: const InputDecoration(
            filled: true,
            fillColor: Colors.white70,
            isDense: true,
          ),
          items: ["Título", "Autor", "Materia"]
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: const TextStyle(fontSize: 12)),
                ),
              )
              .toList(),
          // CAMBIO AQUÍ: Usamos el método que no notifica cambios
          onChanged: (val) => _viewModel.actualizarCriterio(val),
        ),
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton(
            // Al presionar este botón, se ejecuta notifyListeners() dentro de aplicarFiltro
            onPressed: () => _viewModel.aplicarFiltro(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
            child: const Text("Refrescar filtros"),
          ),
        ),
      ],
    );
  }
}

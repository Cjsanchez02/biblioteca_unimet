import 'package:flutter/material.dart';
import 'package:biblioteca_unimet/services/servicio_material.dart';
import 'package:biblioteca_unimet/ui/views/admin_form_view.dart';
import 'package:biblioteca_unimet/viewmodels/material_viewmodel.dart';

class AdminCatalogView extends StatefulWidget {
  const AdminCatalogView({super.key});
  @override
  State<AdminCatalogView> createState() => _AdminCatalogoViewState();
}

class _AdminCatalogoViewState extends State<AdminCatalogView> {
  Color kOrange = Color(0xFFF7941D);
  // Instanciamos el ViewModel
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
      appBar: AppBar(
        title: const Text(
          "Catálogo en línea - MetroShare",
          style: TextStyle(fontSize: 14),
        ),
        backgroundColor: kOrange,
      ),
      body: Column(
        children: [
          // Barra de búsqueda superior (Header)
          _buildSearchHeader(),

          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LADO IZQUIERDO: Resultados en "Barras"
                Expanded(flex: 3, child: _buildResultadosList()),

                // LADO DERECHO: Caja de Filtros Avanzados
                Container(
                  width: 250,
                  margin: const EdgeInsets.all(15),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC4C4C4), // Gris del diseño
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _buildPanelFiltros(),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(ModoFormulario.agregar, null),
        backgroundColor: const Color(0xFFE58D2E),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Header de búsqueda con campo de texto y botón de búsqueda
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
          const Text("Búsqueda :", style: TextStyle(fontSize: 13)),
          const SizedBox(height: 5),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: SizedBox(
                  height: 45,
                  child: TextField(
                    onChanged: (val) => _viewModel.setTextoTemporal(val),
                    decoration: InputDecoration(
                      hintText: "Contiene...",
                      hintStyle: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
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
              // Botón de BUSCAR
              Container(
                height: 45,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: TextButton.icon(
                  onPressed: () => _viewModel.aplicarFiltro(),
                  icon: const Icon(Icons.search, color: Colors.black, size: 20),
                  label: const Text(
                    "BUSCAR",
                    style: TextStyle(
                      color: Color(0xFFE58D2E), // kOrange
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
        ],
      ),
    );
  }

  // Construye la lista de resultados usando StreamBuilder para escuchar cambios en la base de datos
  Widget _buildResultadosList() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: servicioMaterial().obtenerMateriales(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
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
          // Imagen/Miniatura
          Container(
            width: 60,
            height: 80,
            color: Colors.black,
            child: Icon(iconoTipo, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 15),
          // Información central
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "MATERIAL ACADÉMICO",
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
                InkWell(
                  onTap: () => _mostrarDetallesMaterial(
                    material,
                  ), // Nueva función para admin
                  child: Text(
                    material['titulo'],
                    style: const TextStyle(
                      color: Color(0xFF005581),
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      fontSize: 14,
                    ),
                  ),
                ),
                Text(
                  "Autor:${material['autor']}",
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  "Materia: ${material['materia']}",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  material['stock'] > 0
                      ? "Disponible en MetroShare, ${material['stock']} en stock"
                      : "No disponible",
                  style: TextStyle(
                    fontSize: 12,
                    color: material['stock'] > 0 ? Colors.green : Colors.red,
                    fontWeight: material['stock'] > 0
                        ? FontWeight.normal
                        : FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Estrellas y Acciones (Admin)
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
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
                    onPressed: () =>
                        _abrirFormulario(ModoFormulario.editar, material),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                    onPressed: () =>
                        _abrirFormulario(ModoFormulario.eliminar, material),
                  ),
                ],
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
            Text(
              "Filtros",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 15),
        const Text(
          "Filtrar por",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const Divider(color: Colors.white),
        _buildDropdownFiltro("Filtrar por:"),
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton.icon(
            // CAMBIO: Este botón también confirma la búsqueda
            onPressed: () => _viewModel.aplicarFiltro(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              fixedSize: const Size(180, 40),
            ),
            icon: const Icon(Icons.filter_list, color: Colors.black),
            label: const Text(
              "Aplicar filtros",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownFiltro(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: DropdownButtonFormField<String>(
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
        onChanged: _viewModel.actualizarCriterio,
      ),
    );
  }

  void _abrirFormulario(ModoFormulario modo, Map<String, dynamic>? material) {
    showDialog(
      context: context,
      // Evita que se cierre el diálogo si tocan fuera por accidente mientras escriben
      barrierDismissible: false,
      builder: (context) => AdminMaterialForm(
        modo: modo,
        materialExistente: material, // Será null si el modo es agregar
      ),
    );
  }

  void _mostrarDetallesMaterial(Map<String, dynamic> material) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      double screenWidth = MediaQuery.of(context).size.width;
      bool isDesktop = screenWidth > 700;

      return Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          width: isDesktop ? 600 : screenWidth,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: isDesktop ? BorderRadius.circular(20) : const BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Encabezado: Tipo y Cerrar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: kOrange.withAlpha((0.1 * 255).toInt()), borderRadius: BorderRadius.circular(5)),
                            child: Text(material['tipo'] ?? 'LIBRO', style: TextStyle(color: kOrange, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                        ],
                      ),
                      Text(material['titulo'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF005581))),
                      Text("Autor: ${material['autor']}", style: TextStyle(fontSize: 16, color: Colors.grey[600], fontStyle: FontStyle.italic)),
                      
                      const Divider(height: 30),

                      // Chips de Información
                      Row(
                        children: [
                          _buildInfoDetail(Icons.category, "Materia", material['materia']),
                          const SizedBox(width: 30),
                          _buildInfoDetail(Icons.inventory, "Stock", "${material['stock']} unidades"),
                        ],
                      ),

                      const SizedBox(height: 25),
                      
                      // Calificación
                      const Text("CALIFICACIÓN", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                      Row(
                        children: [
                          Text("${material['calificacionPromedio'] ?? 0.0}", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 15),
                          Icon(Icons.star, color: Colors.amber, size: 24),
                          Text(" (${(material['totalVotos'] ?? 0)} votos totales)", style: const TextStyle(color: Colors.grey)),
                        ],
                      ),

                      const SizedBox(height: 35),

                      // BOTONES DE ACCIÓN (ADMIN)
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _abrirFormulario(ModoFormulario.editar, material);
                                },
                                icon: const Icon(Icons.edit, color: Colors.white),
                                label: const Text("EDITAR", style: TextStyle(color: Colors.black)),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _abrirFormulario(ModoFormulario.eliminar, material);
                                },
                                icon: const Icon(Icons.delete, color: Colors.white),
                                label: const Text("ELIMINAR", style: TextStyle(color: Colors.black)),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

// Widget auxiliar para los detalles
Widget _buildInfoDetail(IconData icon, String label, String value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(children: [Icon(icon, size: 14, color: Colors.grey), const SizedBox(width: 5), Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey))]),
      Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
    ],
  );
}
}

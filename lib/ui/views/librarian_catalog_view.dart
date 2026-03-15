import 'package:flutter/material.dart';
import 'package:biblioteca_unimet/services/servicio_material.dart';
import 'package:biblioteca_unimet/viewmodels/material_viewmodel.dart';
import 'package:biblioteca_unimet/services/servicio_biblioteca.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LibrarianCatalogView extends StatefulWidget {
  const LibrarianCatalogView({super.key});

  @override
  State<LibrarianCatalogView> createState() => _LibrarianCatalogViewState();
}

class _LibrarianCatalogViewState extends State<LibrarianCatalogView> {
  static const Color kOrange = Color(0xFFF7941D);
  final MaterialViewModel _viewModel = MaterialViewModel();
  final BibliotecaService _bibliotecaService = BibliotecaService();

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
      appBar: AppBar(
        title: const Text(
          "Catálogo en línea - Modo Consulta (Bibliotecario)",
          style: TextStyle(fontSize: 14, color: Colors.white),
        ),
        backgroundColor: kOrange,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
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
                InkWell(
                  onTap: () => _mostrarDetallesMaterialParaBibliotecario(
                    material,
                  ), // Nueva función
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

  void _mostrarDetallesMaterialParaBibliotecario(
    Map<String, dynamic> material,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        double screenWidth = MediaQuery.of(context).size.width;
        bool isDesktop = screenWidth > 700;

        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            width: isDesktop ? 600 : screenWidth,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: isDesktop
                  ? BorderRadius.circular(20)
                  : const BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: kOrange.withAlpha(25),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                material['tipo'] ?? 'LIBRO',
                                style: const TextStyle(
                                  color: kOrange,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                        Text(
                          material['titulo'],
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF005581),
                          ),
                        ),
                        Text(
                          "Autor: ${material['autor']}",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const Divider(height: 30),
                        Row(
                          children: [
                            _buildInfoDetail(
                              Icons.category,
                              "Materia",
                              material['materia'],
                            ),
                            const SizedBox(width: 30),
                            _buildInfoDetail(
                              Icons.inventory,
                              "Stock actual",
                              "${material['stock']} unidades",
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),
                        const Text(
                          "SOLICITUDES PENDIENTES",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: kOrange,
                          ),
                        ),
                        const SizedBox(height: 10),
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('prestamos')
                              .where('materialId', isEqualTo: material['id'])
                              .where('estado', isEqualTo: 'solicitado')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting)
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      "No hay solicitudes pendientes.",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                var prestamo = snapshot.data!.docs[index];
                                var data =
                                    prestamo.data() as Map<String, dynamic>;
                                return Card(
                                  elevation: 0,
                                  color: Colors.grey[50],
                                  margin: const EdgeInsets.only(bottom: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: BorderSide(color: Colors.grey[200]!),
                                  ),
                                  child: ListTile(
                                    leading: const CircleAvatar(
                                      backgroundColor: kOrange,
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    title: Text(
                                      data['correoSolicitante'] ??
                                          'Correo no disponible',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitle: Text(
                                      "Fecha: ${_formatearFecha(data['fechaSolicitud'])}",
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.check_circle,
                                            color: Colors.green,
                                            size: 28,
                                          ),
                                          onPressed: () => _bibliotecaService
                                              .aprobarPrestamo(prestamo.id),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.cancel,
                                            color: Colors.red,
                                            size: 28,
                                          ),
                                          onPressed: () => _bibliotecaService
                                              .rechazarPrestamo(
                                                prestamo.id,
                                                material['id'],
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 20),
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

  String _formatearFecha(dynamic fecha) {
    if (fecha == null) return "N/A";
    if (fecha is Timestamp) {
      DateTime dt = fecha.toDate();
      return "${dt.day}/${dt.month}/${dt.year}";
    }
    return fecha.toString();
  }

  Widget _buildInfoDetail(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

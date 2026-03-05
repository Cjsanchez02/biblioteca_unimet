import 'package:flutter/material.dart';
import 'package:biblioteca_unimet/services/servicio_material.dart';
import 'package:biblioteca_unimet/ui/views/admin_form_view.dart';
import 'package:biblioteca_unimet/viewmodels/material_viewmodel.dart';

class AdminCatalogView extends StatefulWidget {
  const AdminCatalogView({super.key});
  static const Color kOrange = Color(0xFFF7941D);
  @override
  State<AdminCatalogView> createState() => _AdminCatalogoViewState();
}

class _AdminCatalogoViewState extends State<AdminCatalogView> {
  // Instanciamos el ViewModel
  final MaterialViewModel _viewModel = MaterialViewModel();

  @override
  void initState() {
    super.initState();
    // Escuchamos cambios en el ViewModel para refrescar la UI al filtrar
    _viewModel.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  static const Color kOrange = Color(0xFFF7941D);
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Catálogo Admin"),
        backgroundColor: kOrange,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(
            110,
          ), // Más espacio para los dos controles
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Column(
              children: [
                Row(
                  children: [
                    // DROPBOX DE CRITERIO
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<String>(
                        value: _viewModel.criterio,
                        underline: const SizedBox(),
                        items: ["Título", "Autor", "Materia"].map((
                          String value,
                        ) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: const TextStyle(fontSize: 14),
                            ),
                          );
                        }).toList(),
                        onChanged: _viewModel.actualizarCriterio,
                      ),
                    ),
                    const SizedBox(width: 10),
                    // CAMPO DE BÚSQUEDA
                    Expanded(
                      child: TextField(
                        onChanged: _viewModel.actualizarFiltro,
                        decoration: InputDecoration(
                          hintText: "Buscar...",
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white,
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: servicioMaterial().obtenerMateriales(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final materiales = _viewModel.filtrarMateriales(snapshot.data!);

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200, // Ajusta el ancho máximo de cada tarjeta
              mainAxisExtent:
                  250, // ALTURA FIJA para evitar que crezcan demasiado
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: materiales.length,
            itemBuilder: (context, index) => _cardMaterial(materiales[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(ModoFormulario.agregar, null),
        backgroundColor: const Color(0xFFF7941D), // kOrange
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Añadir Material",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _cardMaterial(Map<String, dynamic> material) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Área visual superior (Color según tipo de material)
          Container(
            height: 80,
            width: double.infinity,
            color: kOrange.withOpacity(0.1),
            child: const Icon(
              Icons.collections_bookmark,
              color: kOrange,
              size: 40,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    material['titulo'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    material['autor'],
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  // Fila de acciones compacta
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Stock: ${material['stock']}",
                        style: const TextStyle(fontSize: 11),
                      ),
                      Row(
                        children: [
                          IconButton(
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                            icon: const Icon(
                              Icons.edit,
                              size: 18,
                              color: Colors.blue,
                            ),
                            onPressed: () => _abrirFormulario(
                              ModoFormulario.editar,
                              material,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                            icon: const Icon(
                              Icons.delete,
                              size: 18,
                              color: Colors.red,
                            ),
                            onPressed: () => _abrirFormulario(
                              ModoFormulario.eliminar,
                              material,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
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
}

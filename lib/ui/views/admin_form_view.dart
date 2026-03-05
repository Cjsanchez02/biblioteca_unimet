import 'package:biblioteca_unimet/viewmodels/material_viewmodel.dart';
import 'package:flutter/material.dart';

enum ModoFormulario { agregar, editar, eliminar }

class AdminMaterialForm extends StatefulWidget {
  final ModoFormulario modo;
  final Map<String, dynamic>? materialExistente; // Solo para editar/eliminar

  const AdminMaterialForm({
    super.key, 
    required this.modo, 
    this.materialExistente
  });

  @override
  State<AdminMaterialForm> createState() => _AdminMaterialFormState();
}

class _AdminMaterialFormState extends State<AdminMaterialForm> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores
  final _tituloCtrl = TextEditingController();
  final _autorCtrl = TextEditingController();
  final _materiaCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  String _tipoSeleccionado = 'Libro';

  @override
  void initState() {
    super.initState();
    // Si es editar o eliminar, precargamos los datos
    if (widget.materialExistente != null) {
      _tituloCtrl.text = widget.materialExistente!['titulo'] ?? '';
      _autorCtrl.text = widget.materialExistente!['autor'] ?? '';
      _materiaCtrl.text = widget.materialExistente!['materia'] ?? '';
      _stockCtrl.text = widget.materialExistente!['stock']?.toString() ?? '';
      _tipoSeleccionado = widget.materialExistente!['tipo'] ?? 'Libro';
    }
  }

  // VALIDACIONES SOLICITADAS
  String? _validarTexto(String? value) {
    if (value == null || value.isEmpty) return 'Campo obligatorio';
    if (RegExp(r'^[0-9]+$').hasMatch(value)) return 'No puede contener solo números';
    return null;
  }

  String? _validarStock(String? value) {
    if (value == null || value.isEmpty) return 'Campo obligatorio';
    if (int.tryParse(value) == null) return 'Debe ser un número entero';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    bool esEliminar = widget.modo == ModoFormulario.eliminar;

    return AlertDialog(
      title: Text('${widget.modo.name.toUpperCase()} MATERIAL'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // DROPDOWN PARA TIPO
              DropdownButtonFormField<String>(
                initialValue: _tipoSeleccionado,
                items: ['Libro', 'Guía', 'Revista', 'Tesis'].map((t) => 
                  DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: esEliminar ? null : (val) => setState(() => _tipoSeleccionado = val!),
                decoration: const InputDecoration(labelText: 'Tipo de Material'),
              ),
              const SizedBox(height: 10),
              _buildTextField(_tituloCtrl, 'Título', _validarTexto, esEliminar),
              _buildTextField(_autorCtrl, 'Autor', _validarTexto, esEliminar),
              _buildTextField(_materiaCtrl, 'Materia', _validarTexto, esEliminar),
              _buildTextField(_stockCtrl, 'Stock', _validarStock, esEliminar, keyboard: TextInputType.number),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: esEliminar ? Colors.red : const Color(0xFFF7941D)
          ),
          onPressed: _procesarAccion,
          child: Text(widget.modo == ModoFormulario.eliminar ? 'Confirmar Eliminar' : 'Guardar'),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label, String? Function(String?) validator, bool disabled, {TextInputType? keyboard}) {
    return TextFormField(
      controller: ctrl,
      decoration: InputDecoration(labelText: label),
      validator: validator,
      enabled: !disabled,
      keyboardType: keyboard,
    );
  }

  void _procesarAccion() async {
    if (widget.modo != ModoFormulario.eliminar && !_formKey.currentState!.validate()) return;

    final vm = MaterialViewModel();
    bool exito = false;

    if (widget.modo == ModoFormulario.eliminar) {
      await vm.borrarMaterial(widget.materialExistente!['id']);
      exito = true;
    } else {
      exito = await vm.guardarMaterial(
        id: widget.materialExistente?['id'],
        tipo: _tipoSeleccionado,
        titulo: _tituloCtrl.text,
        autor: _autorCtrl.text,
        materia: _materiaCtrl.text,
        stock: int.parse(_stockCtrl.text),
      );
    }

    if (exito && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Acción realizada con éxito")));
    }
  }
}
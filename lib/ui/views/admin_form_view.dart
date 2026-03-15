import 'package:biblioteca_unimet/viewmodels/material_viewmodel.dart';
import 'package:flutter/material.dart';
import 'dart:async';

enum ModoFormulario { agregar, editar, eliminar }

class AdminMaterialForm extends StatefulWidget {
  final ModoFormulario modo;
  final Map<String, dynamic>? materialExistente; // Solo para editar/eliminar

  const AdminMaterialForm({
    super.key,
    required this.modo,
    this.materialExistente,
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

  bool _cargando = false; // Para mostrar un indicador de carga
  String? _errorDuplicado; // Para mostrar error específico de título duplicado

  @override
  void initState() {
    super.initState();
    // Si se está eliminando o editando, se obtienen los datos
    if (widget.materialExistente != null) {
      _tituloCtrl.text = widget.materialExistente!['titulo'] ?? '';
      _autorCtrl.text = widget.materialExistente!['autor'] ?? '';
      _materiaCtrl.text = widget.materialExistente!['materia'] ?? '';
      _stockCtrl.text = widget.materialExistente!['stock']?.toString() ?? '';
      _tipoSeleccionado = widget.materialExistente!['tipo'] ?? 'Libro';
      final opcionesValidas = ['Libro', 'Guía', 'Revista', 'Tesis'];
      _tipoSeleccionado = opcionesValidas.contains(_tipoSeleccionado)
          ? _tipoSeleccionado
          : 'Libro';
    }
  }

  // VALIDACIONES
  String? _validarTexto(String? value) {
    if (value == null || value.isEmpty) return 'Campo obligatorio';
    if (RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'No puede contener sólo números';
    }
    if (RegExp(
      r'^[!@#\$%\^&\*\(\)_\+\-=\[\]\{\};:"\\|,.<>\/?]+$',
    ).hasMatch(value)) {
      return 'No puede contener sólo caracteres especiales';
    }
    return null;
  }

  String? _validarStock(String? value) {
    if (value == null || value.isEmpty) return 'Campo obligatorio';
    if (int.tryParse(value) == null) return 'Debe ser un número entero';
    if (int.parse(value) < 0) return 'No puede ser negativo';
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
                initialValue:
                    [
                      'Libro',
                      'Guía',
                      'Revista',
                      'Tesis',
                    ].contains(_tipoSeleccionado)
                    ? _tipoSeleccionado
                    : 'Libro',
                items: ['Libro', 'Guía', 'Revista', 'Tesis']
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: esEliminar
                    ? null
                    : (val) => setState(() => _tipoSeleccionado = val!),
                decoration: const InputDecoration(
                  labelText: 'Tipo de Material',
                ),
              ),
              const SizedBox(height: 10),
              _buildTextField(_tituloCtrl, 'Título', _validarTexto, esEliminar),
              if (_errorDuplicado !=
                  null) // Si hay error de título duplicado, se muestra debajo del campo
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    _errorDuplicado!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              _buildTextField(_autorCtrl, 'Autor', _validarTexto, esEliminar),
              _buildTextField(
                _materiaCtrl,
                'Materia',
                _validarTexto,
                esEliminar,
              ),
              _buildTextField(
                _stockCtrl,
                'Stock',
                _validarStock,
                esEliminar,
                keyboard: TextInputType.number,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar', style: TextStyle(color: Colors.black)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: esEliminar ? Colors.red : const Color(0xFFF7941D),
          ),
          onPressed: _cargando ? null : _procesarAccion,
          child: _cargando
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  widget.modo == ModoFormulario.eliminar
                      ? 'Confirmar Eliminar'
                      : 'Guardar',
                  style: const TextStyle(color: Colors.black),
                ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController ctrl,
    String label,
    String? Function(String?) validator,
    bool disabled, {
    TextInputType? keyboard,
  }) {
    return TextFormField(
      controller: ctrl,
      decoration: InputDecoration(labelText: label),
      validator: validator,
      enabled: !disabled,
      keyboardType: keyboard,
    );
  }

  void _procesarAccion() async {
    if (_cargando) return; // Evita múltiples clics
    if (widget.modo != ModoFormulario.eliminar &&
        !_formKey.currentState!.validate())
      return;

    setState(() => _cargando = true);
    final vm = MaterialViewModel();

    try {
      final String tituloNormalizado = _tituloCtrl.text.trim();
      if (widget.modo != ModoFormulario.eliminar) {
        bool esDuplicado = await vm.validarDuplicado(
          tituloNormalizado,
          id: widget.materialExistente?['id'],
        );

        if (esDuplicado && mounted) {
          setState(() {
            _errorDuplicado = "Este título ya existe"; // Guardamos el error
            _cargando =
                false; // Detenemos la carga para que el usuario pueda corregir
          });
          Timer(const Duration(seconds: 3), () {
            if (mounted) {
              setState(() {
                _errorDuplicado = null;
              });
            }
          });

          return;
        }
      }

      bool exito = false;

      if (widget.modo == ModoFormulario.eliminar) {
        await vm.borrarMaterial(widget.materialExistente!['id']);
        exito = true;
      } else {
        exito = await vm.guardarMaterial(
          id: widget.materialExistente?['id'],
          tipo: _tipoSeleccionado,
          titulo: _tituloCtrl.text.trim(),
          autor: _autorCtrl.text.trim(),
          materia: _materiaCtrl.text.trim(),
          stock: int.parse(_stockCtrl.text),
        );
      }

      if (exito && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Acción realizada con éxito")));
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }
}

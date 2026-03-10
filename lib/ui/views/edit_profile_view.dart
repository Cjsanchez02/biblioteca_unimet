import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import '../../models/UsuarioGeneral.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  static const Color kOrange = Color(0xFFF7941D);
  static const Color kDarkGray = Color(0xFF333333);

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _carreraController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUploadingImage = false;
  String? _profileImageUrl;
  String _rol = 'estudiante'; // Por defecto

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _carreraController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Obtiene la informacion del usuario desde Firebase Auth (correo y nombre base)
  /// y desde Cloud Firestore (datos adicionales como telefono, foto y carrera).
  Future<void> _loadUserData() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // 1. Buscamos datos en Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(currentUser.uid)
            .get();

        if (mounted) {
          setState(() {
            _emailController.text = currentUser.email ?? '';

            _nameController.text = currentUser.displayName ?? '';

            if (userDoc.exists) {
              Map<String, dynamic> data =
                  userDoc.data() as Map<String, dynamic>;
              // Firestore tiene prioridad para el nombre
              if (data['nombre'] != null) _nameController.text = data['nombre'];

              _phoneController.text = data['telefono'] ?? '';
              _carreraController.text = data['carrera'] ?? '';
              _profileImageUrl = data['fotoUrl'];
              _rol = data['rol'] ?? 'estudiante';
            }

            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al cargar datos: $e')));
      }
    }
  }

  /// Permite al usuario seleccionar una imagen de su galeria, subirla a Firebase Storage
  /// y actualizar el enlace de la foto en su documento de Firestore.
  /// NO FUNCIONA TODAVIA
  /// TODO: IMPLEMENTAR
  /* 
  Future<void> _changeProfilePicture() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    setState(() => _isUploadingImage = true);

    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        File file = File(image.path);

        Reference ref = FirebaseStorage.instance
            .ref()
            .child('perfil_fotos')
            .child('${currentUser.uid}.jpg');

        await ref.putFile(file);
        String downloadUrl = await ref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(currentUser.uid)
            .set({'fotoUrl': downloadUrl}, SetOptions(merge: true));

        if (mounted) {
          setState(() {
            _profileImageUrl = downloadUrl;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Foto actualizada exitosamente')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al subir foto: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingImage = false);
      }
    }
  }
  */

  /// Recopila los datos de los campos de texto y los guarda en Firestore.
  /// Tambien actualiza el 'displayName' en Firebase Auth y la contrasena si se
  /// ingreso una nueva.
  Future<void> _saveUserData() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El nombre no puede estar vacío'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isSaving = false);
      return;
    }

    setState(() => _isSaving = true);

    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(currentUser.uid)
            .set({
              'nombre': _nameController.text.trim(),
              'telefono': _phoneController.text.trim(),
              'carrera': _carreraController.text.trim(),
            }, SetOptions(merge: true));

        //  cambio de nombre lo actualizamos en su perfil de Auth
        if (_nameController.text.trim() != currentUser.displayName) {
          await currentUser.updateDisplayName(_nameController.text.trim());
        }

        // NUEVA LOGICA: CAMBIAR CONTRASENA
        if (_passwordController.text.trim().isNotEmpty) {
          if (!UsuarioGeneral.validarRegistro(
            _passwordController.text.trim(),
          )) {
            throw Exception(UsuarioGeneral.mensajeErrorRegistro);
          }
          await currentUser.updatePassword(_passwordController.text.trim());
          _passwordController.clear();
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Perfil actualizado correctamente')),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String mensaje = 'Error al guardar cambios';
        if (e.code == 'requires-recent-login') {
          mensaje =
              'Por seguridad, debes reingresar a la app para cambiar la contraseña';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        backgroundColor: kOrange,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kOrange))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: const Color(0xFFF4F4F4),
                          backgroundImage: _profileImageUrl != null
                              ? NetworkImage(_profileImageUrl!)
                              : null,
                          child: _profileImageUrl == null
                              ? const Icon(
                                  Icons.person,
                                  size: 80,
                                  color: kDarkGray,
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: null, // Desactivado por ahora
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: kOrange,
                              child: _isUploadingImage
                                  ? const SizedBox(
                                      width: 15,
                                      height: 15,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.camera_alt,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildTextField(
                    "Nombre Completo",
                    _nameController,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))],
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    "Correo Institucional",
                    _emailController,
                    enabled: false,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    "Telefono",
                    _phoneController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 20),
                  if (_rol == 'estudiante') ...[
                    _buildTextField("Carrera", _carreraController),
                    const SizedBox(height: 20),
                  ],
                  _buildTextField(
                    "Nueva Contraseña",
                    _passwordController,
                    isPassword: true,
                    hint: "Déjalo vacío para no cambiarla",
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kOrange,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _isSaving ? null : _saveUserData,
                      child: _isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Guardar Cambios',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  /// Para crear los cuadros de texto
  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool enabled = true,
    bool isPassword = false,
    String? hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: kDarkGray,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          obscureText: isPassword,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF4F4F4),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

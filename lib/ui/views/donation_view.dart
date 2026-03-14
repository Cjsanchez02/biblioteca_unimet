import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DonationView extends StatefulWidget {
  const DonationView({super.key});

  @override
  State<DonationView> createState() => _DonationViewState();
}

class _DonationViewState extends State<DonationView> {
  bool _isProcessing = false;

  // Variables para el monto y moneda
  final TextEditingController _montoController = TextEditingController();
  double _monto = 0.0;
  String _monedaSeleccionada = 'USD';
  final List<String> _monedas = ['USD', 'EUR', 'VES'];

  @override
  void initState() {
    super.initState();
    _montoController.addListener(() {
      final String text = _montoController.text;
      if (text.isEmpty) {
        setState(() => _monto = 0.0);
        return;
      }
      String textoProcesado = text.replaceAll(',', '.');
      // Intentamos validar el número. 
      // Si contiene letras o más de un punto, tryParse devolverá null.
      final double? valorValidado = double.tryParse(textoProcesado);

      if (valorValidado == null) {
        // ERROR: El texto contiene caracteres no numéricos.
        // Eliminamos el último carácter introducido.
        final String filtrado = text.substring(0, text.length - 1);
        
        // evitar errores de renderizado
        Future.microtask(() {
          _montoController.value = TextEditingValue(
            text: filtrado,
            selection: TextSelection.collapsed(offset: filtrado.length),
          );
        });
      } else {
        // ÉXITO: Es un número válido. Actualizamos el estado para el botón.
        setState(() {
          _monto = valorValidado;
        });
      }
    });
  }

  @override
  void dispose() {
    _montoController.dispose();
    super.dispose();
  }

  void _processPayment() async {
    // Validacion basica antes de procesar
    if (_monto <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa un monto mayor a 0')),
      );
      return;
    }

    setState(() => _isProcessing = true);
    
    // Simular el tiempo de conexion con el banco
    await Future.delayed(const Duration(seconds: 3));

    // Guardar en Firebase
    try {
      final currentUsuario = FirebaseAuth.instance.currentUser;
      if (currentUsuario != null) {
        final Map<String, dynamic> nuevaDonacion = {
            'monto': _monto,
            'moneda': _monedaSeleccionada,
            'fecha': DateTime.now().toIso8601String(),
        };

        await FirebaseFirestore.instance.collection('usuarios')
          .doc(currentUsuario.uid)
          .set({
            'historialDonaciones': FieldValue.arrayUnion([nuevaDonacion])
          }, SetOptions(merge: true));
      }
    } catch(e) {
      // Si falla firebase solo mostramos un error pero en la vida real aqui abortariamos
      debugPrint("Error al guardar donación: $e");
    }

    if (!mounted) return;
    setState(() => _isProcessing = false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.check_circle,
          color: Color(0xFF0070BA),
          size: 60,
        ),
        title: const Text('Confirmación de Envío'),
        content: Text(
          'Has donado exitosamente $_monto $_monedaSeleccionada a la Biblioteca Unimet.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Volver al la Biblioteca Unimet'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Image(
          image: AssetImage('images/logopaypal.png'),
          height: 60,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: _isProcessing ? _buildProcessingState() : _buildPayPalFlow(),
          ),
          _buildWarningBanner(),
        ],
      ),
    );
  }

  Widget _buildPayPalFlow() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Color(0xFFEDF2F7),
            child: Icon(
              Icons.account_balance,
              color: Color(0xFF003087),
              size: 30,
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            'Donar a Biblioteca Unimet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),

          // SECCIÓN DE MONTO Y MONEDA
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.black12),
            ),
            child: Column(
              children: [
                const Text(
                  'Monto de la donación',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Input de Monto
                    SizedBox(
                      width: 120,
                      child: TextField(
                        controller:
                            _montoController, // El controlador ahora hace todo el trabajo
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '0.00',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Selector de Moneda
                    DropdownButton<String>(
                      value: _monedaSeleccionada,
                      underline: Container(),
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      items: _monedas.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _monedaSeleccionada = newValue!;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // MÉTODO DE PAGO SIMULADO (ESTILO PAYPAL)
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Pagar con',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.credit_card, color: Colors.blue),
                SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Visa •••• 4242',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Tarjeta de crédito principal',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                Spacer(),
                Icon(Icons.keyboard_arrow_right, color: Colors.grey),
              ],
            ),
          ),

          const SizedBox(height: 40),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _processPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0070BA),
                shape: const StadiumBorder(),
              ),
              child: Text(
                'Donar $_monto $_monedaSeleccionada',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            'Transacción protegida por PayPal',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // Los métodos _buildProcessingState y _buildWarningBanner se mantienen igual...
  Widget _buildProcessingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF0070BA)),
          SizedBox(height: 20),
          Text(
            'Conectando con PayPal...',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningBanner() {
    return Container(
      width: double.infinity,
      color: Colors.amber[900],
      padding: const EdgeInsets.all(12),
      child: const Text(
        'ESTA ES UNA SIMULACIÓN. Ningún cargo será realizado.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

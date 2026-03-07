import 'package:flutter/material.dart';
import '../../services/servicio_donaciones.dart';

class DonationView extends StatefulWidget {
  const DonationView({super.key});

  @override
  State<DonationView> createState() => _DonationViewState();
}

class _DonationViewState extends State<DonationView> {
  bool _isProcessing = false;
  final ServicioDonaciones _servicioDonaciones = ServicioDonaciones();

  // Variables para el monto y moneda
  double _monto = 0.0;
  String _monedaSeleccionada = 'USD';
  final List<String> _monedas = ['USD', 'EUR', 'VES'];

  void _processPayment() async {
    setState(() => _isProcessing = true);

    try {
      await _servicioDonaciones.guardarDonacion(_monto, _monedaSeleccionada);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
      setState(() => _isProcessing = false);
      return;
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
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '0.00',
                        ),
                        onChanged: (val) {
                          setState(() {
                            _monto = double.tryParse(val) ?? 0.0;
                          });
                        },
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

          // METODO DE PAGO SIMULADO (ESTILO PAYPAL)
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

  // Construye la pantalla de carga que se muestra mientras se procesa la donacion
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

  // Construye el banner de advertencia que indica que la transaccion es una simulacion
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:biblioteca_unimet/viewmodels/estadisticas_viewmodel.dart'; // Ajusta tu ruta
import '../widgets/admin_navbar.dart';
import '../widgets/custom_navbars.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EstadisticasView extends StatelessWidget {
  const EstadisticasView({super.key});

  static const Color kOrange = Color(0xFFF7941D);
  static const Color kDarkGray = Color(0xFF333333);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EstadisticasViewModel(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            _buildRoleNavbar(),
            const Divider(height: 1),
            Expanded(
              child: Consumer<EstadisticasViewModel>(
                builder: (context, vm, child) {
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Seleccione la métrica a visualizar:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: kDarkGray,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<ModoEstadistica>(
                              value: vm.modoActual,
                              isExpanded: true,
                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                                color: kOrange,
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: ModoEstadistica.solicitudesCarrera,
                                  child: Text(
                                    '📊 Porcentaje de Solicitudes por Carrera',
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: ModoEstadistica.solicitudesMateria,
                                  child: Text(
                                    '📊 Porcentaje de Solicitudes por Materia',
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: ModoEstadistica.calificacionMateria,
                                  child: Text(
                                    '⭐ Mejores Calificados por Materia (Top 5)',
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: ModoEstadistica.calificacionMaterial,
                                  child: Text(
                                    '⭐ Mejores Libros Calificados (Top 5)',
                                  ),
                                ),
                              ],
                              onChanged: (ModoEstadistica? nuevoModo) {
                                if (nuevoModo != null)
                                  vm.cambiarModo(nuevoModo);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),

                        // 2. EL ÁREA DEL GRÁFICO
                        Expanded(
                          child: vm.isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: kOrange,
                                  ),
                                )
                              : vm.datosProcesados.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No hay datos suficientes para mostrar.',
                                  ),
                                )
                              : _construirGraficoYLeyenda(vm),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Decide qué gráfico mostrar según el modo
  Widget _construirGraficoYLeyenda(EstadisticasViewModel vm) {
    // Si es "solicitudesCarrera" o "solicitudesMateria", es un gráfico de torta (%)
    bool esModoSolicitudes =
        vm.modoActual == ModoEstadistica.solicitudesCarrera ||
        vm.modoActual == ModoEstadistica.solicitudesMateria;

    // Paleta de colores para los gráficos
    List<Color> colores = [
      kOrange,
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.red,
      Colors.grey,
    ];

    return Column(
      children: [
        // El Gráfico (Ocupa la mitad del espacio disponible)
        Expanded(
          flex: 3,
          child: esModoSolicitudes
              ? _construirPieChart(vm.datosProcesados, colores)
              : _construirBarChart(vm.datosProcesados, kOrange),
        ),
        const SizedBox(height: 40),

        // La Leyenda / Dashboard Resumen (Ocupa el resto)
        Expanded(
          flex: 2,
          child: _construirLeyenda(
            vm.datosProcesados,
            colores,
            esModoSolicitudes,
          ),
        ),
      ],
    );
  }

  // Gráfico Circular para Porcentajes (%)
  Widget _construirPieChart(Map<String, double> datos, List<Color> colores) {
    int index = 0;
    List<PieChartSectionData> secciones = datos.entries.map((entry) {
      final color = colores[index % colores.length];
      index++;
      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${entry.value}%',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return PieChart(PieChartData(sections: secciones, centerSpaceRadius: 40));
  }

  // Gráfico de Barras para Calificaciones (0 a 5 estrellas)
  Widget _construirBarChart(Map<String, double> datos, Color colorBarra) {
    int index = 0;
    List<BarChartGroupData> gruposBarras = datos.entries.map((entry) {
      final x = index++;
      return BarChartGroupData(
        x: x,
        barRods: [
          BarChartRodData(
            toY: entry.value,
            color: colorBarra,
            width: 30,
            borderRadius: BorderRadius.circular(4),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: 5,
              color: Colors.grey[200],
            ),
          ),
        ],
      );
    }).toList();

    return BarChart(
      BarChartData(
        maxY: 5, // Máximo 5 estrellas
        barGroups: gruposBarras,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value.toInt() >= datos.length) return const Text('');
                String nombre = datos.keys.elementAt(value.toInt());
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    nombre.length > 10
                        ? '${nombre.substring(0, 8)}...'
                        : nombre,
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  // Leyenda detallada tipo lista
  Widget _construirLeyenda(
    Map<String, double> datos,
    List<Color> colores,
    bool esPorcentaje,
  ) {
    return ListView.builder(
      itemCount: datos.length,
      itemBuilder: (context, index) {
        String clave = datos.keys.elementAt(index);
        double valor = datos.values.elementAt(index);
        Color color = esPorcentaje ? colores[index % colores.length] : kOrange;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  clave,
                  style: const TextStyle(
                    fontSize: 16,
                    color: kDarkGray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                esPorcentaje ? '$valor%' : '$valor ⭐',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRoleNavbar() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox(height: 80);
        final data = snapshot.data!.data() as Map<String, dynamic>?;
        final role = data?['rol'] ?? 'Usuario Normal';

        if (role == 'Administrador') {
          return const AdminNavbar(activeTab: AdminTab.estadisticas);
        } else {
          return const LibrarianNavbar(activeTab: LibrarianTab.estadisticas);
        }
      },
    );
  }
}

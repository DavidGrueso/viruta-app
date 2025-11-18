import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/viruta_card.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // ---- TARJETAS SUPERIORES ----
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: const [
            SizedBox(
              width: 180,
              child: VirutaStatCard(
                title: "Temp",
                value: "215°C",
                icon: Icons.thermostat,
              ),
            ),
            SizedBox(
              width: 180,
              child: VirutaStatCard(
                title: "Uso",
                value: "87 min",
                icon: Icons.timer,
              ),
            ),
            SizedBox(
              width: 180,
              child: VirutaStatCard(
                title: "Conexión",
                value: "OK",
                icon: Icons.wifi,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // ---- GRÁFICO PRINCIPAL ----
        Container(
          decoration: BoxDecoration(
            color: const Color(0xff1e293b),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Temperatura en el tiempo",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    backgroundColor: Colors.transparent,
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        isCurved: true,
                        color: Colors.tealAccent,
                        barWidth: 3,
                        dotData: FlDotData(show: false),
                        spots: const [
                          FlSpot(0, 210),
                          FlSpot(1, 220),
                          FlSpot(2, 240),
                          FlSpot(3, 230),
                          FlSpot(4, 245),
                          FlSpot(5, 238),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // ---- TARJETAS DE ABAJO ----
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: const [
            SizedBox(
              width: 180,
              child: VirutaStatCard(
                title: "RPM",
                value: "60",
                icon: Icons.speed,
                tall: true,
              ),
            ),
            SizedBox(
              width: 180,
              child: VirutaStatCard(
                title: "Filamento",
                value: "OK",
                icon: Icons.stacked_line_chart,
                tall: true,
              ),
            ),
            SizedBox(
              width: 180,
              child: VirutaStatCard(
                title: "Presión",
                value: "Normal",
                icon: Icons.compress,
                tall: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

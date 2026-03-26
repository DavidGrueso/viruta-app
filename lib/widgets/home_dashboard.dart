import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../machine_state.dart';
import 'viruta_card.dart';

class HomeDashboard extends StatelessWidget {
  final MachineState machineState;
  final String endpoint;
  final String socketStatus;
  final String statusMessage;
  final List<FlSpot> temperatureHistory;
  final VoidCallback onReconnect;
  final VoidCallback onRequestStatus;

  const HomeDashboard({
    super.key,
    required this.machineState,
    required this.endpoint,
    required this.socketStatus,
    required this.statusMessage,
    required this.temperatureHistory,
    required this.onReconnect,
    required this.onRequestStatus,
  });

  @override
  Widget build(BuildContext context) {
    final chartSpots = temperatureHistory.isEmpty
        ? const <FlSpot>[FlSpot(0, 0)]
        : temperatureHistory;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xffe2f4ea),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ESP32: $endpoint',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text('Estado del socket: $socketStatus'),
              const SizedBox(height: 4),
              Text(statusMessage),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            SizedBox(
              width: 180,
              child: VirutaStatCard(
                title: 'Temperatura',
                value: '${machineState.currentTemp.toStringAsFixed(1)} C',
                icon: Icons.thermostat,
              ),
            ),
            SizedBox(
              width: 180,
              child: VirutaStatCard(
                title: 'Uso',
                value: '${machineState.usageMin} min',
                icon: Icons.timer,
              ),
            ),
            SizedBox(
              width: 180,
              child: VirutaStatCard(
                title: 'Conexion',
                value: machineState.machineConnected ? 'OK' : 'OFF',
                icon: Icons.wifi,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
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
                'Temperatura en el tiempo',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    backgroundColor: Colors.transparent,
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        isCurved: true,
                        color: Colors.tealAccent,
                        barWidth: 3,
                        dotData: const FlDotData(show: false),
                        spots: chartSpots,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            SizedBox(
              width: 180,
              child: VirutaStatCard(
                title: 'RPM',
                value: machineState.rpm.toStringAsFixed(0),
                icon: Icons.speed,
                tall: true,
              ),
            ),
            SizedBox(
              width: 180,
              child: VirutaStatCard(
                title: 'Filamento',
                value: machineState.filamentStatus,
                icon: Icons.stacked_line_chart,
                tall: true,
              ),
            ),
            SizedBox(
              width: 180,
              child: VirutaStatCard(
                title: 'Presion',
                value: machineState.pressure.toStringAsFixed(2),
                icon: Icons.compress,
                tall: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            OutlinedButton.icon(
              onPressed: onRequestStatus,
              icon: const Icon(Icons.sync),
              label: const Text('Actualizar datos'),
            ),
            OutlinedButton.icon(
              onPressed: onReconnect,
              icon: const Icon(Icons.wifi_find),
              label: const Text('Reconectar'),
            ),
          ],
        ),
      ],
    );
  }
}

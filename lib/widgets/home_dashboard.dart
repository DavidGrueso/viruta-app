import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../machine_state.dart';
import 'viruta_card.dart';

class HomeDashboard extends StatelessWidget {
  final MachineState machineState;
  final String endpoint;
  final String socketStatus;
  final String statusMessage;
  final bool isConnected;
  final bool isConnecting;
  final List<FlSpot> temperatureHistory;
  final VoidCallback onReconnect;
  final VoidCallback onRequestStatus;
  final VoidCallback onPowerOn;
  final VoidCallback onPowerOff;
  final VoidCallback onIncreaseTargetTemp;
  final VoidCallback onDecreaseTargetTemp;

  const HomeDashboard({
    super.key,
    required this.machineState,
    required this.endpoint,
    required this.socketStatus,
    required this.statusMessage,
    required this.isConnected,
    required this.isConnecting,
    required this.temperatureHistory,
    required this.onReconnect,
    required this.onRequestStatus,
    required this.onPowerOn,
    required this.onPowerOff,
    required this.onIncreaseTargetTemp,
    required this.onDecreaseTargetTemp,
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
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xfff5f7fb),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Control de maquina',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Text(
                'Calentador: ${machineState.heaterOn ? 'Encendido' : 'Apagado'}',
              ),
              const SizedBox(height: 8),
              Text(
                'Temperatura objetivo: '
                '${machineState.targetTemp.toStringAsFixed(1)} C',
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ElevatedButton.icon(
                    onPressed: isConnecting ? null : onPowerOn,
                    icon: const Icon(Icons.power_settings_new),
                    label: const Text('Encender'),
                  ),
                  ElevatedButton.icon(
                    onPressed: isConnecting ? null : onPowerOff,
                    icon: const Icon(Icons.power_off),
                    label: const Text('Apagar'),
                  ),
                  ElevatedButton.icon(
                    onPressed: isConnecting ? null : onDecreaseTargetTemp,
                    icon: const Icon(Icons.remove),
                    label: const Text('Temp -5'),
                  ),
                  ElevatedButton.icon(
                    onPressed: isConnecting ? null : onIncreaseTargetTemp,
                    icon: const Icon(Icons.add),
                    label: const Text('Temp +5'),
                  ),
                  OutlinedButton.icon(
                    onPressed: onRequestStatus,
                    icon: const Icon(Icons.sync),
                    label: const Text('Solicitar estado'),
                  ),
                  OutlinedButton.icon(
                    onPressed: onReconnect,
                    icon: const Icon(Icons.wifi_find),
                    label: Text(isConnected ? 'Reconectar' : 'Conectar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

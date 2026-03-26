import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../machine_state.dart';
import '../services/esp32_service.dart';
import '../widgets/home_dashboard.dart';
import 'auth.dart';
import 'settings.dart';

class HomePage extends StatefulWidget {
  final String username;
  final Future<void> Function() toggleTheme;
  final bool isDarkMode;
  final String initialEndpoint;
  final Future<void> Function(String endpoint) onEndpointChanged;

  const HomePage({
    super.key,
    required this.username,
    required this.toggleTheme,
    required this.isDarkMode,
    required this.initialEndpoint,
    required this.onEndpointChanged,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Esp32Service _esp32Service = Esp32Service();
  final List<FlSpot> _temperatureHistory = <FlSpot>[];

  StreamSubscription<MachineState>? _telemetrySubscription;
  StreamSubscription<SocketSnapshot>? _connectionSubscription;

  MachineState _machineState = MachineState.initial();
  late String _endpoint;
  SocketStatus _socketStatus = SocketStatus.disconnected;
  String _statusMessage = 'Sin conexion';
  int _sampleIndex = 0;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _endpoint = widget.initialEndpoint;
    _telemetrySubscription = _esp32Service.telemetryStream.listen(
      _handleTelemetry,
    );
    _connectionSubscription = _esp32Service.connectionStream.listen(
      _handleConnection,
    );
    unawaited(_connectToEsp32());
  }

  @override
  void dispose() {
    _telemetrySubscription?.cancel();
    _connectionSubscription?.cancel();
    _esp32Service.dispose();
    super.dispose();
  }

  Future<void> _connectToEsp32() async {
    await _esp32Service.connect(_endpoint);
  }

  void _handleTelemetry(MachineState data) {
    final nextHistory = List<FlSpot>.from(_temperatureHistory)
      ..add(FlSpot(_sampleIndex.toDouble(), data.currentTemp));

    if (nextHistory.length > 20) {
      nextHistory.removeAt(0);
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _machineState = data;
      _temperatureHistory
        ..clear()
        ..addAll(nextHistory);
      _sampleIndex += 1;
    });
  }

  void _handleConnection(SocketSnapshot snapshot) {
    if (!mounted) {
      return;
    }

    setState(() {
      _socketStatus = snapshot.status;
      _statusMessage = snapshot.message ?? _labelForStatus(snapshot.status);
    });
  }

  String _labelForStatus(SocketStatus status) {
    switch (status) {
      case SocketStatus.connecting:
        return 'Conectando';
      case SocketStatus.connected:
        return 'Conectado';
      case SocketStatus.error:
        return 'Error de conexion';
      case SocketStatus.disconnected:
        return 'Desconectado';
    }
  }

  Future<void> _saveEndpoint(String endpoint) async {
    final normalized = endpoint.trim();
    if (normalized.isEmpty) {
      return;
    }

    setState(() {
      _endpoint = normalized;
      _temperatureHistory.clear();
      _sampleIndex = 0;
    });

    await widget.onEndpointChanged(normalized);
    await _connectToEsp32();
  }

  void _sendPowerCommand(bool enabled) {
    _esp32Service.sendCommand(enabled ? 'power_on' : 'power_off');
    setState(() {
      _machineState = _machineState.copyWith(
        heaterOn: enabled,
        machineConnected: true,
      );
    });
  }

  void _changeTargetTemperature(double delta) {
    final nextTarget = (_machineState.targetTemp + delta)
        .clamp(0, 400)
        .toDouble();
    _esp32Service.sendCommand('set_temp', value: nextTarget);
    setState(() {
      _machineState = _machineState.copyWith(targetTemp: nextTarget);
    });
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => AuthPage(
          toggleTheme: widget.toggleTheme,
          isDarkMode: widget.isDarkMode,
          endpoint: _endpoint,
          onEndpointChanged: widget.onEndpointChanged,
        ),
      ),
    );
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SettingsPage(
          currentEndpoint: _endpoint,
          onSaveEndpoint: _saveEndpoint,
          toggleTheme: widget.toggleTheme,
          isDarkMode: widget.isDarkMode,
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentTabIndex) {
      case 0:
        return HomeDashboard(
          machineState: _machineState,
          endpoint: _endpoint,
          socketStatus: _labelForStatus(_socketStatus),
          statusMessage: _statusMessage,
          temperatureHistory: _temperatureHistory,
          onReconnect: _connectToEsp32,
          onRequestStatus: _esp32Service.requestSnapshot,
        );
      case 1:
        return _buildConnectionTab();
      case 2:
        return _buildUserTab();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildConnectionTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xffebf5ef),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Conexion con ESP32',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              Text('Endpoint: $_endpoint'),
              const SizedBox(height: 6),
              Text('Socket: ${_labelForStatus(_socketStatus)}'),
              const SizedBox(height: 6),
              Text(_statusMessage),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ElevatedButton.icon(
                    onPressed: _connectToEsp32,
                    icon: const Icon(Icons.wifi),
                    label: const Text('Conectar'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _esp32Service.requestSnapshot,
                    icon: const Icon(Icons.sync),
                    label: const Text('Solicitar estado'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _openSettings,
                    icon: const Icon(Icons.settings_ethernet),
                    label: const Text('Cambiar endpoint'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xfff5f7fb),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Panel de comandos',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              Text(
                'Temperatura objetivo actual: '
                '${_machineState.targetTemp.toStringAsFixed(1)} C',
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _sendPowerCommand(true),
                    icon: const Icon(Icons.power_settings_new),
                    label: const Text('Encender'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _sendPowerCommand(false),
                    icon: const Icon(Icons.power_off),
                    label: const Text('Apagar'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _changeTargetTemperature(-5),
                    icon: const Icon(Icons.remove),
                    label: const Text('Bajar 5 C'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _changeTargetTemperature(5),
                    icon: const Icon(Icons.add),
                    label: const Text('Subir 5 C'),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _InfoPill(
                      title: 'Calentador',
                      value: _machineState.heaterOn ? 'Encendido' : 'Apagado',
                      icon: Icons.local_fire_department,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InfoPill(
                      title: 'Estado maquina',
                      value: _machineState.machineConnected ? 'Activa' : 'OFF',
                      icon: Icons.memory,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xff2f653d), Color(0xff5ca35e)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(26),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white.withValues(alpha: 0.18),
                child: const Icon(Icons.person, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 18),
              Text(
                widget.username,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Perfil principal de la aplicacion VIRUTA',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            const Expanded(
              child: _ProfileCard(
                title: 'Maquina',
                value: 'Extrusora VIRUTA-01',
                icon: Icons.precision_manufacturing,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ProfileCard(
                title: 'Endpoint',
                value: _endpoint,
                icon: Icons.router,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _ProfileCard(
          title: 'Ultimos datos',
          value:
              'Temp ${_machineState.currentTemp.toStringAsFixed(1)} C, '
              'RPM ${_machineState.rpm.toStringAsFixed(0)}, '
              'presion ${_machineState.pressure.toStringAsFixed(2)}.',
          icon: Icons.analytics,
          fullWidth: true,
        ),
        const SizedBox(height: 20),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.settings),
          title: const Text('Ajustes'),
          subtitle: const Text('Tema, endpoint y preferencias'),
          trailing: const Icon(Icons.chevron_right),
          onTap: _openSettings,
        ),
        const Divider(),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.logout),
          title: const Text('Cerrar sesion'),
          subtitle: const Text('Volver al acceso de la app'),
          trailing: const Icon(Icons.chevron_right),
          onTap: _logout,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentTabIndex == 0
              ? 'Graficas y datos'
              : _currentTabIndex == 1
              ? 'Conexion y control'
              : 'Usuario',
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(padding: const EdgeInsets.all(20), child: _buildBody()),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentTabIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentTabIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.show_chart), label: 'Datos'),
          NavigationDestination(icon: Icon(Icons.memory), label: 'ESP32'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Usuario'),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _InfoPill({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xff2f653d)),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(color: Colors.grey[700])),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final bool fullWidth;

  const _ProfileCard({
    required this.title,
    required this.value,
    required this.icon,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xfff5f7fb),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xff2f653d)),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

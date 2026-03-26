import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../machine_state.dart';
import '../services/esp32_service.dart';
import '../widgets/home_dashboard.dart';
import 'auth.dart';
import 'profile.dart';
import 'settings.dart';

class HomePage extends StatefulWidget {
  final Future<void> Function() toggleTheme;
  final bool isDarkMode;
  final String initialEndpoint;
  final Future<void> Function(String endpoint) onEndpointChanged;

  const HomePage({
    super.key,
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
    final nextTarget =
        (_machineState.targetTemp + delta).clamp(0, 400).toDouble();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VIRUTA'),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.6 < 360
            ? MediaQuery.of(context).size.width * 0.6
            : 360,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 47, 101, 61),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Menu',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Perfil'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfilePage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Ajustes'),
                onTap: () {
                  Navigator.pop(context);
                  _openSettings();
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Cerrar sesion'),
                onTap: () {
                  Navigator.pop(context);
                  _logout();
                },
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'v1.0',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: HomeDashboard(
            machineState: _machineState,
            endpoint: _endpoint,
            socketStatus: _labelForStatus(_socketStatus),
            statusMessage: _statusMessage,
            isConnected: _socketStatus == SocketStatus.connected,
            isConnecting: _socketStatus == SocketStatus.connecting,
            temperatureHistory: _temperatureHistory,
            onReconnect: _connectToEsp32,
            onRequestStatus: _esp32Service.requestSnapshot,
            onPowerOn: () => _sendPowerCommand(true),
            onPowerOff: () => _sendPowerCommand(false),
            onIncreaseTargetTemp: () => _changeTargetTemperature(5),
            onDecreaseTargetTemp: () => _changeTargetTemperature(-5),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  final Future<void> Function() toggleTheme;
  final bool isDarkMode;
  final String currentEndpoint;
  final Future<void> Function(String endpoint) onSaveEndpoint;

  const SettingsPage({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
    required this.currentEndpoint,
    required this.onSaveEndpoint,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final TextEditingController _endpointController;
  late bool _isDarkMode;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _endpointController = TextEditingController(text: widget.currentEndpoint);
    _isDarkMode = widget.isDarkMode;
  }

  @override
  void dispose() {
    _endpointController.dispose();
    super.dispose();
  }

  Future<void> _saveEndpoint() async {
    setState(() {
      _saving = true;
    });

    await widget.onSaveEndpoint(_endpointController.text);

    if (!mounted) {
      return;
    }

    setState(() {
      _saving = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Endpoint guardado')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Conexion a ESP32',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _endpointController,
              decoration: const InputDecoration(
                labelText: 'Endpoint WebSocket',
                hintText: 'ws://192.168.1.50:81',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _saveEndpoint,
                child: Text(_saving ? 'Guardando...' : 'Guardar endpoint'),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Apariencia',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Modo oscuro'),
              value: _isDarkMode,
              onChanged: (_) async {
                await widget.toggleTheme();
                if (!mounted) {
                  return;
                }
                setState(() {
                  _isDarkMode = !_isDarkMode;
                });
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Notas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'La app espera un servidor WebSocket en la ESP32 y mensajes JSON '
              'para telemetria y comandos.',
            ),
          ],
        ),
      ),
    );
  }
}

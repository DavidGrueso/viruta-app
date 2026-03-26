import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pages/auth.dart';

void main() {
  runApp(const VirutaApp());
}

class VirutaApp extends StatefulWidget {
  const VirutaApp({super.key});

  @override
  State<VirutaApp> createState() => _VirutaAppState();
}

class _VirutaAppState extends State<VirutaApp> {
  bool isDarkMode = false;
  String endpoint = 'ws://192.168.1.50:81';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final preferences = await SharedPreferences.getInstance();
    if (!mounted) {
      return;
    }

    setState(() {
      isDarkMode = preferences.getBool('is_dark_mode') ?? false;
      endpoint = preferences.getString('esp32_endpoint') ?? endpoint;
    });
  }

  Future<void> _toggleTheme() async {
    final nextValue = !isDarkMode;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool('is_dark_mode', nextValue);

    if (!mounted) {
      return;
    }

    setState(() {
      isDarkMode = nextValue;
    });
  }

  Future<void> _updateEndpoint(String nextEndpoint) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('esp32_endpoint', nextEndpoint);

    if (!mounted) {
      return;
    }

    setState(() {
      endpoint = nextEndpoint;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VIRUTA',
      debugShowCheckedModeBanner: false,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.teal,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.teal,
      ),
      home: AuthPage(
        toggleTheme: _toggleTheme,
        isDarkMode: isDarkMode,
        endpoint: endpoint,
        onEndpointChanged: _updateEndpoint,
      ),
    );
  }
}

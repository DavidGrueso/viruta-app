import 'package:flutter/material.dart';
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
      //home: AuthPage(toggleTheme: () {
      //  setState(() => isDarkMode = !isDarkMode);
      //}),
      home: const AuthPage(),
    );
  }
}

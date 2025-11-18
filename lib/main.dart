import 'package:flutter/material.dart';
import 'pages/home.dart';

void main() {
  runApp(const VirutaApp());
}

class VirutaApp extends StatelessWidget {
  const VirutaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VIRUTA',
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

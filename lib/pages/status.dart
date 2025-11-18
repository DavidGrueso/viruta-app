import 'package:flutter/material.dart';

class StatusPage extends StatelessWidget {
  const StatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Más adelante leeremos el estado real desde ESP32 o mock API.
    return Scaffold(
      appBar: AppBar(
        title: const Text("Estado de la máquina"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Temperatura actual: 210°C", style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text("Objetivo: 240°C", style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text("Motor: Encendido", style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text("RPM: 80", style: TextStyle(fontSize: 20))
          ],
        ),
      ),
    );
  }
}

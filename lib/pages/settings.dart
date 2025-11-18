import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ajustes"),
      ),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Ajustes generales de la app",
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            Text("• Aquí configuraremos el mDNS / IP de la máquina"),
            Text("• Modo oscuro"),
            Text("• Pruebas de conexión"),
            Text("• Idioma, etc.")
          ],
        ),
      ),
    );
  }
}

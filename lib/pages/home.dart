import 'package:flutter/material.dart';
import 'status.dart';
import 'settings.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("VIRUTA"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StatusPage()),
                );
              },
              child: const Text("Estado de la máquina"),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                );
              },
              child: const Text("Ajustes"),
            ),
          ],
        ),
      ),
    );
  }
}

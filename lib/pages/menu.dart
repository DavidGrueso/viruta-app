import 'package:flutter/material.dart';
import 'settings.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Menú")),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Ajustes"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SettingsPage(toggleTheme: () {})),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Cuenta"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text("Preferencias"),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

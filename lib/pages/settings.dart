import 'package:flutter/material.dart';
import 'home.dart';



class SettingsPage extends StatelessWidget {
  final VoidCallback toggleTheme;
  const SettingsPage({super.key, required this.toggleTheme});
  

  @override
  Widget build(BuildContext context) {

    TextButton(
                onPressed: toggleTheme,
                child: const Text("Modo claro / oscuro"),
              );
    return Scaffold(
      appBar: AppBar(title: const Text("Ajustes")),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: Text("Aquí irán los ajustes de la máquina y la app."),

        
      ),
      
    );
    
  }
}

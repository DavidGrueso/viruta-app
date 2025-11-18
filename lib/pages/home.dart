import 'package:flutter/material.dart';
import 'menu.dart';
import '../widgets/viruta_card.dart';
import '../services/mock.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  double temp = 0;
  String connection = "Desconectado";
  int timeUsedMin = 0;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    var data = await MockAPI.getStatus();
    setState(() {
      temp = data["temp"];
      timeUsedMin = data["usageMin"];
      connection = data["connected"] ? "Conectado" : "Desconectado";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("VIRUTA Dashboard"),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MenuPage()),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            VirutaCard(
              title: "Temperatura",
              value: "$temp °C",
              icon: Icons.thermostat,
            ),
            VirutaCard(
              title: "Tiempo de uso",
              value: "${timeUsedMin} min",
              icon: Icons.timer,
            ),
            VirutaCard(
              title: "Conexión",
              value: connection,
              icon: Icons.wifi,
            ),
          ],
        ),
      ),
    );
  }
}

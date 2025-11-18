import 'package:flutter/material.dart';
import 'menu.dart';
import 'profile.dart';
import 'settings.dart';
import '../widgets/home_dashboard.dart';
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
        title: const Text("VIRUTA"),
        // Menu icon on the right (actions) that opens a limited-width right drawer
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      // Right-side drawer with limited width so it doesn't cover whole screen
      endDrawer: Drawer(
        // limit drawer width to 60% of screen or a max of 360
        width: MediaQuery.of(context).size.width * 0.6 < 360
            ? MediaQuery.of(context).size.width * 0.6
            : 360,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 47, 101, 61),
                  borderRadius: BorderRadius.all( Radius.circular(0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('Menú', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 2),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Perfil'),
                onTap: () {
                  Navigator.pop(context); // close drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfilePage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Ajustes'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SettingsPage(toggleTheme: () {})),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Cerrar sesión'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: implementar logout
                },
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('v1.0', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: HomeDashboard(),
        ),
      ),
    );
  }
}
